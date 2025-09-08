//
//  JGSLogger+Private.h
//  JGSourceBase
//
//  Created by 梅继高 on 2025/7/7.
//  Copyright © 2025 MeiJiGao. All rights reserved.
//

#import "JGSLogger.h"
#if __has_include(<JGSourceBase/JGSBase.h>)
#import <JGSourceBase/JGSBase.h>
#import <JGSourceBase/JGSourceBase-Swift.h>
#else
#import "JGSBase.h"
#import "JGSourceBase-Swift"
#endif

NS_ASSUME_NONNULL_BEGIN

#define JGSPrivateLogWithModeLevel(mode, level, fmt, ...) JGSLogWithArgs(mode, level, __FILE__, __PRETTY_FUNCTION__, __LINE__, @"" fmt "", ## __VA_ARGS__)
#define JGSPrivateLogWithLevel(level, fmt, ...) { \
    JGSPrivateLogWithModeLevel(JGSLogger.enableDebug ? JGSLogModeFunc : JGSLogModeNone, level, fmt, ## __VA_ARGS__); \
}

#define JGSPrivateLog(fmt, ...)  JGSPrivateLogD(fmt, ## __VA_ARGS__)
#define JGSPrivateLogD(fmt, ...) JGSPrivateLogWithLevel(JGSLogLevelDebug, fmt, ## __VA_ARGS__)
#define JGSPrivateLogI(fmt, ...) JGSPrivateLogWithLevel(JGSLogLevelInfo, fmt, ## __VA_ARGS__)
#define JGSPrivateLogW(fmt, ...) JGSPrivateLogWithLevel(JGSLogLevelWarn, fmt, ## __VA_ARGS__)
#define JGSPrivateLogE(fmt, ...) JGSPrivateLogWithLevel(JGSLogLevelError, fmt, ## __VA_ARGS__)

NS_ASSUME_NONNULL_END
