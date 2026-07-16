//
//  JGSLogger+Private.h
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/18.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import "JGSLogger.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN void JGSDebugOutputLog(NSInteger level, const char *file, const char *funcName, NSInteger lineNum, NSString *format, ...) NS_FORMAT_FUNCTION(5, 6);
FOUNDATION_EXTERN void JGSOutputLog(NSInteger mode, NSInteger level, const char *file, const char *funcName, NSInteger lineNum, NSString *log);

#define JGSDebugLogWithModeLevel(mode, level, fmt, ...) JGSOutputLog(mode, level, __FILE_NAME__, __PRETTY_FUNCTION__, __LINE__, @"" fmt "", ## __VA_ARGS__);
#define JGSDebugLogWithLevel(level, fmt, ...) { \
    JGSDebugOutputLog(level, __FILE_NAME__, __PRETTY_FUNCTION__, __LINE__, @"" fmt "", ## __VA_ARGS__); \
}

#define JGSDebugLog(fmt, ...)  JGSDebugLogD(fmt, ## __VA_ARGS__)
#define JGSDebugLogD(fmt, ...) JGSDebugLogWithLevel(0 /*JGSLogLevelDebug*/, fmt, ## __VA_ARGS__)
#define JGSDebugLogI(fmt, ...) JGSDebugLogWithLevel(1 /*JGSLogLevelInfo*/, fmt, ## __VA_ARGS__)
#define JGSDebugLogW(fmt, ...) JGSDebugLogWithLevel(2 /*JGSLogLevelWarn*/, fmt, ## __VA_ARGS__)
#define JGSDebugLogE(fmt, ...) JGSDebugLogWithLevel(3 /*JGSLogLevelError*/, fmt, ## __VA_ARGS__)

NS_ASSUME_NONNULL_END
