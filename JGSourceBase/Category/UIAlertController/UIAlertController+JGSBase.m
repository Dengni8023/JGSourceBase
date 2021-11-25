//
//  UIAlertController+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/9/14.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import "UIAlertController+JGSBase.h"
#import "JGSBase.h"
#import <objc/runtime.h>

@implementation UIAlertController (JGSBase)

static char kJGSSysAlertControllerWindowKey;
static NSPointerArray *jg_ShowingAlertControllers = nil;

#pragma mark - @property
- (NSInteger)jg_cancelIdx {
    return 0;
}

- (NSInteger)jg_destructiveIdx {
    return 1;
}

- (NSInteger)jg_firstOtherIdx {
    return 2;
}

+ (UIWindow *)jg_SysAlertWindow {
    
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *sysAlertWindow = objc_getAssociatedObject(app, &kJGSSysAlertControllerWindowKey);
    if (!sysAlertWindow) {
        
        sysAlertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        sysAlertWindow.windowLevel = UIWindowLevelAlert;
        
        UIViewController *vcT = [[UIViewController alloc] init];
        vcT.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.18];
        sysAlertWindow.rootViewController = vcT;
        objc_setAssociatedObject(app, &kJGSSysAlertControllerWindowKey, sysAlertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        sysAlertWindow.userInteractionEnabled = YES;
        sysAlertWindow.alpha = 1.f;
        sysAlertWindow.hidden = YES;
    }
    return sysAlertWindow;
}

#pragma mark - Alert
+ (instancetype)jg_alertWithTitle:(NSString *)title message:(NSString *)message {
    return [self jg_alertWithTitle:title message:message cancel:nil];
}

+ (instancetype)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel {
    return [self jg_alertWithTitle:title message:message cancel:cancel action:nil];
}

+ (instancetype)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel other:nil action:action];
}

+ (instancetype)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel other:(NSString *)other action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel others:[NSArray arrayWithObjects:other, nil] action:action];
}

+ (instancetype)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel destructive:nil others:others action:action];
}

+ (instancetype)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel destructive:(NSString *)destructive action:(JGSAlertControllerAction)action {
    return [self jg_alertWithTitle:title message:message cancel:cancel destructive:destructive others:nil action:action];
}

+ (instancetype)jg_alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel destructive:(NSString *)destructive others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    
    return [self jg_showAlertWithTitle:title message:message style:UIAlertControllerStyleAlert cancel:cancel destructive:destructive others:others action:action];
}

#pragma mark - ActionSheet
+ (instancetype)jg_actionSheetWithTitle:(NSString *)title cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_actionSheetWithTitle:title message:nil cancel:cancel destructive:nil others:others action:action];
}

+ (instancetype)jg_actionSheetWithTitle:(NSString *)title message:(NSString *)message others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_actionSheetWithTitle:title message:message cancel:nil destructive:nil others:others action:action];
}

+ (instancetype)jg_actionSheetWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_actionSheetWithTitle:title message:message cancel:cancel destructive:nil others:others action:action];
}

+ (instancetype)jg_actionSheetWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel destructive:(NSString *)destructive others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)action {
    return [self jg_showAlertWithTitle:title message:message style:UIAlertControllerStyleActionSheet cancel:cancel destructive:destructive others:others action:action];
}

#pragma mark - Alert & ActionSheet
+ (instancetype)jg_showAlertWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertControllerStyle)style cancel:(NSString *)cancel destructive:(NSString *)destructive others:(NSArray<NSString *> *)others action:(JGSAlertControllerAction)btnAction {
    
    if (!title && !message && !cancel && !destructive && others.count == 0) {
        NSDictionary *elements = @{
            @"title": title ?: @"nil",
            @"message": message ?: @"nil",
            @"cancel": cancel ?: @"nil",
            @"destructive": destructive ?: @"nil",
            @"others": others ? (others.count > 0 ? others : @"0 action") : @"nil"
        };
        JGSLog(@"UIAlertController must have a title, a message or an action to display. Display elements : %@", elements);
        return nil;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
    
    JGSWeak(alert);
    if (cancel) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            JGSStrong(alert);
            if (btnAction) {
                btnAction(alert, alert.jg_cancelIdx);
            }
            [self refreshAlertWindowSatus];
        }];
        [alert addAction:cancelAction];
    }
    
    if (destructive) {
        UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:destructive style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            JGSStrong(alert);
            if (btnAction) {
                btnAction(alert, alert.jg_destructiveIdx);
            }
            [self refreshAlertWindowSatus];
        }];
        [alert addAction:destructiveAction];
    }
    
    for (NSUInteger i = 0; i < [others count]; i++) {
        
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:others[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            JGSStrong(alert);
            if (btnAction) {
                btnAction(alert, alert.jg_firstOtherIdx + i);
            }
            [self refreshAlertWindowSatus];
        }];
        [alert addAction:otherAction];
    }
    
    [alert jg_Show];
    
    return alert;
}

#pragma mark - Hide
+ (BOOL)jg_hideAllAlert:(BOOL)animated {
    
    [[self jg_SysAlertWindow].rootViewController dismissViewControllerAnimated:animated completion:^{
        [self refreshAlertWindowSatus];
    }];
    
    return jg_ShowingAlertControllers.count > 0;
}

+ (BOOL)jg_hideCurrentAlert:(BOOL)animated {
    
    [jg_ShowingAlertControllers.allObjects.lastObject dismissViewControllerAnimated:animated completion:^{
        [self refreshAlertWindowSatus];
    }];
    
    return jg_ShowingAlertControllers.count > 0;
}

+ (void)refreshAlertWindowSatus {
    
    // 直接执行因为刚刚关闭的Alert内存尚未释放，导致jg_ShowingAlertControllers中仍就存储有该对象，状态无法更新成功
    // 所以此处进行一次线程切换之后来更新状态
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //    jg_SysAlertWindow.hidden = jg_ShowingAlertControllers.allObjects.count == 0;
    //});
    dispatch_async(dispatch_get_main_queue(), ^{
        [self jg_SysAlertWindow].hidden = jg_ShowingAlertControllers.allObjects.count == 0;
    });
    UIAlertController *lastAlert = jg_ShowingAlertControllers.allObjects.lastObject;
    BOOL hide = (jg_ShowingAlertControllers.allObjects.count == 0 || (jg_ShowingAlertControllers.allObjects.count == 1 && lastAlert.presentingViewController == nil));
    if (hide) {
        [UIView animateWithDuration:0.02 animations:^{
            [self jg_SysAlertWindow].alpha = 0.f;
        } completion:^(BOOL finished) {
            [self jg_SysAlertWindow].hidden = hide;
        }];
    }
}

#pragma mark - Private
- (void)jg_Show {
    
    UIWindow *sysAlertWindow = [UIAlertController jg_SysAlertWindow];
    sysAlertWindow.hidden = NO;
    sysAlertWindow.alpha = 1.f;
    
    UIViewController *curCtr = sysAlertWindow.rootViewController;
    while (curCtr.presentedViewController) {
        curCtr = curCtr.presentedViewController;
    }
    if (jg_ShowingAlertControllers == nil) {
        jg_ShowingAlertControllers = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
    }
    [jg_ShowingAlertControllers addPointer:(void *)self];
    
    if (self.popoverPresentationController) {
        [self.popoverPresentationController setSourceView:sysAlertWindow];
        [self.popoverPresentationController setSourceRect:sysAlertWindow.bounds];
        [self.popoverPresentationController setPermittedArrowDirections:(UIPopoverArrowDirection)0]; // 无箭头
    }
    
    [curCtr presentViewController:self animated:YES completion:^{
        
    }];
}

@end
