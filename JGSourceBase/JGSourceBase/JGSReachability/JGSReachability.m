//
//  JGSReachability.m
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/7/16.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import "JGSReachability.h"
//#import <SystemConfiguration/SystemConfiguration.h>
//#import <CoreTelephony/CTTelephonyNetworkInfo.h>
//#import <netinet/in.h>
//#import <ifaddrs.h>
//#import <arpa/inet.h>
//#import <net/if.h>
//#import "JGSLogger+Private.h"
//#import "JGSWeakStrong.h"

NSNotificationName const JGSReachabilityStatusChangedNotification = @"JGSReachabilityStatusChangedNotification";

JGSReachabilityNotificationKey const JGSReachabilityNotificationStatusKey = @"JGSReachabilityNotificationStatusKey";

//@interface JGSReachability ()
//
//@property (nonatomic, assign, readonly) SCNetworkReachabilityRef reachabilityRef;
//@property (nonatomic, assign, readonly) BOOL runningSchedule;
//
//@property (nonatomic, strong, readonly) NSMapTable *statusBlocks;
//@property (nonatomic, strong, readonly) NSMapTable *statusSelectors;
//
//@end
//
//@implementation JGSReachability
//
//#pragma mark - ClassMethod
//+ (instancetype)sharedInstance {
//    return [self shared];
//}
//
//+ (instancetype)shared {
//    
//    static JGSReachability *instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        
//        instance = [[self alloc] init];
//    });
//    
//    return instance;
//}
//
//#pragma mark - init & dealloc
///// 初始化方法（私有）
///// 初始化监听者容器，并创建 IPv6 零地址的网络可达性引用
///// IPv6 零地址 (::) 表示查询本机的默认路由网络状态
///// @return 初始化后的实例对象
//- (instancetype)init {
//    
//    self = [super init];
//    if (self) {
//        
//        // 初始化监听者容器，key 使用弱引用，value 使用强引用
//        // 这样当 observer 释放时会自动从容器中移除，避免野指针
//        _statusBlocks = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
//        _statusSelectors = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
//        
//        // 创建 IPv6 零地址结构，0:0:0:0:0:0:0:0 表示查询本机的网络连接状态
//        struct sockaddr_in6 address;
//        bzero(&address, sizeof(address));
//        address.sin6_len = sizeof(address);
//        address.sin6_family = AF_INET6;
//        
//        // 创建网络可达性引用，使用空地址查询默认路由
//        SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&address);
//        _reachabilityRef = CFRetain(defaultRouteReachability);
//        CFRelease(defaultRouteReachability);
//    }
//    
//    return self;
//}
//
///// 析构方法
///// 清理通知监听和网络可达性引用
//- (void)dealloc {
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    // 释放网络可达性引用，避免内存泄漏
//    if (_reachabilityRef != NULL) {
//        CFRelease(_reachabilityRef);
//        _reachabilityRef = NULL;
//    }
//}
//
//#pragma mark - Monitor
///// 检测当前是否通过有线网络连接
///// 通过 getifaddrs() 枚举所有网络接口，结合接口名称和标志位判断有线网络状态
///// 有线网络检测逻辑：
///// 1. 排除特殊接口：回环(lo*)、AirDrop(awdl*)、点对点(p2p*)、VPN(utun*)
///// 2. 判断接口名称前缀：en*(以太网)、bridge*(桥接)
///// 3. 检查接口状态：IFF_UP(接口已启用) && IFF_RUNNING(接口已连接)
///// 4. 排除 WiFi 接口：使用 IFF_WIRELESS 标志区分无线接口
///// 5. 验证 IP 地址：非回环地址(127.0.0.1)，非 APIPA 地址(169.254.x.x)
///// 6. 验证子网掩码：非全0，确保接口有有效网络配置
///// @return YES 表示当前存在活动的有线网络连接
//- (BOOL)isWiredNetworkActive {
//    // 使用 getifaddrs 枚举所有网络接口，返回接口链表头指针
//    struct ifaddrs *interfaces = NULL;
//    struct ifaddrs *temp_addr = NULL;
//    
//    // 调用失败直接返回 NO，无需后续判断
//    if (getifaddrs(&interfaces) != 0) {
//        return NO;
//    }
//    
//    // 遍历网络接口链表
//    temp_addr = interfaces;
//    while (temp_addr != NULL) {
//        // 仅检查 IPv4 接口（AF_INET），忽略 IPv6 和其他类型，不满足则跳过
//        if (temp_addr->ifa_addr->sa_family != AF_INET) {
//            temp_addr = temp_addr->ifa_next;
//            continue;
//        }
//        
//        NSString *ifname = [NSString stringWithUTF8String:temp_addr->ifa_name];
//        unsigned int flags = temp_addr->ifa_flags;
//        
//        // 检查接口标志：
//        // - IFF_UP: 接口已启用
//        // - IFF_RUNNING: 接口已连接并运行（网线已插入且链路已建立）
//        // 仅启用但未连接的接口不视为活动有线网络
//        if (!(flags & IFF_UP) || !(flags & IFF_RUNNING)) {
//            temp_addr = temp_addr->ifa_next;
//            continue;
//        }
//        
//        // 排除非物理网络接口：
//        // - lo*: 回环接口，本地通信使用
//        // - awdl*: AirDrop 专用接口，基于 WiFi Direct
//        // - p2p*: 点对点连接接口（如蓝牙共享）
//        // - utun*: VPN 隧道接口（如 WireGuard、IPsec）
//        if ([ifname hasPrefix:@"lo"] ||
//            [ifname hasPrefix:@"awdl"] ||
//            [ifname hasPrefix:@"p2p"] ||
//            [ifname hasPrefix:@"utun"]) {
//            temp_addr = temp_addr->ifa_next;
//            continue;
//        }
//        
//        // 有线网络接口特征：
//        // - en*: macOS/iOS 以太网接口（en0, en1 等）
//        // - bridge*: 桥接接口（模拟器常用 bridge100）
//        if (![ifname hasPrefix:@"en"] && ![ifname hasPrefix:@"bridge"]) {
//            temp_addr = temp_addr->ifa_next;
//            continue;
//        }
//        
//        // 关键判断：使用 IFF_WIRELESS 标志区分 WiFi 和有线
//        // IFF_WIRELESS 标志表示无线接口（WiFi），需要排除
//        if (flags & IFF_WIRELESS) {
//            temp_addr = temp_addr->ifa_next;
//            continue;
//        }
//        
//        // 获取接口的 IPv4 地址字符串
//        char addrBuf[INET_ADDRSTRLEN];
//        inet_ntop(AF_INET, &((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr, addrBuf, sizeof(addrBuf));
//        NSString *ipAddr = [NSString stringWithUTF8String:addrBuf];
//        
//        // 排除回环地址 127.0.0.1，确保接口有实际网络地址
//        if ([ipAddr isEqualToString:@"127.0.0.1"]) {
//            temp_addr = temp_addr->ifa_next;
//            continue;
//        }
//        
//        // 排除 APIPA 自动分配地址（169.254.x.x），此类地址表示接口未通过 DHCP 获取有效地址
//        if ([ipAddr hasPrefix:@"169.254."]) {
//            temp_addr = temp_addr->ifa_next;
//            continue;
//        }
//        
//        // 检查子网掩码是否有效（非全0），确保接口有有效的网络配置
//        if (!temp_addr->ifa_netmask) {
//            temp_addr = temp_addr->ifa_next;
//            continue;
//        }
//        
//        uint32_t netmaskValue = ((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr.s_addr;
//        // 子网掩码为全0表示未配置有效的子网
//        if (netmaskValue == 0) {
//            temp_addr = temp_addr->ifa_next;
//            continue;
//        }
//        
//        // 满足所有条件：有线接口、已启用且已连接、无 IFF_WIRELESS 标志、有有效网络配置
//        freeifaddrs(interfaces);
//        return YES;
//    }
//    
//    // 释放 getifaddrs 分配的内存，避免内存泄漏
//    freeifaddrs(interfaces);
//    
//    return NO;
//}
//
///// 启动网络状态监听
///// 可重复调用，已启动时重复调用无效
///// 
///// 监听启动流程：
///// 1. 检查网络可达性引用（reachabilityRef）是否有效
///// 2. 检查监听是否已启动（runningSchedule），避免重复启动
///// 3. 创建状态变化回调 Block，内部通过弱引用避免循环引用
///// 4. 设置 SCNetworkReachability 回调上下文，包含 Block 和保留/释放函数
///// 5. 将网络可达性引用加入主运行循环（kCFRunLoopCommonModes）
///// 
///// 监听启动后，网络状态变化会触发回调，最终通过三种方式通知监听者：
///// - Block 回调（通过 addObserver:statusChangeBlock: 添加）
///// - Selector 调用（通过 addObserver:selector: 添加）
///// - NSNotificationCenter 通知（JGSReachabilityStatusChangedNotification）
//- (void)startMonitor {
//    
//    // 检查网络可达性引用是否有效，无效则直接返回
//    if (!self.reachabilityRef) {
//        return;
//    }
//    
//    // 避免重复启动监听，runningSchedule 为 YES 表示已启动
//    if (self.runningSchedule) {
//        return;
//    }
//    
//    // 使用弱引用避免循环引用，在 Block 内部通过 JGSStrong 宏转换为强引用
//    // 确保 Block 执行时 self 仍然存在
//    JGSWeak(self);
//    JGSReachabilityStatusBlock callback = ^(void) {
//        
//        JGSStrong(self);
//        [self notifyReachabilityStatusChange];
//    };
//    
//    // 设置回调上下文，包含回调 Block、保留函数和释放函数
//    // 保留函数用于 Block_copy，释放函数用于 Block_release
//    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, JGSNetworkReachabilityRetainCallback, JGSNetworkReachabilityReleaseCallback, NULL};
//    
//    // 设置网络可达性回调函数，当网络状态变化时会触发此回调
//    SCNetworkReachabilitySetCallback(self.reachabilityRef, JGSNetworkReachabilityCallback, &context);
//    
//    // 将网络可达性引用加入主运行循环，开始监听网络状态变化
//    // kCFRunLoopCommonModes 包含 NSDefaultRunLoopMode 和 UITrackingRunLoopMode，
//    // 确保在 UI 交互和空闲状态下都能正常接收网络状态变化通知
//    _runningSchedule = SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef, CFRunLoopGetMain(), kCFRunLoopCommonModes);
//}
//
///// 停止网络状态监听
///// 将网络可达性引用从运行循环中移除，停止接收网络状态变化通知
///// 可重复调用，未启动时调用无效
///// 停止后，网络状态变化将不再触发回调、Selector 和 Notification 通知
//- (void)stopMonitor {
//    // 网络可达性引用无效或未启动监听，直接返回
//    if (!self.reachabilityRef || !self.runningSchedule) {
//        return;
//    }
//    
//    // 将网络可达性引用从主运行循环中移除，停止监听
//    // 返回值取反赋值给 runningSchedule：成功移除时返回 YES，取反后 runningSchedule 为 NO
//    _runningSchedule = !SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef, CFRunLoopGetMain(), kCFRunLoopCommonModes);
//}
//
///// 添加网络状态变化监听（Block 方式）
///// @param observer 监听接收者（弱引用）
///// @param block 状态变化回调 Block
//- (void)addObserver:(id)observer statusChangeBlock:(void (^)(JGSReachabilityStatus))block {
//    
//    if (observer && block) {
//        [self.statusBlocks setObject:block forKey:observer];
//    }
//    
//    // 自动启动监听，确保添加监听时网络状态监控已启动
//    [self startMonitor];
//}
//
///// 移除指定观察者的 Block 监听
///// @param observer 监听接收者
//- (void)removeStatusChangeBlockWithObserver:(id)observer {
//    
//    if (observer) {
//        [self.statusBlocks removeObjectForKey:observer];
//    }
//}
//
///// 添加网络状态变化监听（Selector 方式）
///// @param observer 监听接收者（弱引用）
///// @param selector 状态变化时执行的方法选择器
//- (void)addObserver:(id)observer selector:(SEL)selector {
//    
//    if (observer && selector) {
//        [self.statusSelectors setObject:NSStringFromSelector(selector) forKey:observer];
//    }
//    
//    // 自动启动监听
//    [self startMonitor];
//}
//
///// 移除指定观察者的 Selector 监听
///// @param observer 监听接收者
//- (void)removeSelectorWithObserver:(id)observer {
//    
//    if (observer) {
//        [self.statusSelectors removeObjectForKey:observer];
//    }
//}
//
///// 通知所有监听者网络状态变化
///// 通过三种方式通知监听者，确保所有注册的监听者都能收到网络状态变化的通知：
///// 1. Block 回调方式（通过 addObserver:statusChangeBlock: 添加）
///// 2. Selector 调用方式（通过 addObserver:selector: 添加），延迟到 runloop 结束后执行
///// 3. NotificationCenter 通知方式（JGSReachabilityStatusChangedNotification）
///// 
///// 注意事项：
///// - 使用 allObjects 获取容器快照，避免枚举过程中容器被修改导致异常
///// - Selector 调用使用 afterDelay:0，避免在回调中修改监听者容器导致的嵌套调用问题
///// - 通知中携带当前网络状态，可通过 JGSReachabilityNotificationStatusKey 从 userInfo 中获取
//- (void)notifyReachabilityStatusChange {
//    
//    // 1. Block 回调方式
//    // 使用 allObjects 获取快照，避免枚举过程中容器被修改
//    for (id obj in self.statusBlocks.objectEnumerator.allObjects) {
//        void (^block)(JGSReachabilityStatus status) = obj;
//        if (block) {
//            block(self.reachabilityStatus);
//        }
//    }
//    
//    // 2. Selector 调用方式
//    // 使用 afterDelay:0 将调用延迟到当前 runloop 结束后执行，避免嵌套调用问题
//    for (id obj in self.statusSelectors.keyEnumerator.allObjects) {
//        SEL selector = NSSelectorFromString([self.statusSelectors objectForKey:obj]);
//        if (selector) {
//            [obj performSelector:selector withObject:self afterDelay:0];
//        }
//    }
//    
//    // 3. NotificationCenter 通知方式
//    // 将当前网络状态封装在 userInfo 中发送通知，监听者可通过 JGSReachabilityNotificationStatusKey 获取状态值
//    [[NSNotificationCenter defaultCenter] postNotificationName:JGSReachabilityStatusChangedNotification 
//                                                        object:self 
//                                                      userInfo:@{JGSReachabilityNotificationStatusKey : @(self.reachabilityStatus)}];
//}
//
//#pragma mark - Getter
///// 获取蜂窝移动网络具体类型
///// 通过 CoreTelephony 框架获取当前无线接入技术，映射到对应的蜂窝网络类型
///// 无线接入技术标识（CTRadioAccessTechnology*）与网络类型的映射关系：
///// - 2G: GPRS、EDGE
///// - 3G: WCDMA、HSDPA、HSUPA、CDMA1x、CDMAEVDO(Rev0/A/B)、eHRPD
///// - 4G: LTE
///// - 5G: NRNSA（非独立组网）、NR（独立组网）- iOS 14.1+
///// @return 蜂窝网络状态枚举值（WWAN/GPRS/2G/3G/4G/5G）
//- (JGSReachabilityStatus)wwanNetworkStatus {
//    // 默认返回未知蜂窝网络类型
//    JGSReachabilityStatus status = JGSReachabilityStatusWWAN;
//    
//    // 使用 dispatch_once 确保映射字典只初始化一次，提升性能
//    static NSDictionary<NSString *, NSNumber *> *wwanInfoDict = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        // 创建无线接入技术标识到网络状态的映射表
//        // CoreTelephony 框架使用 CTRadioAccessTechnology* 常量标识不同的网络技术
//        NSMutableDictionary<NSString *, NSNumber *> *tmp = @{
//            // 2G 网络类型
//            CTRadioAccessTechnologyGPRS: @(JGSReachabilityStatusWWANGPRS), // GPRS（General Packet Radio Service）
//            CTRadioAccessTechnologyEdge: @(JGSReachabilityStatusWWAN2G),   // EDGE（Enhanced Data rates for GSM Evolution，2.75G）
//            // 3G 网络类型
//            CTRadioAccessTechnologyWCDMA: @(JGSReachabilityStatusWWAN3G),   // WCDMA（Wideband Code Division Multiple Access）
//            CTRadioAccessTechnologyHSDPA: @(JGSReachabilityStatusWWAN3G),   // HSDPA（High-Speed Downlink Packet Access，3.5G）
//            CTRadioAccessTechnologyHSUPA: @(JGSReachabilityStatusWWAN3G),   // HSUPA（High-Speed Uplink Packet Access，3.5G）
//            CTRadioAccessTechnologyCDMA1x: @(JGSReachabilityStatusWWAN3G),        // CDMA 1X（CDMA2000 第一阶段）
//            CTRadioAccessTechnologyCDMAEVDORev0: @(JGSReachabilityStatusWWAN3G),  // CDMA EVDO Rev.0
//            CTRadioAccessTechnologyCDMAEVDORevA: @(JGSReachabilityStatusWWAN3G),  // CDMA EVDO Rev.A
//            CTRadioAccessTechnologyCDMAEVDORevB: @(JGSReachabilityStatusWWAN3G),  // CDMA EVDO Rev.B
//            CTRadioAccessTechnologyeHRPD: @(JGSReachabilityStatusWWAN3G),         // eHRPD（Enhanced High Rate Packet Data，3.75G）
//            // 4G 网络类型
//            CTRadioAccessTechnologyLTE: @(JGSReachabilityStatusWWAN4G), // LTE（Long-Term Evolution）
//        }.mutableCopy;
//        
//        // iOS 14.1 及以上版本支持 5G 网络类型定义
//        // iOS 14.0 虽然引入了 5G，但缺少相关常量定义
//        if (@available(iOS 14.1, *)) {
//            [tmp addEntriesFromDictionary:@{
//                CTRadioAccessTechnologyNRNSA: @(JGSReachabilityStatusWWAN5G), // 5G NR 非独立组网（Non-Standalone）模式
//                CTRadioAccessTechnologyNR: @(JGSReachabilityStatusWWAN5G),    // 5G NR 独立组网（Standalone）模式
//            }];
//        }
//        
//        wwanInfoDict = tmp.copy;
//    });
//    
//    // 创建 CoreTelephony 网络信息对象，获取当前无线接入技术
//    // serviceCurrentRadioAccessTechnology 属性返回字典，key 为运营商标识（如 "00000"），
//    // value 为当前使用的无线接入技术标识（如 CTRadioAccessTechnologyLTE）
//    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
//    for (NSString *currentStatus in info.serviceCurrentRadioAccessTechnology.allValues) {
//        // 根据获取到的技术标识查找对应的网络类型
//        if (currentStatus.length > 0 && [wwanInfoDict.allKeys containsObject:currentStatus]) {
//            status = [wwanInfoDict[currentStatus] integerValue];
//            break;
//        }
//    }
//    
//    return status;
//}
//
///// 获取当前网络连接状态
///// 通过 SCNetworkReachabilityGetFlags 获取网络可达性标志位，
///// 结合 getifaddrs 枚举网络接口（模拟器），综合判断当前网络连接类型
///// 
///// 核心判断逻辑：
///// 1. 调用 SCNetworkReachabilityGetFlags 获取当前网络配置的标志位集合
///// 2. 解析标志位判断网络是否可达（isReachable）
///// 3. 判断是否需要用户干预（needsConnection、canConnectWithoutUserInteraction）
///// 4. 根据 kSCNetworkReachabilityFlagsIsWWAN 标志区分蜂窝网络和其他网络
///// 5. 模拟器环境下，通过枚举网络接口进一步区分有线网络和 WiFi
///// 
///// 网络可达性标志位说明：
///// - kSCNetworkReachabilityFlagsReachable (1<<1): 当前网络配置可连接到目标
///// - kSCNetworkReachabilityFlagsConnectionRequired (1<<2): 需要先建立连接过程
///// - kSCNetworkReachabilityFlagsConnectionOnTraffic (1<<3): 按需自动建立连接
///// - kSCNetworkReachabilityFlagsInterventionRequired (1<<4): 需要用户手动配置
///// - kSCNetworkReachabilityFlagsConnectionOnDemand (1<<5): 通过 CFSocketStream 自动建立连接
///// - kSCNetworkReachabilityFlagsIsWWAN (1<<18): 通过蜂窝移动网络连接（仅 iOS 真机）
///// 
///// @return 当前网络连接状态枚举值（NotReachable/ViaWiFi/ViaWWAN/ViaWired）
//- (JGSReachabilityStatus)reachabilityStatus {
//    // 获取网络可达性标志位，flags 代表对默认路由地址的可连接性，
//    // 包括是否需要网络连接、是否需要用户干预等信息
//    SCNetworkReachabilityFlags flags;
//    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags);
//    
//    // 获取标志位失败，返回未知状态
//    if (!didRetrieveFlags) {
//        return JGSReachabilityStatusUnknown;
//    }
//    
//    // 判断网络是否可达：标志位包含 Reachable 表示目标地址在当前网络配置下可达
//    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
//    if (!isReachable) {
//        return JGSReachabilityStatusUnreachable;
//    }
//    
//    // 判断是否需要主动建立连接：包含 ConnectionRequired 表示需要额外的连接过程
//    // 例如 VPN、拨号网络等需要手动或自动建立连接的场景
//    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
//    if (!needsConnection) {
//        // 无需额外连接，直接判断网络类型
//        return [self networkTypeForFlags:flags];
//    }
//    
//    // 判断是否可以自动建立连接，无需用户干预：
//    // - ConnectionOnDemand 或 ConnectionOnTraffic 表示系统可自动建立连接
//    // - 且没有设置 InterventionRequired（不需要用户手动配置）
//    BOOL canConnectAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) ||
//                                    ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
//    BOOL canConnectWithoutUserInteraction = (canConnectAutomatically &&
//                                             (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
//    
//    // 需要连接但无法自动连接（需用户手动配置），判定为不可达
//    if (!canConnectWithoutUserInteraction) {
//        return JGSReachabilityStatusUnreachable;
//    }
//    
//    // 可自动连接，判断具体网络类型
//    return [self networkTypeForFlags:flags];
//}
//
///// 根据网络可达性标志位判断网络类型
///// @param flags 网络可达性标志位集合
///// @return 网络类型枚举值（WiFi/WWAN/Wired）
//- (JGSReachabilityStatus)networkTypeForFlags:(SCNetworkReachabilityFlags)flags {
//    // 判断是否为蜂窝移动网络：kSCNetworkReachabilityFlagsIsWWAN 仅在 iOS 真机上有效，
//    // macOS 和 iOS 模拟器永远不会设置此标志
//    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
//        // 通过 CoreTelephony 获取具体蜂窝网络类型（GPRS/2G/3G/4G/5G）
//        return [self wwanNetworkStatus];
//    }
//    
//    // 默认假设为 WiFi 网络（真机上非蜂窝网络即为 WiFi）
//    JGSReachabilityStatus status = JGSReachabilityStatusWiFi;
//    
//#if TARGET_OS_SIMULATOR
//    // 模拟器环境下，通过枚举网络接口进一步区分有线和 WiFi
//    // 在 macOS/iOS 模拟器环境下，有线网络接口通常以 en/bridge 开头
//    if ([self isWiredNetworkActive]) {
//        status = JGSReachabilityStatusWired;
//    }
//#endif
//    
//    return status;
//}
//
///// 判断网络是否可连接
///// @return YES 表示网络可达，NO 表示网络不可达
//- (BOOL)reachable {
//    return self.reachabilityStatus != JGSReachabilityStatusUnreachable;
//}
//
///// 判断是否通过 WiFi 连接
///// @return YES 表示当前通过 WiFi 网络连接
//- (BOOL)reachableViaWiFi {
//    return self.reachabilityStatus == JGSReachabilityStatusWiFi;
//}
//
///// 判断是否通过蜂窝移动网络连接（仅 iOS 真机）
///// 蜂窝网络包含以下所有类型：WWAN、GPRS、2G、3G、4G、5G
///// @return YES 表示当前通过任意蜂窝移动网络连接
//- (BOOL)reachableViaWWAN {
//    switch (self.reachabilityStatus) {
//        case JGSReachabilityStatusWWAN:
//        case JGSReachabilityStatusWWANGPRS:
//        case JGSReachabilityStatusWWAN2G:
//        case JGSReachabilityStatusWWAN3G:
//        case JGSReachabilityStatusWWAN4G:
//        case JGSReachabilityStatusWWAN5G:
//            return YES;
//            break;
//            
//        case JGSReachabilityStatusUnknown:
//        case JGSReachabilityStatusUnreachable:
//        case JGSReachabilityStatusWiFi:
//        case JGSReachabilityStatusWired:
//            return NO;
//            break;
//    }
//}
//
///// 判断是否通过有线网络连接（macOS/iOS 模拟器）
///// @return YES 表示当前通过有线网络连接
//- (BOOL)reachableViaWired {
//    return self.reachabilityStatus == JGSReachabilityStatusWired;
//}
//
///// 获取网络连接类型的字符串描述
///// 将 JGSReachabilityStatus 枚举值转换为人类可读的字符串，便于日志输出和 UI 展示
///// 返回值说明：
///// - "NoNetwork": 网络不可达
///// - "WiFi": 通过 WiFi 网络连接
///// - "Wired": 通过有线网络连接（仅模拟器）
///// - "Mobile": 未知蜂窝网络类型
///// - "GPRS/2G/3G/4G/5G": 具体蜂窝网络技术类型
///// @return 网络状态字符串
//- (NSString *)reachabilityStatusString {
//    
//    // 使用 dispatch_once 确保映射字典只初始化一次，提升性能
//    static NSDictionary<NSNumber *, NSString *> *wwanInfoDict = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        // 创建 JGSWWANType 枚举值到网络类型字符串的映射表
//        wwanInfoDict = @{
//            @(JGSReachabilityStatusUnknown): @"Unknown",
//            @(JGSReachabilityStatusUnreachable): @"NoNetwork",
//            @(JGSReachabilityStatusWiFi): @"WiFi",
//            @(JGSReachabilityStatusWWAN): @"Mobile", // 未知蜂窝网络类型，返回通用描述
//            @(JGSReachabilityStatusWWANGPRS): @"GPRS",
//            @(JGSReachabilityStatusWWAN2G): @"2G",
//            @(JGSReachabilityStatusWWAN3G): @"3G",
//            @(JGSReachabilityStatusWWAN4G): @"4G",
//            @(JGSReachabilityStatusWWAN5G): @"5G",
//            @(JGSReachabilityStatusWired): @"Wired",
//        };
//    });
//    
//    // 根据当前蜂窝网络类型获取对应的字符串描述
//    JGSReachabilityStatus status = self.reachabilityStatus;
//    if ([wwanInfoDict.allKeys containsObject:@(status)]) {
//        return wwanInfoDict[@(status)];
//    }
//    // 无法识别的网络类型，返回通用蜂窝网络描述
//    return wwanInfoDict[@(JGSReachabilityStatusUnknown)];
//}
//
//@end
