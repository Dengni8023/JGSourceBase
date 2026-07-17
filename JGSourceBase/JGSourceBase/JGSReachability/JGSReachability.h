//
//  JGSReachability.h
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/7/16.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 网络状态变化通知名称
FOUNDATION_EXTERN NSNotificationName const JGSReachabilityStatusChangedNotification;

/// 网络状态通知键类型定义
typedef NSString *JGSReachabilityNotificationKey NS_EXTENSIBLE_STRING_ENUM;

/// 通知中携带网络状态的键名
FOUNDATION_EXTERN JGSReachabilityNotificationKey const JGSReachabilityNotificationStatusKey;

NS_ASSUME_NONNULL_END
