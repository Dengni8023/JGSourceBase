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
    
    public override init() {
        super.init()
        
        var address = sockaddr_in6()
        address.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
        address.sin6_family = sa_family_t(AF_INET6)
        
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
        
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        
        var context = SCNetworkReachabilityContext(
            version: 0,
            info: selfPtr,
            retain: { info in
                let obj = Unmanaged<AnyObject>.fromOpaque(info).takeUnretainedValue()
                return UnsafeRawPointer(Unmanaged.passRetained(obj).toOpaque())
            },
            release: { info in
                Unmanaged<AnyObject>.fromOpaque(info).release()
            },
            copyDescription: nil
        )
        
        let callback: SCNetworkReachabilityCallBack = { target, flags, info in
            guard let info = info else { return }
            let reachability = Unmanaged<JGSReachability>.fromOpaque(info).takeUnretainedValue()
            DispatchQueue.main.async {
                reachability.notifyReachabilityStatusChange()
            }
        }
        
        if SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
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
    /// 网络接口标志常量
    /// IFF_WIRELESS 在 iOS SDK 中未定义，此处手动定义用于区分无线接口
    private let IFF_WIRELESS = 0x8000
    
    /// 检测当前是否通过有线网络连接
    /// 在 macOS 多网卡环境下，`en*` 接口可能是以太网也可能是 WiFi，无法通过接口名称区分。
    /// 解决方案：使用 IFF_WIRELESS 标志区分 WiFi 和有线接口。
    ///
    /// 检测逻辑：
    /// 1. 通过 getifaddrs 枚举所有网络接口
    /// 2. 检查接口是否启用（IFF_UP）并运行（IFF_RUNNING）
    /// 3. 排除特殊接口（回环、AirDrop、点对点、VPN）
    /// 4. 检查接口名称前缀（en*、bridge*）
    /// 5. 使用 IFF_WIRELESS 标志判断是否为 WiFi 接口
    /// 6. 验证 IP 地址和子网掩码是否有效
    ///
    /// @return YES 表示当前通过有线网络连接
    private func isWiredNetworkActive() -> Bool {
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        defer {
            if interfaces != nil {
                freeifaddrs(interfaces)
            }
        }
        
        // 调用失败直接返回 NO
        guard getifaddrs(&interfaces) == 0, let firstInterface = interfaces else {
            return false
        }
        
        // 遍历网络接口链表
        var currentInterface = firstInterface
        while true {
            let addr = currentInterface.pointee.ifa_addr
            
            // 仅检查 IPv4 接口（AF_INET）
            guard let addr = addr, addr.pointee.sa_family == UInt8(AF_INET) else {
                guard let nextInterface = currentInterface.pointee.ifa_next else {
                    break
                }
                currentInterface = nextInterface
                continue
            }
            
            let ifname = String(cString: currentInterface.pointee.ifa_name)
            let flags = currentInterface.pointee.ifa_flags
            
            // 检查接口标志：IFF_UP（接口已启用）&& IFF_RUNNING（接口已连接）
            guard (flags & UInt32(IFF_UP)) != 0 && (flags & UInt32(IFF_RUNNING)) != 0 else {
                guard let nextInterface = currentInterface.pointee.ifa_next else {
                    break
                }
                currentInterface = nextInterface
                continue
            }
            
            // 排除非物理网络接口：
            // - lo*: 回环接口
            // - awdl*: AirDrop 接口
            // - p2p*: 点对点连接接口
            // - utun*: VPN 隧道接口
            if ifname.hasPrefix("lo") ||
                ifname.hasPrefix("awdl") ||
                ifname.hasPrefix("p2p") ||
                ifname.hasPrefix("utun") {
                guard let nextInterface = currentInterface.pointee.ifa_next else {
                    break
                }
                currentInterface = nextInterface
                continue
            }
            
            // 有线网络接口特征：en*（以太网）、bridge*（桥接）
            guard ifname.hasPrefix("en") || ifname.hasPrefix("bridge") else {
                guard let nextInterface = currentInterface.pointee.ifa_next else {
                    break
                }
                currentInterface = nextInterface
                continue
            }
            
            // 关键判断：使用 IFF_WIRELESS 标志区分 WiFi 和有线
            // IFF_WIRELESS 标志在 net/if.h 中定义，表示无线接口
            if (flags & UInt32(IFF_WIRELESS)) != 0 {
                // 这是 WiFi 接口，不是有线网络
                guard let nextInterface = currentInterface.pointee.ifa_next else {
                    break
                }
                currentInterface = nextInterface
                continue
            }
            
            // 获取 IP 地址
            var addrBuf = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
            let sockaddrIn = currentInterface.pointee.ifa_addr!.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0 }
            inet_ntop(AF_INET, &sockaddrIn.pointee.sin_addr, &addrBuf, socklen_t(INET_ADDRSTRLEN))
            let ipAddr = String(decoding: addrBuf[..<addrBuf.count].map({ UInt8($0) }), as: UTF8.self)
            
            // 排除回环地址和 APIPA 地址（169.254.x.x）
            guard ipAddr != "127.0.0.1" && !ipAddr.hasPrefix("169.254.") else {
                guard let nextInterface = currentInterface.pointee.ifa_next else {
                    break
                }
                currentInterface = nextInterface
                continue
            }
            
            // 检查子网掩码是否有效（非全0）
            guard let netmaskAddr = currentInterface.pointee.ifa_netmask else {
                guard let nextInterface = currentInterface.pointee.ifa_next else {
                    break
                }
                currentInterface = nextInterface
                continue
            }
            
            let netmaskSockaddrIn = netmaskAddr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0 }
            let netmaskValue = netmaskSockaddrIn.pointee.sin_addr.s_addr
            guard netmaskValue != 0 else {
                guard let nextInterface = currentInterface.pointee.ifa_next else {
                    break
                }
                currentInterface = nextInterface
                continue
            }
            
            // 满足所有条件：有线接口、已启用且已连接、无 IFF_WIRELESS 标志、有有效网络配置
            return true
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
            // 2G 网络类型
            CTRadioAccessTechnologyGPRS: .WWANGPRS,
            CTRadioAccessTechnologyEdge: .WWAN2G,
            // 3G 网络类型
            CTRadioAccessTechnologyWCDMA: .WWAN3G,
            CTRadioAccessTechnologyHSDPA: .WWAN3G,
            CTRadioAccessTechnologyHSUPA: .WWAN3G,
            CTRadioAccessTechnologyCDMA1x: .WWAN3G,
            CTRadioAccessTechnologyCDMAEVDORev0: .WWAN3G,
            CTRadioAccessTechnologyCDMAEVDORevA: .WWAN3G,
            CTRadioAccessTechnologyCDMAEVDORevB: .WWAN3G,
            CTRadioAccessTechnologyeHRPD: .WWAN3G,
            // 4G 网络类型
            CTRadioAccessTechnologyLTE: .WWAN4G,
        ]
        
        // iOS 14.1 及以上版本支持 5G 网络类型定义
        if #available(iOS 14.1, *) {
            wwanInfoDict[CTRadioAccessTechnologyNRNSA] = .WWAN5G
            wwanInfoDict[CTRadioAccessTechnologyNR] = .WWAN5G
        }
        
        // 默认返回未知蜂窝网络类型
        var status: JGSReachabilityStatus = .WWAN
        // 创建 CoreTelephony 网络信息对象，获取当前无线接入技术
        let info = CTTelephonyNetworkInfo()
        info.serviceCurrentRadioAccessTechnology?.forEach({ (key: String, value: String) in
            if let networkStatus = wwanInfoDict[value] {
                status = networkStatus
                return
            }
        })
        return status
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
        // 模拟器环境下，通过枚举网络接口进一步区分有线和 WiFi
        // 在 macOS/iOS 模拟器环境下，有线网络接口通常以 en/bridge 开头
        if isWiredNetworkActive() {
            return .Wired
        }
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
        // 获取网络可达性标志位，flags 代表对默认路由地址的可连接性，
        // 包括是否需要网络连接、是否需要用户干预等信息
        guard let reachabilityRef = reachabilityRef else {
            return .unknown
        }
        
        var flags = SCNetworkReachabilityFlags()
        let didRetrieveFlags = withUnsafeMutablePointer(to: &flags) { ptr in
            SCNetworkReachabilityGetFlags(reachabilityRef, ptr)
        }
        
        // 获取标志位失败，返回未知状态
        guard didRetrieveFlags else {
            return .unknown
        }
        
        // 判断网络是否可达：标志位包含 .reachable 表示目标地址在当前网络配置下可达
        let isReachable = flags.contains(.reachable)
        if !isReachable {
            return .unreachable
        }
        
        // 判断是否需要主动建立连接：包含 .connectionRequired 表示需要额外的连接过程
        // 例如 VPN、拨号网络等需要手动或自动建立连接的场景
        let needsConnection = flags.contains(.connectionRequired)
        if !needsConnection {
            // 无需额外连接，直接判断网络类型
            return networkType(for: flags)
        }
        
        // 判断是否可以自动建立连接，无需用户干预：
        // - .connectionOnDemand 或 .connectionOnTraffic 表示系统可自动建立连接
        // - 且没有设置 .interventionRequired（不需要用户手动配置）
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        
        // 需要连接但无法自动连接（需用户手动配置），判定为不可达
        if !canConnectWithoutUserInteraction {
            return .unreachable
        }
        
        // 可自动连接，判断具体网络类型
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
        case .unknown,
             .unreachable,
             .WiFi:
            return false
        case .WWAN,
             .WWANGPRS,
             .WWAN2G,
             .WWAN3G,
             .WWAN4G,
             .WWAN5G:
            return true
        case .Wired:
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
