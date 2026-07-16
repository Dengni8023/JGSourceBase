//
//  JGSBase.h
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/18.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#ifndef JGSBase_h
#define JGSBase_h

#if __has_include(<JGSourceBase/JGSBase.h>)
#import <JGSourceBase/JGSBaseUtils.h>
#import <JGSourceBase/JGSIgnoreWarning.h>
#import <JGSourceBase/JGSLogger.h>
#import <JGSourceBase/JGSWeakStrong.h>
#elif __has_include("JGSBase.h")
//#else
#import "JGSBaseUtils.h"
#import "JGSIgnoreWarning.h"
#import "JGSLogger.h"
#import "JGSWeakStrong.h"
#endif

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
#define JGSIsPadUI         (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) // 判断是否为iPad界面
#define JGSDeviceScale     [UIScreen mainScreen].scale // 获取设备的分辨率倍数
#define JGSMinimumPoint    (1.f / JGSDeviceScale) // 计算最小显示点单位

#endif /* JGSBase_h */
