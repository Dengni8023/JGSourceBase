//
//  JGSBase+JGSPrivate.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/6/7.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#if __has_include(<JGSourceBase/JGSBase.h>)
#import <JGSourceBase/JGSBase.h>
#else
#import "JGSBase.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 是否开启内部调试日志，默认不开启打印日志
FOUNDATION_EXTERN BOOL JGSPrivateLogEnable;
#define JGSPrivateLogWithModeLevel(mode, level, fmt, ...) JGSLogWithArgs(mode, level, __FILE__, __PRETTY_FUNCTION__, __LINE__, @"" fmt "", ## __VA_ARGS__)
#define JGSPrivateLogWithLevel(level, fmt, ...) { \
    JGSLogMode mode = JGSPrivateLogEnable ? (JGSEnableLogMode != JGSLogModeNone ? JGSEnableLogMode : JGSLogModeFunc) : JGSLogModeNone; \
    JGSPrivateLogWithModeLevel(mode, level, fmt, ## __VA_ARGS__); \
}

#define JGSPrivateLog(fmt, ...)  JGSPrivateLogD(fmt, ## __VA_ARGS__)
#define JGSPrivateLogD(fmt, ...) JGSPrivateLogWithLevel(JGSLogLevelDebug, fmt, ## __VA_ARGS__)
#define JGSPrivateLogI(fmt, ...) JGSPrivateLogWithLevel(JGSLogLevelInfo, fmt, ## __VA_ARGS__)
#define JGSPrivateLogW(fmt, ...) JGSPrivateLogWithLevel(JGSLogLevelWarn, fmt, ## __VA_ARGS__)
#define JGSPrivateLogE(fmt, ...) JGSPrivateLogWithLevel(JGSLogLevelError, fmt, ## __VA_ARGS__)

@interface JGSLogFunction (JGSPrivate)

@end

// 临时存储文件路径文件夹
FOUNDATION_EXTERN NSString * const JGSTemporaryFileSavedDirectory(void);
// 永久存储文件路径文件夹
FOUNDATION_EXTERN NSString * const JGSPermanentFileSavedDirectory(void);

NS_ASSUME_NONNULL_END
