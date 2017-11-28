//
//  JGSourceCommon.h
//  JGSourceBase
//
//  Created by Mei Jigao on 2017/11/24.
//  Copyright © 2017年 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Log
typedef NS_ENUM(NSInteger, JGLogMode) {
    JGLogModeNone = 0,
    JGLogModeLog,
    JGLogModeFunc,
    JGLogModePretty,
    JGLogModeFile
};

/** 日志输出模式，默认 JGLogModeNone 不输出日志 */
FOUNDATION_EXTERN JGLogMode JGEnableLogMode;

/** 日志输出模式，默认 JGLogModeNone 不输出日志 */
FOUNDATION_EXTERN void JGEnableLogWithMode(JGLogMode mode);

// LOG，Xcode控制台日志结尾换行无效，增加空格才有效
#define JGLogOnly(fmt, ...)     NSLog((@"" fmt ""), ##__VA_ARGS__)
#define JGLogFunc(fmt, ...)     NSLog((@"%s Line: %zd " fmt ""), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define JGLogPretty(fmt, ...)   NSLog((@"\nFunc:\t%s\nLine:\t%zd\n" fmt ""), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define JGLogFile(fmt, ...)     NSLog((@"\nFile:\t%@\nFunc:\t%s\nLine:\t%zd\n" fmt ""), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define JGLog(fmt, ...) {\
    switch (JGEnableLogMode) {\
        case JGLogModeLog:\
            JGLogOnly(fmt, ##__VA_ARGS__);\
            break;\
        case JGLogModeFunc:\
            JGLogFunc(fmt, ##__VA_ARGS__);\
            break;\
        case JGLogModePretty:\
            JGLogPretty(fmt, ##__VA_ARGS__);\
            break;\
        case JGLogModeFile:\
            JGLogFile(fmt, ##__VA_ARGS__);\
            break;\
        case JGLogModeNone:\
            break;\
    }\
}

#define JGLogError(fmt, ...)    JGLog(@"<Error> " fmt, ##__VA_ARGS__)
#define JGLogWarning(fmt, ...)  JGLog(@"<Warning> " fmt, ##__VA_ARGS__)

#pragma mark - Reuse
// Reuse identifier
#define JGReuseIdentifier(Class) [NSStringFromClass([self class]) stringByAppendingFormat:@"_%@", NSStringFromClass([Class class])]

#pragma mark - Block
// Break block recycle
#define JGWeak(object) @autoreleasepool{} __weak typeof(object) weak##object = object
#define JGStrong(object) @autoreleasepool{} __strong typeof(weak##object) object = weak##object

#pragma mark - Runtime
/** 更改方法实现，严谨逻辑实现 */
FOUNDATION_EXPORT void JGRuntimeSwizzledSelector(Class cls, SEL originSelector, SEL swizzledSelector);

NS_ASSUME_NONNULL_END
