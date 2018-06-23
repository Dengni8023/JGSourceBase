//
//  JGSCCommon.h
//  JGSourceBase
//
//  Created by 梅继高 on 2018/6/11.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JGSCLogDefine.h"
#import "JGSCWeakStrongProperty.h"

NS_ASSUME_NONNULL_BEGIN

// Reuse identifier
#pragma mark - Reuse
#define JGSCReuseIdentifier(Class)  [NSStringFromClass([self class]) stringByAppendingFormat:@"_%@", NSStringFromClass([Class class])]

// nil null empty
#pragma mark - nil null empty
#define JGSCEmptyString2Nil(object) (object.length > 0 ? object : nil)
#define JGSCNil2EmptyString(object) (!object ? @"" : object)
#define JGSCNull2Nil(object)        ([object isEqual:[NSNull null]] ? nil : object)

// Device
#pragma mark - Device
#define JGSCIsPadDevice     ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].length > 0) // Pad设备
#define JGSCIsPadUI         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) // Pad界面
#define JGSCDeviceScale     [UIScreen mainScreen].scale // 设备分辨率倍数
#define JGSCMinimumPoint    (1.f / JGSCDeviceScale) // 最小显示点单位

// Logger
#pragma mark - Logger
/** 日志输出模式，默认 JGSCLogModeNone 不输出日志 */
FOUNDATION_EXTERN JGSCLogMode JGSCEnableLogMode;

/** 日志输出模式，默认 JGSCLogModeNone 不输出日志 */
FOUNDATION_EXTERN void JGSCEnableLogWithMode(JGSCLogMode mode);

// Runtime
#pragma mark - Runtime
/** 更改方法实现，严谨逻辑实现 */
FOUNDATION_EXPORT void JGSCRuntimeSwizzledMethod(Class cls, SEL originSelector, SEL swizzledSelector);

// UIColor
#pragma mark - UIColor
/** 16进制RGB颜色，alpha默认1.0 */
FOUNDATION_EXPORT UIColor *JG_ColorHex(GLuint rgbHex);

/** 16进制RGB颜色，alpha */
FOUNDATION_EXPORT UIColor *JG_ColorHexA(GLuint rgbHex, GLclampf alpha);

/** RGB颜色0～255，alpha默认1.0 */
FOUNDATION_EXPORT UIColor *JG_ColorRGB(GLubyte red, GLubyte green, GLubyte blue);

/** RGB颜色0～1.0，alpha默认1.0 */
FOUNDATION_EXPORT UIColor *JG_ColorFRGB(GLclampf red, GLclampf green, GLclampf blue);

/** RGB颜色0～255，alpha */
FOUNDATION_EXPORT UIColor *JG_ColorRGBA(GLubyte red, GLubyte green, GLubyte blue, GLclampf alpha);

/** RGB颜色0～1.0，alpha */
FOUNDATION_EXPORT UIColor *JG_ColorFRGBA(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);

@interface JGSCCommon : NSObject

@end

NS_ASSUME_NONNULL_END
