//
//  JGSCRuntime.m
//  JGSourceBase
//
//  Created by 梅继高 on 2018/6/11.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "JGSCRuntime.h"
#import <objc/runtime.h>


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
