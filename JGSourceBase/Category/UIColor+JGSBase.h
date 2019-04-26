//
//  UIColor+JGSBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 16进制RGB颜色，alpha默认1.0 */
FOUNDATION_EXPORT UIColor *JGSColorHex(GLuint rgbHex);

/** 16进制RGB颜色，alpha */
FOUNDATION_EXPORT UIColor *JGSColorHexA(GLuint rgbHex, GLclampf alpha);

/** RGB颜色0～255，alpha默认1.0 */
FOUNDATION_EXPORT UIColor *JGSColorRGB(GLubyte red, GLubyte green, GLubyte blue);

/** RGB颜色0～255，alpha */
FOUNDATION_EXPORT UIColor *JGSColorRGBA(GLubyte red, GLubyte green, GLubyte blue, GLclampf alpha);

/** RGB颜色0～1.0，alpha默认1.0 */
FOUNDATION_EXPORT UIColor *JGSColorFRGB(GLclampf red, GLclampf green, GLclampf blue);

/** RGB颜色0～1.0，alpha */
FOUNDATION_EXPORT UIColor *JGSColorFRGBA(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);

@interface UIColor (JGSBase)

/** 16进制RGB颜色，alpha默认1.0 */
+ (instancetype)jg_ColorHex:(GLuint)rgbHex;

/** 16进制RGB颜色，alpha */
+ (instancetype)jg_ColorHex:(GLuint)rgbHex alpha:(GLclampf)alpha;

/** RGB颜色0～255，alpha默认1.0 */
+ (instancetype)jg_ColorR:(GLubyte)red g:(GLubyte)green b:(GLubyte)blue;

/** RGB颜色0～255，alpha */
+ (instancetype)jg_ColorR:(GLubyte)red g:(GLubyte)green b:(GLubyte)blue alpha:(GLclampf)alpha;

/** RGB颜色0～1.0，alpha默认1.0 */
+ (instancetype)jg_ColorFR:(GLclampf)red g:(GLclampf)green b:(GLclampf)blue;

/** RGB颜色0～1.0，alpha */
+ (instancetype)jg_ColorFR:(GLclampf)red g:(GLclampf)green b:(GLclampf)blue alpha:(GLclampf)alpha;

@end

NS_ASSUME_NONNULL_END
