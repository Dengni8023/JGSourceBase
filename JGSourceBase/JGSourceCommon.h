//
//  JGSourceCommon.h
//  JGSourceBase
//
//  Created by Mei Jigao on 2017/11/24.
//  Copyright © 2017年 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JGLogMode) {
    JGLogModeNone = 0,
    JGLogModeLog,
    JGLogModeFunc,
    JGLogModePretty,
    JGLogModeFile
};

/** 日志输出模式，默认 JGLogModeNone 不输出日志 */
FOUNDATION_EXPORT JGLogMode JGEnableLogMode;
FOUNDATION_EXPORT void JGEnableLogWithMode(JGLogMode mode);

// LOG，Xcode控制台日志结尾换行无效，增加空格才有效
#define JGLogOnly(fmt, ...)     NSLog((@"" fmt "\n "), ##__VA_ARGS__)
#define JGLogFunc(fmt, ...)     NSLog((@"%s Line: %zd " fmt "\n "), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define JGLogPretty(fmt, ...)   NSLog((@"\n\nFunc:\t%s\nLine:\t%zd\n" fmt "\n "), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define JGLogFile(fmt, ...)     NSLog((@"\n\nFile:\t%@\nFunc:\t%s\nLine:\t%zd\n" fmt "\n "), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

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

// Reuse identifier
#define JGReuseIdentifier(Class) [NSStringFromClass([self class]) stringByAppendingFormat:@"_%@", NSStringFromClass([Class class])]

// Break block recycle
#define JGWeak(object) @autoreleasepool{} __weak typeof(object) weak##object = object
#define JGStrong(object) @autoreleasepool{} __strong typeof(weak##object) object = weak##object

@interface JGSourceCommon : NSObject

@end

NS_ASSUME_NONNULL_END
