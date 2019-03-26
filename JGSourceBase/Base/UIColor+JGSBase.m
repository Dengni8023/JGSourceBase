//
//  UIColor+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "UIColor+JGSBase.h"

FOUNDATION_EXPORT UIColor *JGSColorHex(GLuint rgbHex) {
    return JGSColorHexA(rgbHex, 1.f);
}

FOUNDATION_EXPORT UIColor *JGSColorHexA(GLuint rgbHex, GLclampf alpha) {
    
    CGFloat r = (rgbHex & 0xFF0000) >> 16;
    CGFloat g = (rgbHex & 0x00FF00) >> 8;
    CGFloat b = (rgbHex & 0x0000FF) >> 0;
    return JGSColorRGBA(r, g, b, alpha);
}

FOUNDATION_EXPORT UIColor *JGSColorRGB(GLubyte red, GLubyte green, GLubyte blue) {
    return JGSColorRGBA(red, green, blue, 1.f);
}

FOUNDATION_EXPORT UIColor *JGSColorFRGB(GLclampf red, GLclampf green, GLclampf blue) {
    return JGSColorFRGBA(red, green, blue, 1.f);
}

FOUNDATION_EXPORT UIColor *JGSColorRGBA(GLubyte red, GLubyte green, GLubyte blue, GLclampf alpha) {
    
    CGFloat r = red / 255.f;
    CGFloat g = green / 255.f;
    CGFloat b = blue / 255.f;
    return JGSColorFRGBA(r, g, b, alpha);
}

FOUNDATION_EXPORT UIColor *JGSColorFRGBA(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha) {
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@implementation UIColor (JGSBase)

+ (instancetype)jg_ColorHex:(GLuint)rgbHex {
    return [UIColor jg_ColorHex:rgbHex alpha:1.f];
}

+ (instancetype)jg_ColorHex:(GLuint)rgbHex alpha:(GLclampf)alpha {
    
    CGFloat r = (rgbHex & 0xFF0000) >> 16;
    CGFloat g = (rgbHex & 0x00FF00) >> 8;
    CGFloat b = (rgbHex & 0x0000FF) >> 0;
    return [UIColor jg_ColorR:r g:g b:b alpha:alpha];
}

+ (instancetype)jg_ColorR:(GLubyte)red g:(GLubyte)green b:(GLubyte)blue {
    return [UIColor jg_ColorR:red g:green b:blue alpha:1.f];
}

+ (instancetype)jg_ColorR:(GLubyte)red g:(GLubyte)green b:(GLubyte)blue alpha:(GLclampf)alpha {
    
    CGFloat r = red / 255.f;
    CGFloat g = green / 255.f;
    CGFloat b = blue / 255.f;
    return [UIColor jg_ColorFR:r g:g b:b alpha:alpha];
}

+ (instancetype)jg_ColorFR:(GLclampf)red g:(GLclampf)green b:(GLclampf)blue {
    return [UIColor jg_ColorFR:red g:green b:blue alpha:1.f];
}

+ (instancetype)jg_ColorFR:(GLclampf)red g:(GLclampf)green b:(GLclampf)blue alpha:(GLclampf)alpha {
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
