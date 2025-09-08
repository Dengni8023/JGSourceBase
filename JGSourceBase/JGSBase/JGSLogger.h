//
//  JGSLogger.h
//  JGSourceBase
//
//  Created by 梅继高 on 2025/7/7.
//  Copyright © 2025 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Log
typedef NS_ENUM(NSInteger, JGSLogMode) {
    JGSLogModeNone = 0, // 不打印日志
    JGSLogModeLog, // 仅打印日志内容
    JGSLogModeFunc, // 打印日志所在方法名、行号、日志内容
    JGSLogModeFile, // 打印文件名、方法名、行号、日志内容，各部分分行显示
    
    JGSLogModePretty NS_ENUM_DEPRECATED_IOS(8_0, 10_0, "Use JGSLogModeFile") = JGSLogModeFile, // 打印日志所在方法名、行号，各部分分行显示
};

// 日志省略方式
typedef NS_ENUM(NSInteger, JGSLogTruncating) {
    JGSLogTruncatingMiddle, // 中间省略:  "ab...yz"
    JGSLogTruncatingHead, // 头部省略: "...wxyz"
    JGSLogTruncatingTail, // 尾部省略: "abcd..."
};

typedef NS_ENUM(NSInteger, JGSLogLevel) {
    // 此类级别表明我们当前正在临时打印一些log为了去调试程序, 或者说我们为了观察某个现象但是需要频繁打印, 比如相机回调中打印时间戳, 因为相机每秒钟出来几十帧数据, 所以打印十分频繁, 我们可以使用此级别在开发中作为调试信息, 一般不建议在正常使用中开启此级别
    JGSLogLevelDebug = 0, // 调试级别
    // 此类级别一般用于打印模块中一些重要的点, 比如我们可以在某个类初始化完成时打印此类中初始化好的一些重要信息, 或者在使用某个功能前做一个打印, 这样对于追踪代码十分有效
    JGSLogLevelInfo, // 重要信息级别
    // 此类错误一般较低于error级别,即在一些可能出错的地方, 但实际并没有出错, 比如当视频帧数量小于0表示出错情况, 我们为了预防, 可以在视频帧数量小于5时使用此类添加一条预防的Log
    JGSLogLevelWarn, // 警告级别
    // 此类打印可用于出现一般错误,比如某个方法调用返回失败, 因为一般而言代码预期是正确的, 所以此类Log不会打印的太频繁, 打开此级别后我们可以清晰看到程序哪些地方出现问题
    JGSLogLevelError, // 出错级别
};

#pragma mark - Log - Define
FOUNDATION_EXTERN void JGSLogWithArgs(JGSLogMode mode, JGSLogLevel level, const char *filePath, const char *funcName, NSInteger lineNum, NSString *format, ...);
FOUNDATION_EXTERN void JGSLogWithArgsOnly(const char *filePath, const char *funcName, NSInteger lineNum, NSString *format, ...);
FOUNDATION_EXTERN void JGSLogWithArgsLevel(JGSLogLevel level, const char *filePath, const char *funcName, NSInteger lineNum, NSString *format, ...);
FOUNDATION_EXTERN void JGSLogWithArgsMode(JGSLogMode mode, const char *filePath, const char *funcName, NSInteger lineNum, NSString *format, ...);

#define JGSLogWithFormat(fmt, ...)                 JGSLogWithArgsOnly(__FILE__, __PRETTY_FUNCTION__, __LINE__, @"" fmt "", ## __VA_ARGS__)
#define JGSLogWithLevel(level, fmt, ...)           JGSLogWithArgsLevel(level, __FILE__, __PRETTY_FUNCTION__, __LINE__, @"" fmt "", ## __VA_ARGS__)
#define JGSLogWithMode(mode, fmt, ...)           JGSLogWithArgsMode(mode, __FILE__, __PRETTY_FUNCTION__, __LINE__, @"" fmt "", ## __VA_ARGS__)
#define JGSLogWithModeLevel(mode, level, fmt, ...) JGSLogWithModeArgs(mode, level, __FILE__, __PRETTY_FUNCTION__, __LINE__, @"" fmt "", ## __VA_ARGS__)

#define JGSLog(fmt, ...)  JGSLogD(fmt, ## __VA_ARGS__)
#define JGSLogD(fmt, ...) JGSLogWithLevel(JGSLogLevelDebug, fmt, ## __VA_ARGS__)
#define JGSLogI(fmt, ...) JGSLogWithLevel(JGSLogLevelInfo, fmt, ## __VA_ARGS__)
#define JGSLogW(fmt, ...) JGSLogWithLevel(JGSLogLevelWarn, fmt, ## __VA_ARGS__)
#define JGSLogE(fmt, ...) JGSLogWithLevel(JGSLogLevelError, fmt, ## __VA_ARGS__)

#pragma mark - Log - Deprecated
#define JGSLogInfo(fmt, ...)    JGSLogI(fmt, ## __VA_ARGS__)
#define JGSLogWarning(fmt, ...) JGSLogW(fmt, ## __VA_ARGS__)
#define JGSLogError(fmt, ...)   JGSLogE(fmt, ## __VA_ARGS__)
#define JGSLogOnly(fmt, ...)    JGSLogWithMode(JGSLogModeLog, fmt, ## __VA_ARGS__)
#define JGSLogFunc(fmt, ...)    JGSLogWithMode(JGSLogModeFunc, fmt, ## __VA_ARGS__)
#define JGSLogFile(fmt, ...)    JGSLogWithMode(JGSLogModeFile, fmt, ## __VA_ARGS__)
#define JGSLogPretty(fmt, ...)  JGSLogFile(fmt, ## __VA_ARGS__)

#pragma mark - Logger
/**
 日志输出模式，默认 JGSLogModeNone 不输出日志
 */
FOUNDATION_EXTERN void JGSEnableLogWithMode(JGSLogMode mode) DEPRECATED_MSG_ATTRIBUTE("Replaced by + [JGSLogger enableLogWithMode: level: useNSLog: lengthLimit: truncating:]");

/**
 日志输出级别，默认 JGSLogLevelDebug 输出所有级别日志，日志输出结合 JGSLogMode 使用
 */
FOUNDATION_EXTERN void JGSConsoleLogWithLevel(JGSLogLevel level) DEPRECATED_MSG_ATTRIBUTE("Replaced by + [JGSLogger enableLogWithMode: level: useNSLog: lengthLimit: truncating:]");

/**
 日志输出方式，是否使用NSLog，默认NO，使用print ;
 使用NSLog时，若 scheme-run-Arhuments 设置了OS_ACTIVITY_MODE=disable，则NSLog将无法输出任何日志（Xcode调试控制台无日志，且Mac系统控制台也无日志）
 不使用NSLog时，OS_ACTIVITY_MODE设置不影响Xcode调试控制台日志输出，但Mac系统控制台无日志
 */
FOUNDATION_EXTERN void JGSConsoleLogWithNSLog(BOOL useNSLog) DEPRECATED_MSG_ATTRIBUTE("Replaced by + [JGSLogger enableLogWithMode: level: useNSLog: lengthLimit: truncating:]");

/// 日志输出内容长度限制，超出长度
/// - Parameters:
///   - limit: 日志长度限制，< 0xff 则不限制，默认不限制
///   - truncating: 日志超长省略方式，默认中间省略
FOUNDATION_EXTERN void JGSConsoleLogWithLimitAndTruncating(NSInteger limit, JGSLogTruncating truncating) DEPRECATED_MSG_ATTRIBUTE("Replaced by + [JGSLogger enableLogWithMode: level: useNSLog: lengthLimit: truncating:]");

NS_CLASS_DEPRECATED_IOS(7.0, 12.0, "Replaced by JGSLogger")
@interface JGSLogFunction : NSObject

/// 是否开启内部调试日志
+ (void)enableLog:(BOOL)enable DEPRECATED_MSG_ATTRIBUTE("Use -[JGSLogger enableDebug:] instead");;
+ (BOOL)isLogEnabled;

@end

NS_ASSUME_NONNULL_END
