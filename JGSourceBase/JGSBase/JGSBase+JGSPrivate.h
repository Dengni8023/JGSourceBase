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

@interface JGSBaseUtils (JGSPrivate)

@end

/// 是否开启内部调试日志，默认不开启打印日志
FOUNDATION_EXTERN BOOL JGSPrivateLogEnable;
#define JGSPrivateLogWithModeLevel(level, fmt, ...) {\
    if (JGSPrivateLogEnable) { \
        NSDictionary *map = JGSLogLevelMap()[@(level)]; \
        NSString *lvStr = [NSString stringWithFormat:@"%@ [%@]", map[@"emoji"], map[@"level"]]; \
        JGSLogWithFormat((@"%@ %s Line: %@ " fmt ""), lvStr, __PRETTY_FUNCTION__, @(__LINE__), ##__VA_ARGS__); \
    } \
}

#define JGSPrivateLog(fmt, ...)     JGSPrivateLogD(fmt, ##__VA_ARGS__)
#define JGSPrivateLogD(fmt, ...)    JGSPrivateLogWithModeLevel(JGSLogLevelDebug, fmt, ##__VA_ARGS__)
#define JGSPrivateLogI(fmt, ...)    JGSPrivateLogWithModeLevel(JGSLogLevelInfo, fmt, ##__VA_ARGS__)
#define JGSPrivateLogW(fmt, ...)    JGSPrivateLogWithModeLevel(JGSLogLevelWarn, fmt, ##__VA_ARGS__)
#define JGSPrivateLogE(fmt, ...)    JGSPrivateLogWithModeLevel(JGSLogLevelError, fmt, ##__VA_ARGS__)

@interface JGSLogFunction (JGSPrivate)

@end

NS_ASSUME_NONNULL_END
