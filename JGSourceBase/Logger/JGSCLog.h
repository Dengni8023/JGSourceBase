//
//  JGSCLog.h
//  JGSourceBase
//
//  Created by 梅继高 on 2018/6/11.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Log
typedef NS_ENUM(NSInteger, JGSCLogMode) {
    JGSCLogModeNone = 0, // 不打印日志
    JGSCLogModeLog, // 仅打印日志内容
    JGSCLogModeFunc, // 打印日志所在方法名、行号、日志内容
    JGSCLogModePretty, // 打印日志所在方法名、行号，各部分分行显示
    JGSCLogModeFile // 打印文件名、方法名、行号、日志内容，各部分分行显示
};

/** 日志输出模式，默认 JGSCLogModeNone 不输出日志 */
FOUNDATION_EXTERN JGSCLogMode JGSCEnableLogMode;

/** 日志输出模式，默认 JGSCLogModeNone 不输出日志 */
FOUNDATION_EXTERN void JGSCEnableLogWithMode(JGSCLogMode mode);

// LOG
#define JGSCLogOnly(fmt, ...)     NSLog((@"" fmt ""), ##__VA_ARGS__)
#define JGSCLogFunc(fmt, ...)     NSLog((@"%s Line: %@ " fmt ""), __PRETTY_FUNCTION__, @(__LINE__), ##__VA_ARGS__)
#define JGSCLogPretty(fmt, ...)   NSLog((@"\nFunc:\t%s\nLine:\t%@\n" fmt ""), __PRETTY_FUNCTION__, @(__LINE__), ##__VA_ARGS__)
#define JGSCLogFile(fmt, ...)     NSLog((@"\nFile:\t%@\nFunc:\t%s\nLine:\t%@\n" fmt ""), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, @(__LINE__), ##__VA_ARGS__)

#define JGSCLog(fmt, ...) {\
    switch (JGSCEnableLogMode) {\
        case JGSCLogModeLog:\
            JGSCLogOnly(fmt, ##__VA_ARGS__);\
            break;\
        case JGSCLogModeFunc:\
            JGSCLogFunc(fmt, ##__VA_ARGS__);\
            break;\
        case JGSCLogModePretty:\
            JGSCLogPretty(fmt, ##__VA_ARGS__);\
            break;\
        case JGSCLogModeFile:\
            JGSCLogFile(fmt, ##__VA_ARGS__);\
            break;\
        case JGSCLogModeNone:\
            break;\
    }\
}

#define JGSCLogInfo(fmt, ...)     JGSCLog(@"<Info> " fmt, ##__VA_ARGS__)
#define JGSCLogWarning(fmt, ...)  JGSCLog(@"<Warning> " fmt, ##__VA_ARGS__)
#define JGSCLogError(fmt, ...)    JGSCLog(@"<Error> " fmt, ##__VA_ARGS__)
