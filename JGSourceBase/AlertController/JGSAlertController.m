//
//  JGSAlertController.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSAlertController.h"
#import "JGSourceBase.h"

@implementation JGSAlertController

#pragma mark - Alert
+ (BOOL)hideAlert {
    return [UIAlertController jg_hideAllAlert:YES];
}

+ (UIAlertController *)alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message {
    return [self alertWithTitle:title message:message cancel:nil];
}

+ (UIAlertController *)alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel {
    return [self alertWithTitle:title message:message cancel:cancel action:nil];
}

+ (UIAlertController *)alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel action:(JGSAlertControllerAction)action {
    return [self alertWithTitle:title message:message cancel:cancel other:nil action:action];
}

+ (UIAlertController *)alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel other:(NSString *)other action:(JGSAlertControllerAction)action {
    return [self alertWithTitle:title message:message cancel:cancel others:[NSArray arrayWithObjects:other, nil] action:action];
}

+ (UIAlertController *)alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel destructive:(NSString *)destructive action:(JGSAlertControllerAction)action {
    return [self alertWithTitle:title message:message cancel:cancel destructive:destructive others:nil action:action];
}

+ (UIAlertController *)alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self alertWithTitle:title message:message cancel:cancel destructive:nil others:others action:action];
}

+ (UIAlertController *)alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel destructive:(NSString *)destructive others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self shoWithTitle:title message:message style:UIAlertControllerStyleAlert cancel:cancel destructive:destructive others:others action:action];
}

#pragma mark - ActionSheet
+ (UIAlertController *)actionSheetWithTitle:(NSString *)title cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self actionSheetWithTitle:title cancel:cancel destructive:nil others:others action:action];
}

+ (UIAlertController *)actionSheetWithTitle:(NSString *)title cancel:(NSString *)cancel destructive:(NSString *)destructive others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self shoWithTitle:title message:nil style:UIAlertControllerStyleActionSheet cancel:cancel destructive:destructive others:others action:action];
}

#pragma mark - UIAlertController
+ (UIAlertController *)shoWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertControllerStyle)style cancel:(NSString *)cancel destructive:(NSString *)destructive others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [UIAlertController jg_showAlertWithTitle:title message:message style:style cancel:cancel destructive:destructive others:others action:action];
}

#pragma mark - End

@end
