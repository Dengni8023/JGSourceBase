//
//  JGSBaseUtils.m
//  JGSBase
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSBaseUtils.h"
#import <objc/runtime.h>
#import "JGSBase+JGSPrivate.h"

FOUNDATION_EXTERN void JGSRuntimeSwizzledMethod(Class cls, SEL originSelector, SEL swizzledSelector) {
    
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
        //
        //
        bundleDir = JGSourceBaseResourceBundleName;
        if ([[NSBundle mainBundle] pathForResource:bundleDir ofType:nil].length > 0) {
            JGSPrivateLog(@"%@ exist in main bundle", JGSourceBaseResourceBundleName);
            return;
        }
        
        bundleDir = [JGSourceBaseFrameworkBundleName stringByAppendingPathComponent:JGSourceBaseResourceBundleName];
        if ([[self classBundle] pathForResource:JGSourceBaseResourceBundleName ofType:nil].length > 0) {
            JGSPrivateLog(@"%@ exist in %@", JGSourceBaseResourceBundleName, JGSourceBaseFrameworkBundleName);
            return;
        }
        
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
