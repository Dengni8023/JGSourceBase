//
//  JGSBaseUtils.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 重用标识符
#pragma mark - 重用
#define JGSReuseIdentifier(Class)  [NSStringFromClass([self class]) stringByAppendingFormat:@"_%@", NSStringFromClass([Class class])] // 根据类名生成重用标识符

// 常用宏定义
#pragma mark - 常用宏定义
#define JGSEmptyString2Nil(object) (object == nil || ([object isKindOfClass:NSString.class] && object.length == 0) ? nil : object) // 将空字符串转换为nil
#define JGSNil2EmptyString(object) (object == nil ? @"" : object) // 将nil转换为空字符串
#define JGSNull2Nil(object)        ([object isKindOfClass:NSNull.class] ? nil : object) // 将NSNull对象转换为nil

// 设备相关宏定义
#pragma mark - 设备相关宏定义
#define JGSIsPadDevice     ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].length > 0) // 判断是否为iPad设备
#define JGSIsPadUI         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) // 判断是否为iPad界面
#define JGSDeviceScale     [UIScreen mainScreen].scale // 获取设备的分辨率倍数
#define JGSMinimumPoint    (1.f / JGSDeviceScale) // 计算最小显示点单位

// 常用警告消除宏定义
#pragma mark - 常用警告消除宏定义
// 消除performSelector的警告
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

// 消除未声明的选择器的警告
#define JGSSuppressWarning_UndeclaredSelector(PerformCoding) \
{ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
PerformCoding \
_Pragma("clang diagnostic pop") \
}

// 运行时方法交换
#pragma mark - 运行时方法交换
/// 更换方法实现，严谨逻辑实现（实例方法）
/// @param cls 类
/// @param originSelector 原始方法
/// @param swizzledSelector 替换后方法
FOUNDATION_EXTERN void JGSRuntimeSwizzledMethod(Class cls, SEL originSelector, SEL swizzledSelector);

/// 更换方法实现，严谨逻辑实现（类方法）
/// @param cls 类
/// @param originSelector 原始方法
/// @param swizzledSelector 替换后方法
FOUNDATION_EXTERN void JGSRuntimeSwizzledClassMethod(Class cls, SEL originSelector, SEL swizzledSelector);

/// 字符串大小写风格枚举
typedef NS_ENUM(NSInteger, JGSStringUpperLowerStyle) {
    JGSStringLowercase = 0, // 字母小写，默认风格
    JGSStringUppercase, // 字母大写风格
	JGSStringRandomCase, // 随机，字符串中随机存在大小写
    JGSStringCaseDefault = JGSStringLowercase, // 默认风格，即字母小写
};

/// JGSourceBase框架的bundle名称
#define JGSourceBaseFrameworkBundleName  @"JGSourceBase.framework"

/// JGSourceBase资源bundle名称
/// TODO: ⚠️ 注意与 podspec 文件中 resource_bundles 名称保持一致
#define JGSourceBaseResourceBundleName  @"JGSourceBase.bundle"

@interface JGSBaseUtils : NSObject

/// 获取类所在的bundle
/// 1、源文件引用以及 .a 包 (Pod) 引用：主 Target 的 mainBundle
/// 2、framework（成品包、Pod） 引用：framework
+ (NSBundle *)classBundle;

/// 获取资源文件的bundle
/// 一、源文件使用，bundle 为 nil
/// 二、使用 famework + bundle，存在资源 bundle
/// 三、Pod 方式使用，根据 podspec 定义的资源文件使用方式存在差异
/// 1、使用 resource_bundles 方式则存在资源 bundle；
/// 2、使用 resources 则不存在 bundle
/// 3、此处 podspec 使用的 resource_bundles 方式，存在bundle
+ (nullable NSBundle *)resourceBundle;

/// 获取资源文件在资源bundle中的路径
/// 一、源文件使用，bundle 为 nil
/// 二、使用 famework + bundle，存在资源 bundle
/// 三、Pod 方式使用，根据 podspec 定义的资源文件使用方式存在差异
/// 1、使用 resource_bundles 方式则存在资源 bundle；
/// 2、使用 resources 则不存在 bundle
/// 3、此处 podspec 使用的 resource_bundles 方式，存在bundle
+ (NSString *)fileInResourceBundle:(NSString *)resourceFile;

/// 从资源bundle中获取图片
/// @param name 图片名称
+ (nullable UIImage *)imageInResourceBundle:(NSString *)name;

/// 获取组件版本
+ (NSString *)version;

@end

NS_ASSUME_NONNULL_END
