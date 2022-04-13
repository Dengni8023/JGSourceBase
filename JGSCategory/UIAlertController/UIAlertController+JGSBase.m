//
//  UIAlertController+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/9/14.
//  Copyright © 2021 MeiJiGao. All rights reserved.
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
        // 此处直接设置为透明，alert 展示时系统默认增加半透明背景色
        // 如果手动设备自定义背景色，存在 alert 消失时自定义背景色仍旧存在情况
        // 自定义背景色在状态更新动画结束才会消失，影响用户体验
        vcT.view.backgroundColor = [UIColor clearColor];
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
    
    // 直接执行因为刚刚关闭的 alert 内存尚未释放，presentingViewController 仍旧被 alert 持有
    // 导致 jg_ShowingAlertControllers.allObjects 中仍存储有该alert对象
    // 无法根据 alert 的内存、presentingViewController 成功进行释放清理
    // 此处进行一次线程切换以更新 laert的 内存、presentingViewController 状态
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (NSInteger i = jg_ShowingAlertControllers.count - 1; i >= 0; i--) {
            // 对内存已释放、或 presentingViewController 为 nil 的 alert 进行清理
            UIAlertController *alert = [jg_ShowingAlertControllers pointerAtIndex:i];
            if (alert == nil || alert.presentingViewController == nil) {
                // 因存在外部短时间调用多个 alert 展示
                // alert 展示动画执行过程中调用 alert展示，存在不会实际展示出来的情况
                // 如：存在短时内依次调用展示1、2、3三个 alert，但是存在仅1、3展示出来的情况
                // 因此此处遍历需要遍历所有存储的 alert 对象，不能 break
                [jg_ShowingAlertControllers removePointerAtIndex:i];
            }
        }
        
        if (jg_ShowingAlertControllers.allObjects.count == 0) {
            
            // 动画开始时 alert 已完全消失
            // 动画结束前，透明窗仍旧存在，用户无法操作界面
            // 如定义了根控制器视图的背景色，则动画过程有一个颜色渐变消失的动
            [UIView animateWithDuration:0.02 animations:^{
                [self jg_SysAlertWindow].alpha = 0.f;
            } completion:^(BOOL finished) {
                [self jg_SysAlertWindow].hidden = YES;
            }];
        }
    });
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

#pragma mark - End

@end
