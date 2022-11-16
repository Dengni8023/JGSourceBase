//
//  JGSBaseUtils.h
//  JGSBase
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// Reuse identifier
#pragma mark - Reuse
#define JGSReuseIdentifier(Class)  [NSStringFromClass([self class]) stringByAppendingFormat:@"_%@", NSStringFromClass([Class class])]

// Common
#pragma mark - Common
#define JGSEmptyString2Nil(object) (object.length > 0 ? object : nil)
#define JGSNil2EmptyString(object) (!object ? @"" : object)
#define JGSNull2Nil(object)        ([object isKindOfClass:[NSNull class]] ? nil : object)

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
{ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
PerformCoding \
_Pragma("clang diagnostic pop") \
}

// 消除方法弃用(过时)的警告
#define JGSSuppressWarning_DeprecatedDeclarations(PerformCoding) \
{ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"") \
PerformCoding \
_Pragma("clang diagnostic pop") \
}

// ignored(忽视)消除对应的selector的警告
#define JGSSuppressWarning_UndeclaredSelector(PerformCoding) \
{ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
PerformCoding \
_Pragma("clang diagnostic pop") \
}

// Runtime
#pragma mark - SwizzledMethod
/// 更改方法实现，严谨逻辑实现
FOUNDATION_EXTERN void JGSRuntimeSwizzledMethod(Class cls, SEL originSelector, SEL swizzledSelector);

/// 字符串大小写风格
typedef NS_ENUM(NSInteger, JGSStringUpperLowerStyle) {
    JGSStringLowercase = 0, // 字母小写，默认风格
    JGSStringUppercase, // 字母大写风格
	JGSStringRandomCase, // 随机，字符串中随机存在大小写
	JGSStringCaseDefault = JGSStringLowercase,
};

/// JGSourceBase framework bundle
#define JGSourceBaseFrameworkBundleName  @"JGSourceBase.framework"

/// JGSourceBase resource bundle
/// TODO: ⚠️ 注意与 podspec 文件中 resource_bundles 名称保持一致
#define JGSourceBaseResourceBundleName  @"JGSourceBase.bundle"

@interface JGSBaseUtils : NSObject

/// 类所在 bundle
/// 1、源文件引用以及 .a 包 (Pod) 引用：主 Target 的 mainBundle
/// 2、framework 引用：framework
+ (NSBundle *)classBundle;

/// 资源文件 bundle
/// 一、源文件使用，bundle 为 nil
/// 二、使用 famework + bundle，存在资源 bundle
/// 三、Pod 方式使用，根据 podspec 定义的资源文件使用方式存在差异
/// 1、使用 resource_bundles 方式则存在资源 bundle；
/// 2、使用 resources 则不存在 bundle
/// 3、此处 podspec 使用的 resource_bundles 方式，存在bundle
+ (nullable NSBundle *)resourceBundle;

/// 资源文件 bundle
/// 一、源文件使用，bundle 为 nil
/// 二、使用 famework + bundle，存在资源 bundle
/// 三、Pod 方式使用，根据 podspec 定义的资源文件使用方式存在差异
/// 1、使用 resource_bundles 方式则存在资源 bundle；
/// 2、使用 resources 则不存在 bundle
/// 3、此处 podspec 使用的 resource_bundles 方式，存在bundle
+ (NSString *)fileInResourceBundle:(NSString *)resourceFile;

+ (nullable UIImage *)imageInResourceBundle:(NSString *)name;

/// 组件版本
+ (NSString *)version;

@end

NS_ASSUME_NONNULL_END
