//
//  JGSReachability.h
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef JGS_Reachability
#define JGS_Reachability
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 * 网络连接类型
 */
typedef NS_ENUM(NSInteger, JGSReachabilityStatus) {
    JGSReachabilityStatusNotReachable = 1, // 不可连接
    JGSReachabilityStatusViaWiFi, // WiFi
    JGSReachabilityStatusViaWWAN, // 蜂窝移动网络
};

/**
 * 蜂窝移动网络类型
 */
typedef NS_ENUM(NSInteger, JGSWWANType) {
    JGSWWANTypeUnknown = 201,
    JGSWWANTypeGPRS, // GPRS
    JGSWWANType2G, // 2G
    JGSWWANType3G, // 3G
    JGSWWANType4G, // 4G
    JGSWWANType5G, // 5G
};

typedef void (^JGSReachabilityStatusChangeBlock)(JGSReachabilityStatus status);

FOUNDATION_EXTERN NSNotificationName const JGSReachabilityStatusChangedNotification;

typedef NSString *JGSReachabilityNotificationKey NS_EXTENSIBLE_STRING_ENUM;
FOUNDATION_EXTERN JGSReachabilityNotificationKey const JGSReachabilityNotificationStatusKey;

@interface JGSReachability : NSObject

/** 网络连接类型 */
@property (nonatomic, assign, readonly) JGSReachabilityStatus reachabilityStatus;

/** 网络是否可连接 */
@property (nonatomic, assign, readonly) BOOL reachable;

/** 是否WiFi网络 */
@property (nonatomic, assign, readonly) BOOL reachableViaWiFi;

/** 是否为蜂窝移动网络 */
@property (nonatomic, assign, readonly) BOOL reachableViaWWAN;

/** 蜂窝移动网络状态 */
@property (nonatomic, assign, readonly) JGSWWANType WWANType;

/** 网络连接类型描述，eg: NoNetwork, WiFi, Mobile, GPRS, 2G, 3G, 4G */
@property (nonatomic, copy, readonly) NSString *reachabilityStatusString;

+ (instancetype)sharedInstance;

/**
 * 全局调用，可重复调用，已启动时重复调用无效
 */
- (void)startMonitor;

/**
 状态变化监听处理，可添加多个监听者，注意block内存问题
 
 @param observer 监听接收者
 @param block 监听处理block
 */
- (void)addObserver:(id)observer statusChangeBlock:(nullable JGSReachabilityStatusChangeBlock)block;

/**
 移除状态监听block，非必需
 addStatusObserver:statusChangeBlock: 调用时block内部不存在内存问题时observer内存释放时会自动移除；
 addStatusObserver:statusChangeBlock: 调用时block内部存在内存问题时observer内存释放时必须手动调用本接口移除监听
 
 @param observer 监听接收者
 */
- (void)removeStatusChangeBlockWithObserver:(id)observer;

/**
 状态变化监听处理，可添加多个监听者
 selector定义带单个可选参数，执行时参数类型 JGSReachability
 selector定义多个参数执行时只第一参数有效，其他参数无效
 
 @param observer 监听接收者
 @param selector 监听处理selector
 */
- (void)addObserver:(id)observer selector:(SEL)selector;

/**
 移除状态监听selector，非必需，observer内存释放时会自动移除
 
 @param observer 监听接收者
 */
- (void)removeSelectorWithObserver:(id)observer;

@end

NS_ASSUME_NONNULL_END
