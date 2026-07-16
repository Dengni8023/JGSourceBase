//
//  JGSLogger.h
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/18.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Log - Define

/// 打印日志，注意参数方法中不要使用修改变量的表达式，避免打印、不打印日志时外部获取的参数值不一样
/// - Parameters:
///   - mode: 日志打印模式，详见 JGSLogger.swift > JGSLogMode
///   - level: 日志级别，详见 JGSLogger.swift > JGSLogLevel
///   - file: 文件路径
///   - funcName: 方法名
///   - lineNum: 代码行
///   - format: 格式化控制字符串及后续参数
FOUNDATION_EXTERN void JGSLogWithArgs(NSInteger /*JGSLogMode*/ mode, NSInteger /*JGSLogLevel*/ level, const char *file, const char *funcName, NSInteger lineNum, NSString *format, ...) NS_FORMAT_FUNCTION(6, 7);

/// 打印日志，注意参数方法中不要使用修改变量的表达式，避免打印、不打印日志时外部获取的参数值不一样
/// - Parameters:
///   - file: 文件路径
///   - funcName: 方法名
///   - lineNum: 代码行
///   - format: 格式化控制字符串及后续参数
FOUNDATION_EXTERN void JGSLogWithArgsOnly(const char *file, const char *funcName, NSInteger lineNum, NSString *format, ...) NS_FORMAT_FUNCTION(4, 5);

/// 打印日志，注意参数方法中不要使用修改变量的表达式，避免打印、不打印日志时外部获取的参数值不一样
/// - Parameters:
///   - level: 日志级别，详见 JGSLogger.swift > JGSLogLevel
///   - file: 文件路径
///   - funcName: 方法名
///   - lineNum: 代码行
///   - format: 格式化控制字符串及后续参数
FOUNDATION_EXTERN void JGSLogWithArgsLevel(NSInteger /*JGSLogLevel*/ level, const char *file, const char *funcName, NSInteger lineNum, NSString *format, ...) NS_FORMAT_FUNCTION(5, 6);

/// 打印日志，注意参数方法中不要使用修改变量的表达式，避免打印、不打印日志时外部获取的参数值不一样
/// - Parameters:
///   - mode: 日志打印模式，详见 JGSLogger.swift > JGSLogMode
///   - file: 文件路径
///   - funcName: 方法名
///   - lineNum: 代码行
///   - format: 格式化控制字符串及后续参数
FOUNDATION_EXTERN void JGSLogWithArgsMode(NSInteger /*JGSLogMode*/ mode, const char *file, const char *funcName, NSInteger lineNum, NSString *format, ...) NS_FORMAT_FUNCTION(5, 6);

#define JGSLogWithFormat(fmt, ...)                 JGSLogWithArgsOnly(__FILE_NAME__, __PRETTY_FUNCTION__, __LINE__, @"" fmt "", ## __VA_ARGS__);
#define JGSLogWithLevel(level, fmt, ...)           JGSLogWithArgsLevel(level, __FILE_NAME__, __PRETTY_FUNCTION__, __LINE__, @"" fmt "", ## __VA_ARGS__);
#define JGSLogWithMode(mode, fmt, ...)             JGSLogWithArgsMode(mode, __FILE_NAME__, __PRETTY_FUNCTION__, __LINE__, @"" fmt "", ## __VA_ARGS__);
#define JGSLogWithModeLevel(mode, level, fmt, ...) JGSLogWithModeArgs(mode, level, __FILE_NAME__, __PRETTY_FUNCTION__, __LINE__, @"" fmt "", ## __VA_ARGS__);

#define JGSLog(fmt, ...)  JGSLogD(fmt, ## __VA_ARGS__)
#define JGSLogD(fmt, ...) JGSLogWithLevel(0 /*JGSLogLevelDebug*/, fmt, ## __VA_ARGS__)
#define JGSLogI(fmt, ...) JGSLogWithLevel(1 /*JGSLogLevelInfo*/, fmt, ## __VA_ARGS__)
#define JGSLogW(fmt, ...) JGSLogWithLevel(2 /*JGSLogLevelWarn*/, fmt, ## __VA_ARGS__)
#define JGSLogE(fmt, ...) JGSLogWithLevel(3 /*JGSLogLevelError*/, fmt, ## __VA_ARGS__)

#pragma mark - Log - Deprecated
#define JGSLogInfo(fmt, ...)    JGSLogI(fmt, ## __VA_ARGS__)
#define JGSLogWarning(fmt, ...) JGSLogW(fmt, ## __VA_ARGS__)
#define JGSLogError(fmt, ...)   JGSLogE(fmt, ## __VA_ARGS__)
#define JGSLogOnly(fmt, ...)    JGSLogWithMode(1 /*JGSLogModeLog*/, fmt, ## __VA_ARGS__)
#define JGSLogFunc(fmt, ...)    JGSLogWithMode(2 /*JGSLogModeFunc*/, fmt, ## __VA_ARGS__)
#define JGSLogFile(fmt, ...)    JGSLogWithMode(3 /*JGSLogModeFile*/, fmt, ## __VA_ARGS__)
#define JGSLogPretty(fmt, ...)  JGSLogFile(fmt, ## __VA_ARGS__)

#pragma mark - Logger
/// 日志输出模式，JGSLogMode， 默认 JGSLogModeNone 不输出日志
FOUNDATION_EXTERN void JGSEnableLogWithMode(NSInteger /*JGSLogMode*/ mode) DEPRECATED_MSG_ATTRIBUTE("Replaced by + [JGSLogger enableLogWithMode: level: useNSLog: lengthLimit: truncating:]") ;

/// 日志输出级别，JGSLogLevel， 默认 JGSLogLevelDebug 输出所有级别日志，日志输出结合 JGSLogMode 使用
FOUNDATION_EXTERN void JGSConsoleLogWithLevel(NSInteger /*JGSLogLevel*/ level) DEPRECATED_MSG_ATTRIBUTE("Replaced by + [JGSLogger enableLogWithMode: level: useNSLog: lengthLimit: truncating:]");

/// 日志输出方式，是否使用NSLog，默认NO，使用print ;
/// 使用NSLog时，若 scheme-run-Arguments 设置了OS_ACTIVITY_MODE=disable，则NSLog将无法输出任何日志（Xcode调试控制台无日志，且Mac系统控制台也无日志）
/// 不使用NSLog时，OS_ACTIVITY_MODE设置不影响Xcode调试控制台日志输出，但Mac系统控制台无日志
/// - Parameter useNSLog: 是否使用NSLog
FOUNDATION_EXTERN void JGSConsoleLogWithNSLog(BOOL useNSLog) DEPRECATED_MSG_ATTRIBUTE("Replaced by + [JGSLogger enableLogWithMode: level: useNSLog: lengthLimit: truncating:]");

/// 日志输出内容长度限制，超出长度
/// - Parameters:
///   - limit: 日志长度限制，< 0xff 则不限制，默认不限制
///   - truncating: 日志超长省略方式，JGSLogTruncating，默认中间省略
FOUNDATION_EXTERN void JGSConsoleLogWithLimitAndTruncating(NSInteger limit, NSInteger /*JGSLogTruncating*/ truncating) DEPRECATED_MSG_ATTRIBUTE("Replaced by + [JGSLogger enableLogWithMode: level: useNSLog: lengthLimit: truncating:]");

__deprecated_msg("Replaced by JGSLogger")
@interface JGSLogFunction : NSObject

/// 是否开启内部调试日志
+ (void)enableLog:(BOOL)enable;
+ (BOOL)isLogEnabled;

@end

NS_ASSUME_NONNULL_END
