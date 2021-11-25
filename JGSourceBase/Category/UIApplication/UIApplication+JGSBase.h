//
//  UIApplication+JGSBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2021/3/19.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN UIViewController * _Nullable  JGSTopViewController(UIViewController *rootViewController);
@interface UIApplication (JGSBase)

/// 应用层最顶层显示的ViewController，不包含系统弹窗
@property (nonatomic, copy, readonly, nullable) UIViewController *jg_topViewController;

/// 显示层最顶层显示的ViewController，包含系统弹窗
@property (nonatomic, copy, readonly, nullable) UIViewController *jg_visibleViwController;

@end

NS_ASSUME_NONNULL_END
