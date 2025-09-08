//
//  JGSBaseUtils.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSBaseUtils.h"
#import <objc/runtime.h>
#import "JGSBase+Private.h"

void JGSInnerRuntimeSwizzledMethod(Class cls, SEL originSelector, SEL swizzledSelector, BOOL classMethod) {
    
    // 获取原始方法和新方法
    Method originMethod = class_getInstanceMethod(cls, originSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);

    // 如果是类方法，则获取类方法并使用元类
    if (classMethod) {
        originMethod = class_getClassMethod(cls, originSelector);
        swizzledMethod = class_getClassMethod(cls, swizzledSelector);
        // 类方法必须使用 MetaClass
        if (!class_isMetaClass(cls)) {
            cls = objc_getMetaClass(NSStringFromClass(cls).UTF8String);
        }
    } else {
        // 实例方法必须使用 Class
        if (class_isMetaClass(cls)) {
            cls = objc_getClass(NSStringFromClass(cls).UTF8String);
        }
    }

    // 如果原始方法或新方法为空，则直接返回
    if (originMethod == nil || swizzledMethod == nil) {
        return;
    }
    
    /*
     严谨的方法替换逻辑：
     1. 检查运行时源方法的实现是否已执行
     2. 将新的实现添加到源方法，用来做检查用，避免源方法没有实现（有实现，但运行时尚未执行到该方法的实现）
     3. 如果源方法已有实现，会返回 NO，此时直接交换源方法与新方法的实现即可
     4. 如果源方法尚未实现，会返回 YES，此时新的实现已替换原方法的实现，需要将源方法的实现替换到新方法
     
     对于部分代理方法，可能存在该类本身是没有进行实现的，此时将新的实现添加到源方法必返回YES
     之后不需要在进行其他操作，在新的实现内部如需执行源方法，需要判断新方法与源方法实现是否一致，一致时则不能执行原方法(否则死循环)
     */
    BOOL didAddMethod = class_addMethod(cls, originSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    }
    else {
        method_exchangeImplementations(originMethod, swizzledMethod);
    }
}

FOUNDATION_EXTERN void JGSRuntimeSwizzledMethod(Class cls, SEL originSelector, SEL swizzledSelector) {
    // 调用内部方法进行方法交换，参数为类、原始方法选择器、新方法选择器，且指定为实例方法
    JGSInnerRuntimeSwizzledMethod(cls, originSelector, swizzledSelector, NO);
}

FOUNDATION_EXTERN void JGSRuntimeSwizzledClassMethod(Class cls, SEL originSelector, SEL swizzledSelector) {
    // 调用内部方法进行方法交换，参数为类、原始方法选择器、新方法选择器，且指定为类方法
    JGSInnerRuntimeSwizzledMethod(cls, originSelector, swizzledSelector, YES);
}

@implementation JGSBaseUtils

+ (NSBundle *)classBundle {
    
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleForClass:[self class]] ?: [NSBundle mainBundle];
    });
    return bundle;
}

+ (NSBundle *)resourceBundle {
    
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *path = [[self classBundle].resourcePath stringByAppendingPathComponent:JGSourceBaseResourceBundleName];
        bundle = [NSBundle bundleWithPath:path];
        if (bundle) {
            return;
        }
        
        path = [[NSBundle mainBundle] pathForResource:JGSourceBaseResourceBundleName ofType:nil];
        bundle = path.length > 0 ? [NSBundle bundleWithPath:path] : nil;
    });
    return bundle;
}

+ (NSString *)fileInResourceBundle:(NSString *)resourceFile {
    
    static NSString *bundleDir = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 源码直接引用、打包方式引用 bundle 路径
        bundleDir = JGSourceBaseResourceBundleName;
        if ([[NSBundle mainBundle] pathForResource:bundleDir ofType:nil].length > 0) {
            JGSPrivateLog(@"%@ exist in main bundle", JGSourceBaseResourceBundleName);
            return;
        }
        
        // Pod等方式引用 bundle 路径
        bundleDir = [JGSourceBaseFrameworkBundleName stringByAppendingPathComponent:JGSourceBaseResourceBundleName];
        if ([[self classBundle] pathForResource:JGSourceBaseResourceBundleName ofType:nil].length > 0) {
            JGSPrivateLog(@"%@ exist in %@", JGSourceBaseResourceBundleName, JGSourceBaseFrameworkBundleName);
            return;
        }
        
        // bundle 不存在情况
        JGSPrivateLog(@"%@ not exist", JGSourceBaseResourceBundleName);
        bundleDir = nil;
    });
    
    NSString *name = bundleDir ? [bundleDir stringByAppendingPathComponent:resourceFile] : resourceFile;
    return name;
}

+ (UIImage *)imageInResourceBundle:(NSString *)name {
    
    UIImage *image = [UIImage imageNamed:[self fileInResourceBundle:name]];
    if (!image) {
        image = [UIImage imageNamed:name inBundle:[self resourceBundle] compatibleWithTraitCollection:nil];
    }
    
    // tint color 渲染图片，可能导致图片未按照原图展示
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    return image;
}

+ (NSString *)version {
    
    NSString *version = [NSString stringWithUTF8String:JGSVersion] ?: @"1.0.0";
    NSString *build = [NSString stringWithUTF8String:JGSBuild] ?: @"1";
    NSString *sourceVersion = [NSString stringWithFormat:@"JGSourceBase_V%@.%@", version, build];
    
    return sourceVersion;
}

@end
