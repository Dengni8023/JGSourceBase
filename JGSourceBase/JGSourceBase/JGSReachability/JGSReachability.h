//
//  JGSReachability.h
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/7/16.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///// 网络连接状态枚举
///// 表示当前设备的网络连接类型，支持 WiFi、蜂窝移动网络和有线网络（模拟器）
//typedef NS_ENUM(NSInteger, JGSReachabilityStatus) {
//    JGSReachabilityStatusUnknown = 0, /// 未知网络类型
//    JGSReachabilityStatusUnreachable, /// 网络不可达
//    JGSReachabilityStatusWiFi, /// 通过 WiFi 网络连接
//    JGSReachabilityStatusWWAN, /// 通过蜂窝移动网络连接（仅 iOS 真机），未知蜂窝移动网络时返回此值
//    JGSReachabilityStatusWWANGPRS, /// GPRS 网络（2G）
//    JGSReachabilityStatusWWAN2G, /// 2G 网络（EDGE 等）
//    JGSReachabilityStatusWWAN3G, /// 3G 网络（WCDMA、CDMA、HSDPA、HSUPA 等）
//    JGSReachabilityStatusWWAN4G, /// 4G 网络（LTE）
//    JGSReachabilityStatusWWAN5G, /// 5G 网络（NR/NRNSA）
//    JGSReachabilityStatusWired, /// 通过有线网络连接（macOS/iOS 模拟器）
//    
//    JGSReachabilityStatusNotReachable NS_ENUM_DEPRECATED(1_0, 4_0, 1_0, 4_0, "Replaced by JGSReachabilityStatusUnreachable") = JGSReachabilityStatusUnreachable,
//    JGSReachabilityStatusViaWiFi NS_ENUM_DEPRECATED(1_0, 4_0, 1_0, 4_0, "Replaced by JGSReachabilityStatusWiFi") = JGSReachabilityStatusWiFi,
//    JGSReachabilityStatusViaWWAN NS_ENUM_DEPRECATED(1_0, 4_0, 1_0, 4_0, "Replaced by JGSReachabilityStatusWWAN") = JGSReachabilityStatusWWAN,
//};

/// 网络状态变化通知名称
FOUNDATION_EXTERN NSNotificationName const JGSReachabilityStatusChangedNotification;

/// 网络状态通知键类型定义
typedef NSString *JGSReachabilityNotificationKey NS_EXTENSIBLE_STRING_ENUM;

/// 通知中携带网络状态的键名
FOUNDATION_EXTERN JGSReachabilityNotificationKey const JGSReachabilityNotificationStatusKey;

//@interface JGSReachability : NSObject
//
//@property (nonatomic, strong, class, readonly) JGSReachability *shared;
//
///// 当前网络连接类型（只读）
///// 内部通过 SCNetworkReachabilityGetFlags 获取网络可达性标志位，
///// 结合 getifaddrs 枚举网络接口（模拟器），综合判断当前网络连接类型
//@property (nonatomic, assign, readonly) JGSReachabilityStatus reachabilityStatus;
//
///// 网络是否可达（只读）
///// @return YES 表示网络可达（包括 WiFi、蜂窝、有线），NO 表示网络不可达
//@property (nonatomic, assign, readonly) BOOL reachable;
//
///// 是否通过 WiFi 连接（只读）
///// @return YES 表示当前通过 WiFi 网络连接，不包含有线网络
//@property (nonatomic, assign, readonly) BOOL reachableViaWiFi;
//
///// 是否通过蜂窝移动网络连接（只读，仅 iOS 真机）
///// 蜂窝网络包含以下所有类型：WWAN、GPRS、2G、3G、4G、5G
///// @return YES 表示当前通过任意蜂窝移动网络连接
//@property (nonatomic, assign, readonly) BOOL reachableViaWWAN;
//
///// 是否通过有线网络连接（只读，macOS/iOS 模拟器）
///// 通过枚举网络接口（getifaddrs）判断是否存在活动的有线网络接口
///// @return YES 表示当前通过有线网络连接
//@property (nonatomic, assign, readonly) BOOL reachableViaWired;
//
///// 网络连接类型的字符串描述（只读）
///// 将 JGSReachabilityStatus 枚举值转换为可读的字符串
///// @return 网络状态字符串，e.g. "NoNetwork", "WiFi", "Wired", "Mobile", "GPRS", "2G", "3G", "4G", "5G"
//@property (nonatomic, copy, readonly) NSString *reachabilityStatusString;
//
///// 获取单例实例
///// 全局唯一的网络可达性管理对象，使用 dispatch_once 保证线程安全
///// @return JGSReachability 单例对象
//+ (instancetype)sharedInstance DEPRECATED_MSG_ATTRIBUTE("Replace by + shared");
//
///// 获取单例实例
///// 全局唯一的网络可达性管理对象，使用 dispatch_once 保证线程安全
///// @return JGSReachability 单例对象
//+ (instancetype)shared;
//
///// 启动网络状态监听（全局调用）
///// 可重复调用，已启动时重复调用无效
///// 监听启动后，网络状态变化会通过三种方式通知：
///// 1. Block 回调（通过 addObserver:statusChangeBlock: 添加）
///// 2. Selector 调用（通过 addObserver:selector: 添加）
///// 3. NSNotificationCenter 通知（JGSReachabilityStatusChangedNotification）
//- (void)startMonitor;
//
///// 添加网络状态变化监听（Block 方式）
///// 可添加多个监听者，内部使用 NSMapTable 弱引用持有 observer，防止循环引用
///// 添加后会自动调用 startMonitor 启动监听
///// @param observer 监听接收者（弱引用，释放时自动移除）
///// @param block 状态变化时的回调 Block，传入当前网络状态
//- (void)addObserver:(id)observer statusChangeBlock:(nullable void(^)(JGSReachabilityStatus status))block;
//
///// 移除指定观察者的 Block 监听
///// 非必需调用，observer 内存释放时会自动从 NSMapTable 中移除
///// @param observer 监听接收者
//- (void)removeStatusChangeBlockWithObserver:(id)observer;
//
///// 添加网络状态变化监听（Selector 方式）
///// 可添加多个监听者，内部使用 NSMapTable 弱引用持有 observer
///// selector 定义规则：
///// - 不带参数或带单个可选参数，参数类型为 JGSReachability
///// - 定义多个参数时仅第一个参数有效
///// 添加后会自动调用 startMonitor 启动监听
///// @param observer 监听接收者（弱引用，释放时自动移除）
///// @param selector 状态变化时执行的方法选择器
//- (void)addObserver:(id)observer selector:(SEL)selector;
//
///// 移除指定观察者的 Selector 监听
///// 非必需调用，observer 内存释放时会自动从 NSMapTable 中移除
///// @param observer 监听接收者
//- (void)removeSelectorWithObserver:(id)observer;
//
//@end

NS_ASSUME_NONNULL_END
