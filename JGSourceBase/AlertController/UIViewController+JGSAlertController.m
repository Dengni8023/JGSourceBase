//
//  UIViewController+JGSAlertController.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJiGao. All rights reserved.
//

#import "UIViewController+JGSAlertController.h"
#import "JGSourceBase.h"

@implementation UIViewController (JGSAlertController)

#pragma mark - Alert
- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message {
    return [self jg_alertWithTitle:title message:message cancel:nil];
}

- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel {
    return [self jg_alertWithTitle:title message:message cancel:cancel action:nil];
}

- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel other:nil action:action];
}

- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel other:(NSString *)other action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel others:[NSArray arrayWithObjects:other, nil] action:action];
}

- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel destructive:nil others:others action:action];
}

- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel destructive:(NSString *)destructive action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel destructive:destructive others:nil action:action];
}

- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel destructive:(NSString *)destructive others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_showAlertWithTitle:title message:message style:UIAlertControllerStyleAlert cancel:cancel destructive:destructive others:others action:action];
}

#pragma mark - ActionSheet
- (UIAlertController *)jg_actionSheetWithTitle:(NSString *)title cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_actionSheetWithTitle:title cancel:cancel destructive:nil others:others action:action];
}

- (UIAlertController *)jg_actionSheetWithTitle:(NSString *)title cancel:(NSString *)cancel destructive:(NSString *)destructive others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_showAlertWithTitle:title message:nil style:UIAlertControllerStyleActionSheet cancel:cancel destructive:destructive others:others action:action];
}

#pragma mark - Alert & ActionSheet
- (UIAlertController *)jg_showAlertWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertControllerStyle)style cancel:(NSString *)cancel destructive:(NSString *)destructive others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [UIAlertController jg_showAlertWithTitle:title message:message style:style cancel:cancel destructive:destructive others:others action:action];
}

#pragma mark - Hide
- (BOOL)jg_hideCurrentAlert:(BOOL)animated {
    return [UIAlertController jg_hideCurrentAlert:animated];
}

#pragma mark - End

@end
