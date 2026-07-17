//
//  JGSReachability.swift
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/7/16.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import Foundation
import SystemConfiguration
import CoreTelephony

/// 网络连接状态枚举
/// 表示当前设备的网络连接类型，支持 WiFi、蜂窝移动网络和有线网络（模拟器）
@objc public
enum JGSReachabilityStatus: Int, Sendable {
    case unknown = 0 /// 未知网络类型
    case unreachable /// 网络不可达
    case WiFi /// 通过 WiFi 网络连接
    case WWAN /// 通过蜂窝移动网络连接（仅 iOS 真机），未知蜂窝移动网络时返回此值
    case WWANGPRS /// GPRS 网络（2G）
    case WWAN2G /// 2G 网络（EDGE 等）
    case WWAN3G /// 3G 网络（WCDMA、CDMA、HSDPA、HSUPA 等）
    case WWAN4G /// 4G 网络（LTE）
    case WWAN5G /// 5G 网络（NR/NRNSA）
    case Wired /// 通过有线网络连接（macOS/iOS 模拟器）
    
    /// 保留旧的命名，并标记为废弃，提供迁移提示
    @available(*, deprecated, renamed: "unreachable")
    public static var notReachable: JGSReachabilityStatus { .unreachable }
    @available(*, deprecated, renamed: "WiFi")
    public static var viaWiFi: JGSReachabilityStatus { .WiFi }
    @available(*, deprecated, renamed: "WWAN")
    public static var viaWWAN: JGSReachabilityStatus { .WWAN }
}

public let JGSReachabilityStatusChangedNotification = Notification.Name("JGSReachabilityStatusChangedNotification")

public let JGSReachabilityNotificationStatusKey = "JGSReachabilityNotificationStatusKey"

@objcMembers public final
class JGSReachability: NSObject, @unchecked Sendable {
    
    public nonisolated class var statusChangedNotification: NSNotification.Name {
        return JGSReachabilityStatusChangedNotification
    }
    
    public static let shared = JGSReachability()
    
    /// 获取单例实例
    /// 全局唯一的网络可达性管理对象，使用 dispatch_once 保证线程安全
    /// @return JGSReachability 单例对象
    @available(*, deprecated, renamed: "shared", message: "Replace by + shared")
    @objc public
    class func sharedInstance() -> JGSReachability {
        return shared
    }
    
    private var reachabilityRef: SCNetworkReachability?
    private var runningSchedule: Bool = false
    
    private var statusBlocks = NSMapTable<AnyObject, AnyObject>(keyOptions: .weakMemory, valueOptions: .strongMemory)
    private var statusSelectors = NSMapTable<AnyObject, NSString>(keyOptions: .weakMemory, valueOptions: .strongMemory)
    
    private let lock = NSRecursiveLock()
    
    /// 初始化网络可达性管理器
    /// 创建 IPv6 回环地址（::1）对应的 SCNetworkReachability 对象，用于监控默认路由的网络状态。
    /// 使用 IPv6 地址而非 IPv4 的原因：
    /// 1. IPv6 是未来网络协议标准，iOS/macOS 优先支持
    /// 2. 空的 IPv6 地址（全零）可以同时监控 IPv4 和 IPv6 网络
    /// 3. SCNetworkReachabilityCreateWithAddress 使用全零地址时，会监控整个网络栈的可达性
    public override init() {
        super.init()
        
        // 创建 IPv6 套接字地址结构体，所有字段初始化为 0
        var address = sockaddr_in6()
        // 设置地址长度字段，必须等于 sockaddr_in6 结构体的实际大小
        address.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
        // 设置地址族为 IPv6（AF_INET6）
        address.sin6_family = sa_family_t(AF_INET6)
        
        // 将 sockaddr_in6 指针强制转换为通用的 sockaddr 指针，因为
        // SCNetworkReachabilityCreateWithAddress 接受的是 sockaddr 类型参数
        let reachability = withUnsafePointer(to: &address) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { addr in
                SCNetworkReachabilityCreateWithAddress(nil, addr)
            }
        }
        
        self.reachabilityRef = reachability
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if let reachabilityRef = reachabilityRef {
            if runningSchedule {
                SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
            }
            SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
        }
    }
    
    // MARK: - Monitor
    
    /// 启动网络状态监听（全局调用）
    /// 可重复调用，已启动时重复调用无效
    /// 监听启动后，网络状态变化会通过三种方式通知：
    /// 1. Block 回调（通过 addObserver(_:statusChangeBlock:) 添加）
    /// 2. Selector 调用（通过 addObserver(_:selector:) 添加）
    /// 3. NSNotificationCenter 通知（.JGSReachabilityStatusChangedNotification）
    @objc public func startMonitor() {
        guard let reachabilityRef = reachabilityRef else {
            return
        }
        
        lock.lock()
        defer { lock.unlock() }
        
        guard !runningSchedule else {
            return
        }
        
        // 将 self 转换为不透明指针，传递给 C 回调函数。
        // 使用 passUnretained 而非 passRetained，因为 SCNetworkReachability 不会持有这个对象，
        // 而是通过 context 中的 retain/release 函数来管理生命周期
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        
        // SCNetworkReachabilityContext 是传递给 C 回调的上下文信息，包含：
        // - version: 版本号，必须为 0
        // - info: 自定义数据指针，这里是 self 的不透明指针
        // - retain: 当 context 需要被保留时调用的函数
        // - release: 当 context 需要被释放时调用的函数
        // - copyDescription: 可选的描述复制函数
        var context = SCNetworkReachabilityContext(
            version: 0,
            info: selfPtr,
            retain: { info in
                // retain 回调：将 info 指针还原为 AnyObject，然后 retain 它
                // 返回值是新的保留后的指针，SCNetworkReachability 会使用这个指针
                let obj = Unmanaged<AnyObject>.fromOpaque(info).takeUnretainedValue()
                return UnsafeRawPointer(Unmanaged.passRetained(obj).toOpaque())
            },
            release: { info in
                // release 回调：将 info 指针还原为 AnyObject，然后 release 它
                Unmanaged<AnyObject>.fromOpaque(info).release()
            },
            copyDescription: nil
        )
        
        // 网络状态变化回调函数，当 SCNetworkReachability 检测到网络状态变化时触发
        // - target: 保留的上下文指针（通过 retain 函数保留的）
        // - flags: 最新的网络可达性标志位
        // - info: 原始的上下文指针（未保留）
        let callback: SCNetworkReachabilityCallBack = { target, flags, info in
            guard let info = info else { return }
            // 将 info 指针还原为 JGSReachability 实例
            let reachability = Unmanaged<JGSReachability>.fromOpaque(info).takeUnretainedValue()
            // 在主线程通知状态变化，确保 UI 更新和回调在主线程执行
            DispatchQueue.main.async {
                reachability.notifyReachabilityStatusChange()
            }
#if targetEnvironment(simulator)
            // 模拟器特殊处理：当 SCNetworkReachability 报告不可达时，
            // 延迟 2 秒再次检查，因为模拟器的网络状态变化通知可能有延迟
            // 这是一个 workaround，用于处理模拟器中网络状态变化的时序问题
            if !flags.contains(.reachable) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    reachability.notifyReachabilityStatusChange()
                }
            }
#endif
        }
        
        // 设置回调函数和上下文
        if SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
            // 将 SCNetworkReachability 对象注册到主 RunLoop，使其开始监听网络状态变化
            runningSchedule = SCNetworkReachabilityScheduleWithRunLoop(
                reachabilityRef,
                CFRunLoopGetMain(),
                CFRunLoopMode.commonModes.rawValue
            )
        }
    }
    
    /// 停止网络状态监听
    /// 将网络可达性引用从运行循环中移除，停止接收网络状态变化通知
    /// 可重复调用，未启动时调用无效
    /// 停止后，网络状态变化将不再触发回调、Selector 和 Notification 通知
    @objc public func stopMonitor() {
        guard let reachabilityRef = reachabilityRef else {
            return
        }
        
        lock.lock()
        defer { lock.unlock() }
        
        guard runningSchedule else {
            return
        }
        
        runningSchedule = !SCNetworkReachabilityUnscheduleFromRunLoop(
            reachabilityRef,
            CFRunLoopGetMain(),
            CFRunLoopMode.commonModes.rawValue
        )
    }
    
    // MARK: - Observer
    
    /// 添加网络状态变化监听（Block 方式）
    /// 可添加多个监听者，内部使用 NSMapTable 弱引用持有 observer，防止循环引用
    /// 添加后会自动调用 startMonitor 启动监听
    /// @param observer 监听接收者（弱引用，释放时自动移除）
    /// @param block 状态变化时的回调 Block，传入当前网络状态
    @objc public func addObserver(_ observer: AnyObject, statusChangeBlock block: ((JGSReachabilityStatus) -> Void)?) {
        lock.lock()
        defer { lock.unlock() }
        
        if let block = block {
            statusBlocks.setObject(block as AnyObject, forKey: observer)
        }
        
        startMonitor()
    }
    
    /// 移除指定观察者的 Block 监听
    /// 非必需调用，observer 内存释放时会自动从 NSMapTable 中移除
    /// @param observer 监听接收者
    @objc public func removeStatusChangeBlock(with observer: AnyObject) {
        lock.lock()
        defer { lock.unlock() }
        
        statusBlocks.removeObject(forKey: observer)
    }
    
    /// 添加网络状态变化监听（Selector 方式）
    /// 可添加多个监听者，内部使用 NSMapTable 弱引用持有 observer
    /// selector 定义规则：
    /// - 不带参数或带单个可选参数，参数类型为 JGSReachability
    /// - 定义多个参数时仅第一个参数有效
    /// 添加后会自动调用 startMonitor 启动监听
    /// @param observer 监听接收者（弱引用，释放时自动移除）
    /// @param selector 状态变化时执行的方法选择器
    @objc public func addObserver(_ observer: AnyObject, selector: Selector) {
        lock.lock()
        defer { lock.unlock() }
        
        statusSelectors.setObject(NSStringFromSelector(selector) as NSString, forKey: observer)
        
        startMonitor()
    }
    
    /// 移除指定观察者的 Selector 监听
    /// 非必需调用，observer 内存释放时会自动从 NSMapTable 中移除
    /// @param observer 监听接收者
    @objc public func removeSelector(with observer: AnyObject) {
        lock.lock()
        defer { lock.unlock() }
        
        statusSelectors.removeObject(forKey: observer)
    }
    
    // MARK: - Notify
    
    /// 通知所有监听者网络状态变化
    /// 通过三种方式通知监听者，确保所有注册的监听者都能收到网络状态变化的通知：
    /// 1. Block 回调方式（通过 addObserver(_:statusChangeBlock:) 添加）
    /// 2. Selector 调用方式（通过 addObserver(_:selector:) 添加），延迟到 runloop 结束后执行
    /// 3. NotificationCenter 通知方式（.JGSReachabilityStatusChangedNotification）
    ///
    /// 注意事项：
    /// - 使用 allObjects 获取容器快照，避免枚举过程中容器被修改导致异常
    /// - Selector 调用使用 afterDelay:0，避免在回调中修改监听者容器导致的嵌套调用问题
    /// - 通知中携带当前网络状态，可通过 JGSReachabilityNotificationStatusKey 从 userInfo 中获取
    private func notifyReachabilityStatusChange() {
        let status = reachabilityStatus
        
        lock.lock()
        let blocks = statusBlocks.objectEnumerator()?.allObjects ?? []
        let selectorKeys = statusSelectors.keyEnumerator().allObjects as [AnyObject]
        lock.unlock()
        
        for block in blocks {
            if let statusBlock = block as? (JGSReachabilityStatus) -> Void {
                statusBlock(status)
            }
        }
        
        for keyObj in selectorKeys {
            lock.lock()
            let selectorStr = statusSelectors.object(forKey: keyObj)
            lock.unlock()
            
            if let selectorStr = selectorStr {
                let selector = NSSelectorFromString(selectorStr as String)
                if keyObj.responds(to: selector) {
                    keyObj.perform(selector, with: self, afterDelay: 0)
                }
            }
        }
        
        NotificationCenter.default.post(
            name: JGSReachabilityStatusChangedNotification,
            object: self,
            userInfo: [JGSReachabilityNotificationStatusKey: status.rawValue]
        )
    }
    
    // MARK: - Private
    
#if targetEnvironment(simulator)
    /// 获取所有活跃的以太网接口（en*）名称列表
    /// 通过 getifaddrs 系统调用遍历系统中的所有网络接口，筛选出符合条件的以太网接口：
    /// 1. 接口名称以 "en" 开头（以太网接口命名约定）
    /// 2. 接口处于活跃状态（UP 且 RUNNING）
    /// 3. 拥有有效的 IPv4 地址（非回环地址、非链路本地地址）
    /// 4. 拥有有效的子网掩码
    ///
    /// 注意：一个网络接口可能有多个地址条目（IPv4、IPv6、不同的地址类型），
    /// 使用 seenInterfaces Set 去重，确保每个接口只添加一次
    ///
    /// @return 活跃的以太网接口名称数组，如 ["en0", "en1"]
    private func getActiveENInterfaces() -> [String] {
        // ifaddrs 是一个链表结构，每个节点代表一个网络接口的地址信息
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        // 使用 defer 确保在函数返回前释放 ifaddrs 链表资源
        defer {
            if interfaces != nil {
                freeifaddrs(interfaces)
            }
        }
        
        // 调用 getifaddrs 获取系统中所有网络接口的信息
        // 返回 0 表示成功，interfaces 指向链表头节点
        guard getifaddrs(&interfaces) == 0, let firstInterface = interfaces else {
            return []
        }
        
        var activeInterfaces = [String]()
        // seenInterfaces 用于去重，避免同一个接口多次添加
        var seenInterfaces = Set<String>()
        
        var currentInterface = firstInterface
        // 遍历 ifaddrs 链表，直到遇到 nil（链表结束）
        while true {
            let interface = currentInterface.pointee
            
            // 过滤条件1：必须有地址信息，且地址族为 IPv4（AF_INET）
            // 忽略 IPv6 地址和其他类型的地址
            guard let addr = interface.ifa_addr, addr.pointee.sa_family == UInt8(AF_INET) else {
                guard let nextInterface = interface.ifa_next else { break }
                currentInterface = nextInterface
                continue
            }
            
            // 获取接口名称，如 "en0"、"lo0" 等
            // 使用 String(decoding:as:) 替代 cString，避免编译器警告
            let ifname = String(decoding: interface.ifa_name.withMemoryRebound(to: UInt8.self, capacity: Int(strlen(interface.ifa_name))) {
                UnsafeBufferPointer(start: $0, count: Int(strlen(interface.ifa_name)))
            }, as: UTF8.self)
            
            // 过滤条件2：跳过已经处理过的接口（去重）
            if seenInterfaces.contains(ifname) {
                guard let nextInterface = interface.ifa_next else { break }
                currentInterface = nextInterface
                continue
            }
            
            // 过滤条件3：接口名称必须以 "en" 开头（以太网接口），
            // 并且通过 isInterfaceActive 检查接口是否真正活跃
            if ifname.hasPrefix("en"), isInterfaceActive(currentInterface) {
                activeInterfaces.append(ifname)
                seenInterfaces.insert(ifname)
            }
            
            // 移动到链表的下一个节点
            guard let nextInterface = interface.ifa_next else { break }
            currentInterface = nextInterface
        }
        
        return activeInterfaces
    }
    
    /// 判断网络接口是否处于活跃状态
    /// 一个接口被认为是活跃的，需要同时满足以下条件：
    /// 1. 接口标志位包含 IFF_UP（接口已启用）和 IFF_RUNNING（接口正在运行）
    /// 2. 拥有有效的 IPv4 地址（非回环地址 127.0.0.1，非链路本地地址 169.254.x.x）
    /// 3. 拥有有效的子网掩码（非全零）
    ///
    /// @param interfacePtr ifaddrs 链表节点指针
    /// @return YES 表示接口活跃且可用，NO 表示接口不活跃或不可用
    private func isInterfaceActive(_ interfacePtr: UnsafeMutablePointer<ifaddrs>) -> Bool {
        let interface = interfacePtr.pointee
        
        // 获取接口标志位，通过位运算检查接口状态
        let flags = interface.ifa_flags
        // IFF_UP：接口已启用（管理员已将其启用）
        let isUp = (flags & UInt32(IFF_UP)) != 0
        // IFF_RUNNING：接口正在运行（有载波信号，物理连接正常）
        let isRunning = (flags & UInt32(IFF_RUNNING)) != 0
        
        // 快速失败：接口未启用或未运行，直接返回 false
        guard isUp && isRunning else {
            return false
        }
        
        // 将 sockaddr 指针转换为 sockaddr_in 指针，提取 IPv4 地址
        var addrBuf = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
        let sockaddrIn = interface.ifa_addr!.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0 }
        // 将二进制 IP 地址转换为字符串格式（如 "192.168.1.100"）
        inet_ntop(AF_INET, &sockaddrIn.pointee.sin_addr, &addrBuf, socklen_t(INET_ADDRSTRLEN))
        let ipAddr = String(decoding: addrBuf[..<addrBuf.count].map({ UInt8($0) }), as: UTF8.self)
        
        // 过滤无效 IP 地址：
        // - 回环地址 127.0.0.1：表示本地回环接口，不是真实网络连接
        // - 链路本地地址 169.254.x.x：DHCP 失败时自动分配的地址，无法访问外部网络
        guard ipAddr != "127.0.0.1" && !ipAddr.hasPrefix("169.254.") else {
            return false
        }
        
        // 检查子网掩码是否有效：
        // 如果子网掩码为全零（sin_addr.s_addr == 0），表示没有正确配置子网掩码，
        // 这样的接口无法进行正常的网络通信
        if let netmaskAddr = interface.ifa_netmask {
            let netmaskSockaddrIn = netmaskAddr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0 }
            if netmaskSockaddrIn.pointee.sin_addr.s_addr == 0 {
                return false
            }
        }
        
        // 所有检查通过，接口是活跃的
        return true
    }
    
    /// 执行系统命令并返回输出结果
    /// 使用 POSIX 的 posix_spawn API 执行命令，相比 Swift 的 Process API 更稳定可靠，
    /// 尤其在模拟器环境下兼容性更好。
    ///
    /// 执行流程：
    /// 1. 将命令字符串按空格分割为参数数组
    /// 2. 创建管道（pipe）用于捕获命令输出
    /// 3. 配置 posix_spawn 的文件操作，将子进程的 stdout 重定向到管道
    /// 4. 调用 posix_spawn 创建并执行子进程
    /// 5. 等待子进程执行完毕（waitpid）
    /// 6. 从管道读取命令输出数据
    /// 7. 清理资源（关闭文件描述符、释放内存）
    ///
    /// @param command 命令字符串，如 "networksetup -listallhardwareports"
    /// @return 命令执行的输出字符串，失败时返回 nil
    private func executeCommand(_ command: String) -> String? {
        // 将命令字符串按空格分割为参数数组
        let args = command.components(separatedBy: " ")
        guard let path = args.first else {
            return nil
        }
        
        // 将参数数组转换为 C 风格的 argv 数组（以 nil 结尾）
        // strdup 复制每个字符串到堆内存，需要在 defer 中释放
        var argv = args.map { strdup($0) }
        argv.append(nil)
        defer {
            argv.forEach { if let ptr = $0 { free(ptr) } }
        }
        
        // 创建管道，用于捕获子进程的标准输出
        // pipeFD[0] 是读取端，pipeFD[1] 是写入端
        var pipeFD: [Int32] = [0, 0]
        guard pipe(&pipeFD) == 0 else {
            return nil
        }
        
        let stdoutRead = pipeFD[0]
        let stdoutWrite = pipeFD[1]
        
        var pid: pid_t = 0
        // posix_spawn_file_actions_t 用于配置子进程的文件描述符
        var fileActions: posix_spawn_file_actions_t?
        
        // 初始化文件操作对象
        let initResult = posix_spawn_file_actions_init(&fileActions)
        guard initResult == 0 else {
            close(stdoutRead)
            close(stdoutWrite)
            return nil
        }
        
        // 在函数返回前销毁文件操作对象
        defer {
            posix_spawn_file_actions_destroy(&fileActions)
        }
        
        // 添加文件操作：关闭子进程中的读取端文件描述符
        // 子进程不需要读取管道，只需要写入
        guard posix_spawn_file_actions_addclose(&fileActions, stdoutRead) == 0 else {
            close(stdoutRead)
            close(stdoutWrite)
            return nil
        }
        
        // 添加文件操作：将管道的写入端复制到 STDOUT_FILENO（标准输出）
        // 这样子进程的标准输出就会写入管道
        guard posix_spawn_file_actions_adddup2(&fileActions, stdoutWrite, STDOUT_FILENO) == 0 else {
            close(stdoutRead)
            close(stdoutWrite)
            return nil
        }
        
        // 添加文件操作：关闭子进程中的写入端文件描述符
        // dup2 之后原始的写入端就不需要了
        guard posix_spawn_file_actions_addclose(&fileActions, stdoutWrite) == 0 else {
            close(stdoutRead)
            close(stdoutWrite)
            return nil
        }
        
        // 调用 posix_spawn 创建并执行子进程
        // - pid: 输出参数，返回子进程 ID
        // - path: 可执行文件路径
        // - fileActions: 文件操作配置
        // - nil: 属性参数，使用默认值
        // - argv: 命令参数数组
        // - environ: 环境变量，继承父进程的环境变量
        let status = posix_spawn(&pid, path, &fileActions, nil, argv, environ)
        
        // 父进程关闭写入端，因为已经不需要了
        close(stdoutWrite)
        
        // posix_spawn 返回非零表示失败
        if status != 0 {
            close(stdoutRead)
            return nil
        }
        
        // 等待子进程执行完毕
        var waitStatus: Int32 = 0
        waitpid(pid, &waitStatus, 0)
        
        // 从管道读取命令输出
        var data = [UInt8]()
        var buffer = [UInt8](repeating: 0, count: 1024)
        
        while true {
            let bytesRead = read(stdoutRead, &buffer, buffer.count)
            if bytesRead <= 0 {
                break
            }
            data.append(contentsOf: buffer[0..<Int(bytesRead)])
        }
        
        // 关闭读取端
        close(stdoutRead)
        
        // 将二进制数据转换为字符串
        return String(bytes: data, encoding: .utf8)
    }
    
    private func isWiFiInterface(_ ifname: String) -> Bool {
        let wifiInterfaces = getWiFiInterfaceNames()
        // JGSDebugLog("WiFi interfaces: \(wifiInterfaces)")
        return wifiInterfaces.contains(ifname)
    }
    
    /// 获取 WiFi 接口名称集合
    /// 通过执行 `networksetup -listallhardwareports` 命令获取系统中所有硬件端口信息，
    /// 解析输出内容，找到类型为 "Wi-Fi" 的端口对应的设备名称（如 "en0"）。
    ///
    /// 命令输出格式示例：
    /// ```
    /// Hardware Port: Wi-Fi
    /// Device: en0
    /// Ethernet Address: aa:bb:cc:dd:ee:ff
    ///
    /// Hardware Port: Ethernet
    /// Device: en1
    /// Ethernet Address: 11:22:33:44:55:66
    /// ```
    ///
    /// 解析逻辑：
    /// 1. 遍历每一行，记录当前端口类型（Hardware Port）
    /// 2. 当遇到 Device 行时，检查当前端口类型是否为 "Wi-Fi"
    /// 3. 如果是，提取设备名称并添加到结果集合中
    ///
    /// 容错处理：
    /// - 命令执行失败时，默认返回 ["en0"]（macOS 上 WiFi 接口通常是 en0）
    /// - 解析结果为空时，同样默认返回 ["en0"]
    ///
    /// @return WiFi 接口名称集合，如 ["en0"]
    private func getWiFiInterfaceNames() -> Set<String> {
        var names = Set<String>()
        
        // 执行 networksetup 命令获取硬件端口信息
        guard let output = executeCommand("networksetup -listallhardwareports") else {
            // 命令执行失败，返回默认值 en0
            names.insert("en0")
            return names
        }
        
        // 用于记录当前正在处理的端口类型
        var currentPortType: String?
        
        // 按行分割命令输出
        for line in output.components(separatedBy: "\n") {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 匹配 "Hardware Port: xxx" 行，提取端口类型
            if trimmedLine.hasPrefix("Hardware Port:") {
                let portType = trimmedLine.replacingOccurrences(of: "Hardware Port: ", with: "")
                currentPortType = portType
            }
            // 匹配 "Device: xxx" 行，提取设备名称
            else if trimmedLine.hasPrefix("Device:") {
                let device = trimmedLine.replacingOccurrences(of: "Device: ", with: "")
                // 如果当前端口类型是 Wi-Fi，将设备名称添加到结果中
                if let portType = currentPortType, portType == "Wi-Fi" {
                    names.insert(device)
                }
            }
        }
        
        // 如果没有找到 WiFi 接口，返回默认值 en0
        if names.isEmpty {
            names.insert("en0")
        }
        
        return names
    }
    
    /// 检测当前是否通过有线网络连接
    /// 在 macOS 多网卡环境下，`en*` 接口可能是以太网也可能是 WiFi，无法通过接口名称区分。
    /// 解决方案：获取所有活跃的 en* 接口，通过接口类型判断 WiFi 接口。
    /// 如果只有一个活跃的 en* 接口且不是 WiFi，则认为是有线网络。
    /// 如果有多个活跃的 en* 接口，排除 WiFi 接口后检查是否有有线接口。
    ///
    /// @return YES 表示当前通过有线网络连接
    private func isWiredNetworkActive(_ activeInterfaces: [String]? = nil) -> Bool {
        let interfaces = activeInterfaces ?? getActiveENInterfaces()
        // JGSDebugLog("Active en* interfaces: \(interfaces)")
        
        if interfaces.count == 0 {
            return false
        }
        
        if interfaces.count == 1 {
            let ifname = interfaces[0]
            let isWiFi = isWiFiInterface(ifname)
            // JGSDebugLog("Single interface: \(ifname), isWiFi: \(isWiFi)")
            return !isWiFi
        }
        
        for ifname in interfaces {
            if !isWiFiInterface(ifname) {
                // JGSDebugLog("Found wired interface: \(ifname)")
                return true
            }
        }
        
        return false
    }
    
#endif
    
    /// 获取蜂窝移动网络具体类型
    /// 通过 CoreTelephony 框架获取当前无线接入技术，映射到对应的蜂窝网络类型
    /// 无线接入技术标识（CTRadioAccessTechnology*）与网络类型的映射关系：
    /// - 2G: GPRS、EDGE
    /// - 3G: WCDMA、HSDPA、HSUPA、CDMA1x、CDMAEVDO(Rev0/A/B)、eHRPD
    /// - 4G: LTE
    /// - 5G: NRNSA（非独立组网）、NR（独立组网）- iOS 14.1+
    /// @return 蜂窝网络状态枚举值（WWAN/GPRS/2G/3G/4G/5G）
    private func wwanNetworkStatus() -> JGSReachabilityStatus {
        var wwanInfoDict: [String: JGSReachabilityStatus] = [
            CTRadioAccessTechnologyGPRS: .WWANGPRS,
            CTRadioAccessTechnologyEdge: .WWAN2G,
            CTRadioAccessTechnologyWCDMA: .WWAN3G,
            CTRadioAccessTechnologyHSDPA: .WWAN3G,
            CTRadioAccessTechnologyHSUPA: .WWAN3G,
            CTRadioAccessTechnologyCDMA1x: .WWAN3G,
            CTRadioAccessTechnologyCDMAEVDORev0: .WWAN3G,
            CTRadioAccessTechnologyCDMAEVDORevA: .WWAN3G,
            CTRadioAccessTechnologyCDMAEVDORevB: .WWAN3G,
            CTRadioAccessTechnologyeHRPD: .WWAN3G,
            CTRadioAccessTechnologyLTE: .WWAN4G,
        ]
        
        if #available(iOS 14.1, *) {
            wwanInfoDict[CTRadioAccessTechnologyNRNSA] = .WWAN5G
            wwanInfoDict[CTRadioAccessTechnologyNR] = .WWAN5G
        }
        
        let info = CTTelephonyNetworkInfo()
        for (_, accessTechnology) in info.serviceCurrentRadioAccessTechnology ?? [:] {
            if let networkStatus = wwanInfoDict[accessTechnology] {
                return networkStatus
            }
        }
        return .WWAN
    }
    
    /// 根据网络可达性标志位判断网络类型
    /// @param flags 网络可达性标志位集合
    /// @return 网络类型枚举值（WiFi/WWAN/Wired）
    private func networkType(for flags: SCNetworkReachabilityFlags) -> JGSReachabilityStatus {
        // 判断是否为蜂窝移动网络：.isWWAN 仅在 iOS 真机上有效，
        // macOS 和 iOS 模拟器永远不会设置此标志
        if flags.contains(.isWWAN) {
            // 通过 CoreTelephony 获取具体蜂窝网络类型（GPRS/2G/3G/4G/5G）
            return wwanNetworkStatus()
        }
        
#if targetEnvironment(simulator)
        let activeInterfaces = getActiveENInterfaces()
        // JGSDebugLog("networkType: flags reachable, active interfaces count: \(activeInterfaces.count)")
        
        if activeInterfaces.isEmpty {
            return .unreachable
        }
        
        return isWiredNetworkActive(activeInterfaces) ? .Wired : .WiFi
#endif
        
        // 真机上非蜂窝网络即为 WiFi
        return .WiFi
    }
    
    // MARK: - Properties
    
    /// 当前网络连接类型（只读）
    /// 通过 SCNetworkReachabilityGetFlags 获取网络可达性标志位，
    /// 结合 getifaddrs 枚举网络接口（模拟器），综合判断当前网络连接类型
    ///
    /// 核心判断逻辑：
    /// 1. 调用 SCNetworkReachabilityGetFlags 获取当前网络配置的标志位集合
    /// 2. 解析标志位判断网络是否可达（isReachable）
    /// 3. 判断是否需要用户干预（needsConnection、canConnectWithoutUserInteraction）
    /// 4. 根据 .isWWAN 标志区分蜂窝网络和其他网络
    /// 5. 模拟器环境下，通过枚举网络接口进一步区分有线网络和 WiFi
    ///
    /// 网络可达性标志位说明：
    /// - .reachable: 当前网络配置可连接到目标
    /// - .connectionRequired: 需要先建立连接过程
    /// - .connectionOnTraffic: 按需自动建立连接
    /// - .interventionRequired: 需要用户手动配置
    /// - .connectionOnDemand: 通过 CFSocketStream 自动建立连接
    /// - .isWWAN: 通过蜂窝移动网络连接（仅 iOS 真机）
    ///
    /// @return 当前网络连接状态枚举值（Unreachable/WiFi/WWAN/Wired）
    @objc public var reachabilityStatus: JGSReachabilityStatus {
        guard let reachabilityRef = reachabilityRef else {
            return .unknown
        }
        
        var flags = SCNetworkReachabilityFlags()
        let didRetrieveFlags = withUnsafeMutablePointer(to: &flags) { ptr in
            SCNetworkReachabilityGetFlags(reachabilityRef, ptr)
        }
        
        guard didRetrieveFlags else {
            return .unknown
        }
        
        return status(from: flags)
    }
    
    /// 根据网络可达性标志位解析当前网络状态
    /// 这是网络状态判断的核心逻辑，按照以下优先级顺序判断：
    ///
    /// 1. **网络不可达**：flags 不包含 .reachable
    ///    - 模拟器环境下有特殊处理：即使 SCNetworkReachability 报告不可达，
    ///      仍通过枚举网络接口来判断实际网络状态（避免模拟器误报）
    ///
    /// 2. **网络可达且无需额外连接**：flags 不包含 .connectionRequired
    ///    - 直接判断网络类型（WiFi/WWAN/Wired）
    ///
    /// 3. **网络可达但需要额外连接**：flags 包含 .connectionRequired
    ///    - 检查是否可以自动连接（.connectionOnDemand 或 .connectionOnTraffic）
    ///    - 检查是否需要用户干预（.interventionRequired）
    ///    - 如果可以自动连接且无需用户干预，则判断网络类型
    ///    - 否则视为不可达
    ///
    /// @param flags SCNetworkReachabilityFlags 标志位集合
    /// @return 网络状态枚举值
    private func status(from flags: SCNetworkReachabilityFlags) -> JGSReachabilityStatus {
        // 第一步：判断网络是否可达
        guard flags.contains(.reachable) else {
#if targetEnvironment(simulator)
            // 模拟器特殊处理：SCNetworkReachability 可能在网络切换时误报不可达，
            // 通过枚举实际网络接口来确认真实的网络状态
            let activeInterfaces = getActiveENInterfaces()
            if !activeInterfaces.isEmpty {
                return isWiredNetworkActive(activeInterfaces) ? .Wired : .WiFi
            }
#endif
            return .unreachable
        }
        
        // 第二步：判断是否需要额外连接才能访问目标
        // .connectionRequired 表示需要先建立连接（如 VPN、拨号等）
        guard flags.contains(.connectionRequired) else {
            // 无需额外连接，直接判断网络类型
            return networkType(for: flags)
        }
        
        // 第三步：如果需要额外连接，检查是否可以自动连接
        // .connectionOnDemand：系统会在需要时自动建立连接（通过 CFSocketStream）
        // .connectionOnTraffic：系统会在有流量时自动建立连接
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        
        // 检查是否需要用户手动干预（如输入密码、确认连接等）
        // 如果设置了 .interventionRequired，则无法自动连接
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        
        guard canConnectWithoutUserInteraction else {
            // 需要用户干预才能连接，视为不可达
            return .unreachable
        }
        
        // 可以自动连接，判断具体网络类型
        return networkType(for: flags)
    }
    
    /// 网络是否可达（只读）
    /// @return YES 表示网络可达（包括 WiFi、蜂窝、有线），NO 表示网络不可达
    @objc public var reachable: Bool {
        return reachabilityStatus != .unreachable
    }
    
    /// 是否通过 WiFi 连接（只读）
    /// @return YES 表示当前通过 WiFi 网络连接，不包含有线网络
    @objc public var reachableViaWiFi: Bool {
        return reachabilityStatus == .WiFi
    }
    
    /// 是否通过蜂窝移动网络连接（只读，仅 iOS 真机）
    /// 蜂窝网络包含以下所有类型：WWAN、GPRS、2G、3G、4G、5G
    /// @return YES 表示当前通过任意蜂窝移动网络连接
    @objc public var reachableViaWWAN: Bool {
        switch reachabilityStatus {
        case .WWAN, .WWANGPRS, .WWAN2G, .WWAN3G, .WWAN4G, .WWAN5G:
            return true
        default:
            return false
        }
    }
    
    /// 是否通过有线网络连接（只读，macOS/iOS 模拟器）
    /// 通过枚举网络接口（getifaddrs）判断是否存在活动的有线网络接口
    /// @return YES 表示当前通过有线网络连接
    @objc public var reachableViaWired: Bool {
        return reachabilityStatus == .Wired
    }
    
    /// 网络连接类型的字符串描述（只读）
    /// 将 JGSReachabilityStatus 枚举值转换为人类可读的字符串，便于日志输出和 UI 展示
    /// 返回值说明：
    /// - "Unknown": 未知网络类型
    /// - "NoNetwork": 网络不可达
    /// - "WiFi": 通过 WiFi 网络连接
    /// - "Wired": 通过有线网络连接（仅模拟器）
    /// - "Mobile": 未知蜂窝网络类型
    /// - "GPRS/2G/3G/4G/5G": 具体蜂窝网络技术类型
    /// @return 网络状态字符串
    @objc public var reachabilityStatusString: String {
        let reachAbilityStatusDict: [JGSReachabilityStatus: String] = [
            .unknown: "Unknown",
            .unreachable: "NoNetwork",
            .WiFi: "WiFi",
            .WWAN: "Mobile",
            .WWANGPRS: "GPRS",
            .WWAN2G: "2G",
            .WWAN3G: "3G",
            .WWAN4G: "4G",
            .WWAN5G: "5G",
            .Wired: "Wired",
        ]
        if let statusString = reachAbilityStatusDict[reachabilityStatus] {
            return statusString
        }
        return "Unknown"
    }
}
