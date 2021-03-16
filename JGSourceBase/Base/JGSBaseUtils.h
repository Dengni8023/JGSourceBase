//
//  JGSBaseUtils.h
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Reuse identifier
#pragma mark - Reuse
#define JGSReuseIdentifier(Class)  [NSStringFromClass([self class]) stringByAppendingFormat:@"_%@", NSStringFromClass([Class class])]

// nil null empty
#pragma mark - nil null empty
#define JGSEmptyString2Nil(object) (object.length > 0 ? object : nil)
#define JGSNil2EmptyString(object) (!object ? @"" : object)
#define JGSNull2Nil(object)        ([object isEqual:[NSNull null]] ? nil : object)

// Device
#pragma mark - Device
#define JGSIsPadDevice     ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].length > 0) // Pad设备
#define JGSIsPadUI         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) // Pad界面
#define JGSDeviceScale     [UIScreen mainScreen].scale // 设备分辨率倍数
#define JGSMinimumPoint    (1.f / JGSDeviceScale) // 最小显示点单位

// 常用警告消除
#pragma mark - 常用警告消除
// performSelector警告消除
#define JGSSuppressWarning_PerformSelector(PerformCoding) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
PerformCoding \
_Pragma("clang diagnostic pop") \
} while (0)

// Runtime
#pragma mark - SwizzledMethod
/** 更改方法实现，严谨逻辑实现 */
FOUNDATION_EXTERN void JGSRuntimeSwizzledMethod(Class cls, SEL originSelector, SEL swizzledSelector);

@interface JGSBaseUtils : NSObject

@end

NS_ASSUME_NONNULL_END
