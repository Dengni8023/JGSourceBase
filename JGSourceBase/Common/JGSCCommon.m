//
//  JGSCCommon.m
//  JGSourceBase
//
//  Created by 梅继高 on 2018/6/23.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "JGSCCommon.h"
#import <objc/runtime.h>

JGSCLogMode JGSCEnableLogMode = JGSCLogModeNone;
FOUNDATION_EXTERN void JGSCEnableLogWithMode(JGSCLogMode mode) {
    JGSCEnableLogMode = mode;
}

FOUNDATION_EXPORT void JGSCRuntimeSwizzledMethod(Class cls, SEL originSelector, SEL swizzledSelector) {
    
    Method originMethod = class_getInstanceMethod(cls, originSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    
    /*
     严谨的方法替换逻辑：检查运行时源方法的实现是否已执行
     将新的实现添加到源方法，用来做检查用，避免源方法没有实现（有实现，但运行时尚未执行到该方法的实现）
     如果源方法已有实现，会返回 NO，此时直接交换源方法与新方法的实现即可
     如果源方法尚未实现，会返回 YES，此时新的实现已替换原方法的实现，需要将源方法的实现替换到新方法
     */
    BOOL didAddMethod = class_addMethod(cls, originSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    }
    else {
        method_exchangeImplementations(originMethod, swizzledMethod);
    }
}

FOUNDATION_EXPORT UIColor *JG_ColorHex(GLuint rgbHex) {
    
    return JG_ColorHexA(rgbHex, 1.f);
}

FOUNDATION_EXPORT UIColor *JG_ColorHexA(GLuint rgbHex, GLclampf alpha) {
    
    CGFloat r = (rgbHex & 0xFF0000) >> 16;
    CGFloat g = (rgbHex & 0x00FF00) >> 8;
    CGFloat b = (rgbHex & 0x0000FF) >> 0;
    
    return JG_ColorRGBA(r, g, b, alpha);
}

FOUNDATION_EXPORT UIColor *JG_ColorRGB(GLubyte red, GLubyte green, GLubyte blue) {
    
    return JG_ColorRGBA(red, green, blue, 1.f);
}

FOUNDATION_EXPORT UIColor *JG_ColorFRGB(GLclampf red, GLclampf green, GLclampf blue) {
    
    return JG_ColorFRGBA(red, green, blue, 1.f);
}

FOUNDATION_EXPORT UIColor *JG_ColorRGBA(GLubyte red, GLubyte green, GLubyte blue, GLclampf alpha) {
    
    CGFloat r = red / 255.f;
    CGFloat g = green / 255.f;
    CGFloat b = blue / 255.f;
    
    return JG_ColorFRGBA(r, g, b, alpha);
}

FOUNDATION_EXPORT UIColor *JG_ColorFRGBA(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha) {
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@implementation JGSCCommon

@end
