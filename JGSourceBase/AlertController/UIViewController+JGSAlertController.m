//
//  UIViewController+JGSAlertController.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "UIViewController+JGSAlertController.h"
#import "JGSBase.h"

@implementation UIViewController (JGSAlertController)

#pragma mark - Alert
- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message {
    return [self jg_alertWithTitle:title message:message cancel:nil];
}

- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel {
    return [self jg_alertWithTitle:title message:message cancel:cancel btnAction:nil];
}

- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel btnAction:(JGSAlertControllerAction)btnAction {
    return [self jg_alertWithTitle:title message:message cancel:cancel other:nil btnAction:btnAction];
}

- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel other:(NSString *)other btnAction:(JGSAlertControllerAction)btnAction {
    return [self jg_alertWithTitle:title message:message cancel:cancel others:[NSArray arrayWithObjects:other, nil] btnAction:btnAction];
}

- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel others:(NSArray<NSString *> *)others btnAction:(JGSAlertControllerAction)btnAction {
    return [self jg_alertWithTitle:title message:message cancel:cancel destructive:nil others:others btnAction:btnAction];
}

- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel destructive:(NSString *)destructive btnAction:(JGSAlertControllerAction)btnAction {
    return [self jg_alertWithTitle:title message:message cancel:cancel destructive:destructive others:nil btnAction:btnAction];
}

- (UIAlertController *)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel destructive:(NSString *)destructive others:(NSArray<NSString *> *)others btnAction:(JGSAlertControllerAction)btnAction {
    return [self jg_showAlertWithTitle:title message:message style:UIAlertControllerStyleAlert cancel:cancel destructive:destructive others:others btnAction:btnAction];
}

#pragma mark - ActionSheet
- (UIAlertController *)jg_actionSheetWithTitle:(NSString *)title cancel:(NSString *)cancel others:(NSArray<NSString *> *)others btnAction:(JGSAlertControllerAction)btnAction {
    return [self jg_actionSheetWithTitle:title cancel:cancel destructive:nil others:others btnAction:btnAction];
}

- (UIAlertController *)jg_actionSheetWithTitle:(NSString *)title cancel:(NSString *)cancel destructive:(NSString *)destructive others:(NSArray<NSString *> *)others btnAction:(JGSAlertControllerAction)btnAction {
    return [self jg_showAlertWithTitle:title message:nil style:UIAlertControllerStyleActionSheet cancel:cancel destructive:destructive others:others btnAction:btnAction];
}

#pragma mark - Alert & ActionSheet
- (UIAlertController *)jg_showAlertWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertControllerStyle)style cancel:(NSString *)cancel destructive:(NSString *)destructive others:(NSArray<NSString *> *)others btnAction:(JGSAlertControllerAction)btnAction {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
    
    JGSWeak(alert);
    if (cancel) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            JGSStrong(alert);
            if (btnAction) {
                btnAction(alert, alert.jg_cancelIdx);
            }
        }];
        [alert addAction:cancelAction];
    }
    
    if (destructive) {
        UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:destructive style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            JGSStrong(alert);
            if (btnAction) {
                btnAction(alert, alert.jg_destructiveIdx);
            }
        }];
        [alert addAction:destructiveAction];
    }
    
    for (NSUInteger i = 0; i < [others count]; i++) {
        
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:others[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            JGSStrong(alert);
            if (btnAction) {
                btnAction(alert, alert.jg_firstOtherIdx + i);
            }
        }];
        [alert addAction:otherAction];
    }
    
    if (alert.popoverPresentationController) {
        [alert.popoverPresentationController setSourceView:self.view];
        [alert.popoverPresentationController setSourceRect:self.view.bounds];
        [alert.popoverPresentationController setPermittedArrowDirections:(UIPopoverArrowDirection)0];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
    
    return alert;
}

#pragma mark - Hide
- (BOOL)jg_hideCurrentAlert:(BOOL)animated {
    
    if (self.presentedViewController && [self.presentedViewController isKindOfClass:[UIAlertController class]]) {
        [self.presentedViewController dismissViewControllerAnimated:animated completion:^{
            
        }];
        return YES;
    }
    return NO;
}

@end

@implementation UIAlertController (JGSAlertController)

- (NSInteger)jg_cancelIdx {
    return 0;
}

- (NSInteger)jg_destructiveIdx {
    return 1;
}

- (NSInteger)jg_firstOtherIdx {
    return 2;
}

@end
