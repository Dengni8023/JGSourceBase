//
//  JGSLogFunction.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSLogFunction.h"
#import <sys/time.h>
#import <sys/uio.h>

FOUNDATION_EXTERN NSDictionary *JGSLogLevelMap(void) {
    
    static NSDictionary *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = @{
            // Mac control+command+space 弹出emoji选择
            @(JGSLogLevelDebug): @{@"emoji": @"🛠", @"level": @"Debug"},
            @(JGSLogLevelInfo): @{@"emoji": @"ℹ️", @"level": @"Info"},
            @(JGSLogLevelWarn): @{@"emoji": @"⚠️", @"level": @"Warn"},
            @(JGSLogLevelError): @{@"emoji": @"❌", @"level": @"Error"},
        };
    });
    return instance;
}

FOUNDATION_EXTERN void JGSLogWithFormat(NSString *format, ...) {
    
    // 使用print代替NSLog，避免因屏蔽部分系统及log导致日志无法输出
    // 如屏蔽调试控制台输出的系统提示信息，在
    // Edit Scheme -> Run -> Arguments -> Environment Variables 添加: OS_ACTIVITY_MODE: disable
    // 此时使用的NSLog日志也不会输出
    va_list L;
    va_start(L, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:L];
    va_end(L);
    
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
    
    NSString *logMsg = [NSString stringWithFormat:@"%s.%.6d%s %@[%d] %@\n", dateTime, microseconds, timeZone, [NSProcessInfo processInfo].processName, (UInt32)getpid(), message];
    NSUInteger msgLength = [logMsg lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (msgLength > 4 * 1024) {
        
        // 数据量较大时writev性能较低
        fprintf(stderr, "%s\n", logMsg.UTF8String);
        return;
    }
    
    char msgStack[msgLength + 1];
    BOOL isUTF8 = [logMsg getCString:msgStack maxLength:(msgLength + 1) encoding:NSUTF8StringEncoding];
    if (!isUTF8) {
        return;
    }
    
    struct iovec msgBuffer[1];
    msgBuffer[0].iov_base = msgStack;
    msgBuffer[0].iov_len = msgLength;
    writev(STDERR_FILENO, msgBuffer, 1);
}

JGSLogMode JGSEnableLogMode = JGSLogModeNone; //默认不输出日志
FOUNDATION_EXTERN void JGSEnableLogWithMode(JGSLogMode mode) {
    JGSEnableLogMode = mode;
}

JGSLogLevel JGSConsoleLogLevel = JGSLogLevelDebug; //默认输出所有级别日志
FOUNDATION_EXTERN void JGSConsoleLogWithLevel(JGSLogLevel level) {
    JGSConsoleLogLevel = level;
}

@implementation JGSLogFunction

@end
