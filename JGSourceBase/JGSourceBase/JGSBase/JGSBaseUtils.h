//
//  JGSBaseUtils.h
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/27.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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

NS_ASSUME_NONNULL_END
