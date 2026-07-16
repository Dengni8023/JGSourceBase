//
//  JGSLogger.m
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/18.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import "JGSLogger.h"
#if __has_include(<JGSourceBase/JGSourceBase-Swift.h>)
#import <JGSourceBase/JGSourceBase-Swift.h>
#elif __has_include("JGSourceBase-Swift.h")
#import "JGSourceBase-Swift.h"
#endif
#import "JGSLogger+Private.h"

/**
 * 可变参数多层传递处理，可能导致日志内部的部分内容到最终构建日志时内存被释放，例：dfd,
 * JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
 * 因此，每个可变参数方法，先将可变参数构建成日志，而不是将可变参数继续往下传递
 */

void JGSLogWithArgs(JGSLogMode mode, JGSLogLevel level, const char *file, const char *funcName, NSInteger lineNum, NSString *format, ...) {
    
    // 对 mode 和 level 进行边界检查，确保值在有效范围内
    JGSLogMode modeVal = MIN(JGSLogModeFile, MAX(mode, JGSLogModeNone));
    JGSLogLevel levelVal = MIN(JGSLogLevelError, MAX(level, JGSLogLevelDebug));
    
    // 使用可变参数列表格式化日志字符串
    va_list varList;
    va_start(varList, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:varList];
    va_end(varList);
    
    // 将格式化后的日志传递给核心输出函数
    JGSOutputLog(modeVal, levelVal, file, funcName, lineNum, log);
}

void JGSLogWithArgsOnly(const char *file, const char *funcName, NSInteger lineNum, NSString *format, ...) {
    
    // 使用可变参数列表格式化日志字符串
    va_list varList;
    va_start(varList, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:varList];
    va_end(varList);
    
    // 使用全局配置的日志模式和DEBUG级别输出日志
    JGSOutputLog(JGSLogger.mode, JGSLogLevelDebug, file, funcName, lineNum, log);
}

void JGSLogWithArgsLevel(JGSLogLevel level, const char *file, const char *funcName, NSInteger lineNum, NSString *format, ...) {
    
    // 对 level 进行边界检查，确保值在有效范围内
    JGSLogLevel val = MIN(JGSLogLevelError, MAX(level, JGSLogLevelDebug));
    
    // 使用可变参数列表格式化日志字符串
    va_list varList;
    va_start(varList, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:varList];
    va_end(varList);
    
    // 使用全局配置的日志模式和指定的日志级别输出日志
    JGSOutputLog(JGSLogger.mode, val, file, funcName, lineNum, log);
}

void JGSLogWithArgsMode(JGSLogMode mode, const char *file, const char *funcName, NSInteger lineNum, NSString *format, ...) {
    
    // 对 mode 进行边界检查，确保值在有效范围内
    JGSLogMode val = MIN(JGSLogModeFile, MAX(mode, JGSLogModeNone));
    
    // 使用可变参数列表格式化日志字符串
    va_list varList;
    va_start(varList, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:varList];
    va_end(varList);
    
    // 使用指定的日志模式和DEBUG级别输出日志
    JGSOutputLog(val, JGSLogLevelDebug, file, funcName, lineNum, log);
}

void JGSEnableLogWithMode(JGSLogMode mode) {
    JGSLogMode val = MIN(JGSLogModeFile, MAX(mode, JGSLogModeNone));
    if ([NSThread isMainThread]) {
        [JGSLogger enableLogWithMode:val level:JGSLogger.level useNSLog:JGSLogger.useNSLog lengthLimit:JGSLogger.lengthLimit truncating:JGSLogger.truncating];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [JGSLogger enableLogWithMode:val level:JGSLogger.level useNSLog:JGSLogger.useNSLog lengthLimit:JGSLogger.lengthLimit truncating:JGSLogger.truncating];
    });
}

void JGSConsoleLogWithLevel(JGSLogLevel level) {
    JGSLogLevel val = MIN(JGSLogLevelError, MAX(level, JGSLogLevelDebug));
    if ([NSThread isMainThread]) {
        [JGSLogger enableLogWithMode:JGSLogger.mode level:val useNSLog:JGSLogger.useNSLog lengthLimit:JGSLogger.lengthLimit truncating:JGSLogger.truncating];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [JGSLogger enableLogWithMode:JGSLogger.mode level:val useNSLog:JGSLogger.useNSLog lengthLimit:JGSLogger.lengthLimit truncating:JGSLogger.truncating];
    });
}

void JGSConsoleLogWithNSLog(BOOL useNSLog) {
    if ([NSThread isMainThread]) {
        [JGSLogger enableLogWithMode:JGSLogger.mode level:JGSLogger.level useNSLog:useNSLog lengthLimit:JGSLogger.lengthLimit truncating:JGSLogger.truncating];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [JGSLogger enableLogWithMode:JGSLogger.mode level:JGSLogger.level useNSLog:useNSLog lengthLimit:JGSLogger.lengthLimit truncating:JGSLogger.truncating];
    });
}

void JGSConsoleLogWithLimitAndTruncating(NSInteger limit, JGSLogTruncating truncating) {
    JGSLogTruncating val = MIN(JGSLogTruncatingTail, MAX(truncating, JGSLogTruncatingMiddle));
    if ([NSThread isMainThread]) {
        [JGSLogger enableLogWithMode:JGSLogger.mode level:JGSLogger.level useNSLog:JGSLogger.useNSLog lengthLimit:limit truncating:val];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [JGSLogger enableLogWithMode:JGSLogger.mode level:JGSLogger.level useNSLog:JGSLogger.useNSLog lengthLimit:limit truncating:val];
    });
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

@implementation JGSLogFunction

+ (void)enableLog:(BOOL)enable {
    [JGSLogger setEnableDebug:enable];
}

+ (BOOL)isLogEnabled {
    return [JGSLogger enableDebug];
}

@end

#pragma clang diagnostic pop
