//
//  JGSBaseUtils.m
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/27.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import "JGSBaseUtils.h"
#if __has_include(<JGSourceBase/JGSourceBase-Swift.h>)
#import <JGSourceBase/JGSourceBase-Swift.h>
#elif __has_include("JGSourceBase-Swift.h")
#import "JGSourceBase-Swift.h"
#endif
#import <objc/runtime.h>

NSString * JGSourceBaseVersion(void) {
    return [JGSBaseUtils sdkVersion];
}

void JGSInnerRuntimeSwizzledMethod(Class cls, SEL originSelector, SEL swizzledSelector, BOOL classMethod) {
    
    // 获取原始方法和新方法（默认按实例方法处理）
    Method originMethod = class_getInstanceMethod(cls, originSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);

    // 如果是类方法，则使用 class_getClassMethod 获取类方法
    // 类方法存储在元类(MetaClass)中，因此需要将 cls 转换为元类
    if (classMethod) {
        originMethod = class_getClassMethod(cls, originSelector);
        swizzledMethod = class_getClassMethod(cls, swizzledSelector);
        
        // 确保使用元类进行后续操作
        if (!class_isMetaClass(cls)) {
            cls = objc_getMetaClass(NSStringFromClass(cls).UTF8String);
        }
    } else {
        // 实例方法必须使用普通类
        if (class_isMetaClass(cls)) {
            cls = objc_getClass(NSStringFromClass(cls).UTF8String);
        }
    }

    // 如果原始方法或新方法为空，则直接返回，无法进行方法交换
    if (originMethod == nil || swizzledMethod == nil) {
        return;
    }
    
    /*
     严谨的方法替换逻辑：
     
     1. 尝试将 swizzledMethod 的实现添加到 originSelector
        - 如果返回 YES，表示 originSelector 原本没有实现，新实现已成功添加
        - 如果返回 NO，表示 originSelector 已有实现，添加失败
     
     2. 根据添加结果决定后续操作：
        - didAddMethod == YES：需要将原始方法的实现替换到 swizzledSelector
          这样在调用 swizzledSelector 时可以执行原始逻辑
        - didAddMethod == NO：直接交换两个方法的实现即可
     
     注意：对于协议方法或未实现的方法，class_addMethod 会返回 YES
     在这种情况下，swizzledSelector 中调用原始方法时需要检查是否会导致死循环
     */
    BOOL didAddMethod = class_addMethod(cls, originSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    }
    else {
        method_exchangeImplementations(originMethod, swizzledMethod);
    }
}

void JGSRuntimeSwizzledMethod(Class cls, SEL originSelector, SEL swizzledSelector) {
    // 调用内部方法进行方法交换，参数为类、原始方法选择器、新方法选择器，且指定为实例方法
    JGSInnerRuntimeSwizzledMethod(cls, originSelector, swizzledSelector, NO);
}

void JGSRuntimeSwizzledClassMethod(Class cls, SEL originSelector, SEL swizzledSelector) {
    // 调用内部方法进行方法交换，参数为类、原始方法选择器、新方法选择器，且指定为类方法
    JGSInnerRuntimeSwizzledMethod(cls, originSelector, swizzledSelector, YES);
}
