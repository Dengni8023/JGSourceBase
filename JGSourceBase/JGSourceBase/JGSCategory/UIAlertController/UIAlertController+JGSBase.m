//
//  UIAlertController+JGSBase.m
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/21.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import "UIAlertController+JGSBase.h"
#if __has_include(<JGSourceBase/JGSourceBase-Swift.h>)
#import <JGSourceBase/JGSourceBase-Swift.h>
#elif __has_include("JGSourceBase-Swift.h")
#import "JGSourceBase-Swift.h"
#endif

@implementation UIAlertController (JGSBase)

#pragma mark - Alert
/// 调用带 cancel 参数的重载方法，cancel 传 nil 表示不显示取消按钮
+ (instancetype)jg_alertWithTitle:(NSString *)title message:(NSString *)message {
    return [self jg_alertWithTitle:title message:message cancel:nil];
}

/// 调用带 action 参数的重载方法，action 传 nil 表示无点击响应
+ (instancetype)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel {
    return [self jg_alertWithTitle:title message:message cancel:cancel action:nil];
}

/// 调用带 other 参数的重载方法，other 传 nil 表示不显示确定按钮
+ (instancetype)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel other:nil action:action];
}

/// 将单个 other 按钮包装成数组，调用多按钮重载方法
+ (instancetype)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel other:(NSString *)other action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel others:[NSArray arrayWithObjects:other, nil] action:action];
}

/// 调用带 destructive 参数的重载方法，destructive 传 nil 表示不显示警告按钮
+ (instancetype)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel destructive:nil others:others action:action];
}

/// 将 destructive 按钮包装成单元素数组，调用多按钮重载方法
+ (instancetype)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel destructive:(NSString *)destructive action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel destructive:destructive others:@[] action:action];
}

#pragma mark - ActionSheet
/// 调用完整参数的重载方法，message 和 destructive 传 nil
+ (instancetype)jg_actionSheetWithTitle:(NSString *)title cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_actionSheetWithTitle:title message:nil cancel:cancel destructive:nil others:others action:action];
}

/// 调用完整参数的重载方法，cancel 和 destructive 传 nil
+ (instancetype)jg_actionSheetWithTitle:(NSString *)title message:(NSString *)message others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_actionSheetWithTitle:title message:message cancel:nil destructive:nil others:others action:action];
}

/// 调用完整参数的重载方法，destructive 传 nil
+ (instancetype)jg_actionSheetWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_actionSheetWithTitle:title message:message cancel:cancel destructive:nil others:others action:action];
}

#pragma mark - Hide
/// 调用 Swift 实现的 jg_hideAll:from: 方法，from 传 nil 表示全局隐藏
+ (BOOL)jg_hideAllAlert:(BOOL)animated {
    return [UIAlertController jg_hideAll:animated from:nil];
}

/// 调用带默认动画的隐藏方法
+ (BOOL)jg_hideAll {
    return [UIAlertController jg_hideAll:YES from:nil];
}

/// 调用 Swift 实现的 jg_hideCurrent:from: 方法，from 传 nil 表示全局隐藏
+ (BOOL)jg_hideCurrentAlert:(BOOL)animated {
    return [UIAlertController jg_hideCurrent:animated from:nil];
}

/// 调用带默认动画的隐藏当前弹窗方法
+ (BOOL)jg_hideCurrent {
    return [UIAlertController jg_hideCurrent:YES from:nil];
}

@end

#pragma mark - UIView (JGSAlertController)

@implementation UIView (JGSAlertController)

#pragma mark - Alert
/// 链式调用，传 nil cancel 表示不显示取消按钮
- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message {
    return [self jg_alertWithTitle:title message:message cancel:nil];
}

/// 链式调用，传 nil action 表示无点击响应
- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel {
    return [self jg_alertWithTitle:title message:message cancel:cancel action:nil];
}

/// 链式调用，传 nil other 表示不显示确定按钮
- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel other:nil action:action];
}

/// 将单个 other 按钮包装成数组
- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel other:(NSString *)other action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel others:[NSArray arrayWithObjects:other, nil] action:action];
}

/// 链式调用，传 nil destructive 表示不显示警告按钮
- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel destructive:nil others:others action:action];
}

/// 将 destructive 按钮包装成空数组
- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel destructive:(NSString *)destructive action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel destructive:destructive others:@[] action:action];
}

#pragma mark - ActionSheet
/// 链式调用，补全 message 和 destructive 参数为 nil
- (UIAlertController *)jg_actionSheetWithTitle:(NSString *)title cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_actionSheetWithTitle:title message:nil cancel:cancel others:others action:action];
}

/// 链式调用，补全 cancel 和 destructive 参数为 nil
- (UIAlertController *)jg_actionSheetWithTitle:(NSString *)title message:(NSString *)message others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_actionSheetWithTitle:title message:message cancel:nil others:others action:action];
}

/// 链式调用，补全 destructive 参数为 nil
- (UIAlertController *)jg_actionSheetWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_actionSheetWithTitle:title message:message cancel:cancel destructive:nil others:others action:action];
}

#pragma mark - Hide
/// 默认执行动画隐藏所有弹窗
- (BOOL)jg_hideAllAlert {
    return [self jg_hideAllAlert:YES];
}

/// 默认执行动画隐藏当前弹窗
- (BOOL)jg_hideCurrentAlert {
    return [self jg_hideCurrentAlert:YES];
}

@end

#pragma mark - UIViewController (JGSAlertController)

@implementation UIViewController (JGSAlertController)

#pragma mark - Alert
/// 链式调用，传 nil cancel 表示不显示取消按钮
- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message {
    return [self jg_alertWithTitle:title message:message cancel:nil];
}

/// 链式调用，传 nil action 表示无点击响应
- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel {
    return [self jg_alertWithTitle:title message:message cancel:cancel action:nil];
}

/// 链式调用，传 nil other 表示不显示确定按钮
- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel other:nil action:action];
}

/// 将单个 other 按钮包装成数组
- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel other:(NSString *)other action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel others:[NSArray arrayWithObjects:other, nil] action:action];
}

/// 链式调用，传 nil destructive 表示不显示警告按钮
- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel destructive:nil others:others action:action];
}

/// 将 destructive 按钮包装成空数组
- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel destructive:(NSString *)destructive action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel destructive:destructive others:@[] action:action];
}

#pragma mark - ActionSheet
/// 链式调用，补全 message 和 destructive 参数为 nil
- (UIAlertController *)jg_actionSheetWithTitle:(NSString *)title cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_actionSheetWithTitle:title message:nil cancel:cancel others:others action:action];
}

/// 链式调用，补全 cancel 和 destructive 参数为 nil
- (UIAlertController *)jg_actionSheetWithTitle:(NSString *)title message:(NSString *)message others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_actionSheetWithTitle:title message:message cancel:nil others:others action:action];
}

/// 链式调用，补全 destructive 参数为 nil
- (UIAlertController *)jg_actionSheetWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_actionSheetWithTitle:title message:message cancel:cancel destructive:nil others:others action:action];
}

#pragma mark - Hide
/// 默认执行动画隐藏所有弹窗，内部调用 self.view 的对应方法
- (BOOL)jg_hideAllAlert {
    return [self jg_hideAllAlert:YES];
}

/// 默认执行动画隐藏当前弹窗，内部调用 self.view 的对应方法
- (BOOL)jg_hideCurrentAlert {
    return [self jg_hideCurrentAlert:YES];
}

@end
