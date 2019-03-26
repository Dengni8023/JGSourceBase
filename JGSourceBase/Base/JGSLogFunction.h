//
//  JGSLogFunction.h
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Log
typedef NS_ENUM(NSInteger, JGSLogMode) {
    JGSLogModeNone = 0, // 不打印日志
    JGSLogModeLog, // 仅打印日志内容
    JGSLogModeFunc, // 打印日志所在方法名、行号、日志内容
    JGSLogModePretty, // 打印日志所在方法名、行号，各部分分行显示
    JGSLogModeFile // 打印文件名、方法名、行号、日志内容，各部分分行显示
};

// LOG
#define JGSLogOnly(fmt, ...)     NSLog((@"" fmt ""), ##__VA_ARGS__)
#define JGSLogFunc(fmt, ...)     NSLog((@"%s Line: %@ " fmt ""), __PRETTY_FUNCTION__, @(__LINE__), ##__VA_ARGS__)
#define JGSLogPretty(fmt, ...)   NSLog((@"\nFunc:\t%s\nLine:\t%@\n" fmt ""), __PRETTY_FUNCTION__, @(__LINE__), ##__VA_ARGS__)
#define JGSLogFile(fmt, ...)     NSLog((@"\nFile:\t%@\nFunc:\t%s\nLine:\t%@\n" fmt ""), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, @(__LINE__), ##__VA_ARGS__)

#define JGSLog(fmt, ...) {\
    switch (JGSEnableLogMode) {\
        case JGSLogModeLog:\
            JGSLogOnly(fmt, ##__VA_ARGS__);\
            break;\
        case JGSLogModeFunc:\
            JGSLogFunc(fmt, ##__VA_ARGS__);\
            break;\
        case JGSLogModePretty:\
            JGSLogPretty(fmt, ##__VA_ARGS__);\
            break;\
        case JGSLogModeFile:\
            JGSLogFile(fmt, ##__VA_ARGS__);\
            break;\
        case JGSLogModeNone:\
            break;\
    }\
}
#define JGSLogInfo(fmt, ...)     JGSLog(@"<Info> " fmt, ##__VA_ARGS__)
#define JGSLogWarning(fmt, ...)  JGSLog(@"<Warning> " fmt, ##__VA_ARGS__)
#define JGSLogError(fmt, ...)    JGSLog(@"<Error> " fmt, ##__VA_ARGS__)

// Logger
#pragma mark - Logger
/** 日志输出模式，默认 JGSLogModeNone 不输出日志 */
FOUNDATION_EXTERN JGSLogMode JGSEnableLogMode;

/** 日志输出模式，默认 JGSLogModeNone 不输出日志 */
FOUNDATION_EXTERN void JGSEnableLogWithMode(JGSLogMode mode);

@interface JGSLogFunction : NSObject

@end

NS_ASSUME_NONNULL_END
