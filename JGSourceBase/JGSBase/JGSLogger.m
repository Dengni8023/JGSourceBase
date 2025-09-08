//
//  JGSLogger.m
//  JGSourceBase
//
//  Created by 梅继高 on 2025/7/7.
//  Copyright © 2025 MeiJiGao. All rights reserved.
//

#import "JGSLogger.h"
#import <sys/time.h>
//#import <sys/uio.h>
#import "JGSLogger+Private.h"

FOUNDATION_EXTERN void JGSLogWithLog(JGSLogMode mode, JGSLogLevel level, const char *filePath, const char *funcName, NSInteger lineNum, NSString *log) {
    
    // 判断log开关及log日志级别设置
    if (mode == JGSLogModeNone || level < JGSLogger.level) {
        return;
    }
    
    // 日志长度、省略处理
    NSInteger logLimit = JGSLogger.lengthLimit > 0 ? MAX(JGSLogger.lengthLimit, JGSLogger.lengthMin) : 0;
    if (logLimit > 0 && log.length > logLimit) {
        switch (JGSLogger.truncating) {
            case JGSLogTruncatingMiddle: {
                NSString *logHead = [log substringToIndex:logLimit / 2];
                NSString *logTail = [log substringFromIndex:log.length - logLimit / 2];
                log = [NSString stringWithFormat:@"%@\n\n\t\t...\n\n\t\t%@ (log count: %@)", logHead, logTail, @(log.length)];
            }
            break;
            
            case JGSLogTruncatingHead: {
                NSString *logTail = [log substringFromIndex:log.length - logLimit];
                log = [NSString stringWithFormat:@"...\n\n\t\t%@ (log count: %@)", logTail, @(log.length)];
            }
                break;
            
            case JGSLogTruncatingTail: {
                NSString *logHead = [log substringToIndex:logLimit];
                log = [NSString stringWithFormat:@"%@\n\n\t\t... (log count: %@)", logHead, @(log.length)];
            }
                break;
        }
    }
    
    // 日志级别
    JGSLogLevelDetailInfo *lvInfo = [JGSLogger logDetailInfo:level];
    NSString *lvStr = [NSString stringWithFormat:@"%@ [%@-OC]", lvInfo.emoji, lvInfo.level];
    
    // 执行输出日志方法所在文件、方法、行号
    if (mode == JGSLogModeFunc) {
        
        // 对方法名进行处理
        // Log长度小于最小限长是时不分行显示，否则 log 内容换行显示
        log = [NSString stringWithFormat:@"%s Line: %@%@%@", funcName, @(lineNum), log.length > JGSLogger.lengthMin ? @"\n" : @" ", log];
    }
    else if (mode == JGSLogModeFile) {
        
        // 对文件名、方法名
        NSString *fileName = [NSString stringWithCString:filePath encoding:NSUTF8StringEncoding].lastPathComponent;
        // Log长度小于最小限长是时不分行显示，否则 log 内容换行显示
        log = [NSString stringWithFormat:@"%@ %s Line: %@%@%@", fileName, funcName, @(lineNum), log.length > JGSLogger.lengthMin ? @"\n" : @" ", log];
    }
    
    // 使用NSLog输出
    if (JGSLogger.useNSLog) {
        NSLog(@"%@ %s", lvStr, [log cStringUsingEncoding:NSUTF8StringEncoding]);
        return;
    }
    
    // 使用print代替NSLog，避免因屏蔽部分系统及log导致日志无法输出
    // 如屏蔽调试控制台输出的系统提示信息，在
    // Edit Scheme -> Run -> Arguments -> Environment Variables 添加: OS_ACTIVITY_MODE: disable
    // 此时使用的NSLog日志也不会输出
    
    // 处理类似NSLog输出的日志头
    // 2021-03-11 20:25:42.949957+0800 JGSourceBaseDemo[25823:826858]
    // 年-月-日 时:分:秒.微秒+时区偏移 BundleExecutable[pid:xx]
    struct timeval now;
    gettimeofday(&now, NULL);
    time_t seconds = now.tv_sec;
    struct tm *timeinfo = localtime(&seconds);
    useconds_t microseconds = now.tv_usec;
    
    // 输出日期时间 2021-03-11 20:23:39 长度为 19，最短定义为20
    char dateTime[32];
    strftime(dateTime, 32, "%Y-%m-%d %H:%M:%S", timeinfo);
    
    // 输出时区 +0800 长度为5，最短定义为6
    char timeZone[8];
    strftime(timeZone, 8, "%z", timeinfo);
    
    // 参考：https://www.cnblogs.com/itmarsung/p/14901052.html
    // 格式化时间字符串
    NSString *formatedDateTimeStr = [NSString stringWithFormat:@"%s.%.6d%s", dateTime, microseconds, timeZone];
    // 运行进程信息，NSLog使用私有方法GSPrivateThreadID()获取threadID，此处无法获取，仅使用pid
    NSString *prcessInfo = [NSString stringWithFormat:@"%@[%@]", [[NSProcessInfo processInfo] processName], @(getpid())];
    NSString *logMsg = [NSString stringWithFormat:@"%@ %@ %@ %@", formatedDateTimeStr, prcessInfo, lvStr, log];
    
    //NSUInteger msgLength = [logMsg lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    //if (msgLength > 4 * 1024) {
        
        // 数据量较大时writev性能较低
        // OC 中 printf 需添加换行
        fprintf(stderr, "%s\n", logMsg.UTF8String);
    //    return;
    //}
    //
    //char msgStack[msgLength + 1];
    //BOOL isUTF8 = [logMsg getCString:msgStack maxLength:(msgLength + 1) encoding:NSUTF8StringEncoding];
    //if (!isUTF8) {
    //    return;
    //}
    //
    //struct iovec msgBuffer[1];
    //msgBuffer[0].iov_base = msgStack;
    //msgBuffer[0].iov_len = msgLength;
    //writev(STDERR_FILENO, msgBuffer, 1);
}

FOUNDATION_EXTERN void JGSLogWithArgs(JGSLogMode mode, JGSLogLevel level, const char *filePath, const char *funcName, NSInteger lineNum, NSString *format, ...) {
    
    // 为避免表达式参数 表达式未执行情况，是否输出 Log 判断放到构建日志内容之后
    // 输出 Log 前构建 Log 内容步骤不可省
    va_list varList;
    va_start(varList, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:varList];
    va_end(varList);
    
    // 日志格式化打印
    JGSLogWithLog(mode, level, filePath, funcName, lineNum, log);
}

FOUNDATION_EXTERN void JGSLogWithArgsOnly(const char *filePath, const char *funcName, NSInteger lineNum, NSString *format, ...) {
    
    // 为避免表达式参数 表达式未执行情况，是否输出 Log 判断放到构建日志内容之后
    // 输出 Log 前构建 Log 内容步骤不可省
    va_list varList;
    va_start(varList, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:varList];
    va_end(varList);
    
    // 日志格式化打印
    JGSLogWithLog(JGSLogger.mode, JGSLogLevelDebug, filePath, funcName, lineNum, log);
}

FOUNDATION_EXTERN void JGSLogWithArgsLevel(JGSLogLevel level, const char *filePath, const char *funcName, NSInteger lineNum, NSString *format, ...) {
    
    // 为避免表达式参数 表达式未执行情况，是否输出 Log 判断放到构建日志内容之后
    // 输出 Log 前构建 Log 内容步骤不可省
    va_list varList;
    va_start(varList, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:varList];
    va_end(varList);
    
    // 日志格式化打印
    JGSLogWithLog(JGSLogger.mode, level, filePath, funcName, lineNum, log);
}

FOUNDATION_EXTERN void JGSLogWithArgsMode(JGSLogMode mode, const char *filePath, const char *funcName, NSInteger lineNum, NSString *format, ...) {
    
    // 为避免表达式参数 表达式未执行情况，是否输出 Log 判断放到构建日志内容之后
    // 输出 Log 前构建 Log 内容步骤不可省
    va_list varList;
    va_start(varList, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:varList];
    va_end(varList);
    
    // 日志格式化打印
    JGSLogWithLog(mode, JGSLogLevelDebug, filePath, funcName, lineNum, log);
}

FOUNDATION_EXTERN void JGSEnableLogWithMode(JGSLogMode mode) {
    [JGSLogger enableLogWithMode:mode level:JGSLogger.level useNSLog:JGSLogger.useNSLog lengthLimit:JGSLogger.lengthLimit truncating:JGSLogger.truncating];
}

FOUNDATION_EXTERN void JGSConsoleLogWithLevel(JGSLogLevel level) {
    [JGSLogger enableLogWithMode:JGSLogger.mode level:level useNSLog:JGSLogger.useNSLog lengthLimit:JGSLogger.lengthLimit truncating:JGSLogger.truncating];
}

FOUNDATION_EXTERN void JGSConsoleLogWithNSLog(BOOL useNSLog) {
    [JGSLogger enableLogWithMode:JGSLogger.mode level:JGSLogger.level useNSLog:useNSLog lengthLimit:JGSLogger.lengthLimit truncating:JGSLogger.truncating];
}

FOUNDATION_EXTERN void JGSConsoleLogWithLimitAndTruncating(NSInteger limit, JGSLogTruncating truncating) {
    [JGSLogger enableLogWithMode:JGSLogger.mode level:JGSLogger.level useNSLog:JGSLogger.useNSLog lengthLimit:limit truncating:truncating];
}

@implementation JGSLogFunction

+ (void)enableLog:(BOOL)enable {
    [JGSLogger setEnableDebug:enable];
}

+ (BOOL)isLogEnabled {
    return [JGSLogger enableDebug];
}

@end
