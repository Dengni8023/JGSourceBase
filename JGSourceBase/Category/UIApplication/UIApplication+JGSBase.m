//
//  UIApplication+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/3/19.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import "UIApplication+JGSBase.h"
#import <objc/message.h>
#import "JGSourceBase.h"

FOUNDATION_EXTERN UIViewController *JGSTopViewController(UIViewController *rootViewController) {
    
    UIViewController *topCtr = rootViewController;
    while (topCtr.presentedViewController) {
        topCtr = topCtr.presentedViewController;
    }
    
    if ([topCtr isKindOfClass:[UINavigationController class]]) {
        return JGSTopViewController([(UINavigationController *)topCtr visibleViewController]);
    }
    else if ([topCtr isKindOfClass:[UITabBarController class]]) {
        return JGSTopViewController([(UITabBarController *)topCtr selectedViewController]);
    }
    return topCtr;
}

@implementation UIApplication (JGSBase)

- (UIViewController *)jg_topViewController {
    
    // UIAlertController、UIAlertView、UIActionSheet弹出后
    // 这些View 出现生成了一个新的window，加在了界面上面
    // keyWindow就会变成UIAlertControllerShimPresenterWindow这个类
    // delegate、keyWindow、rootViewController均需在主线程获取
    id<UIApplicationDelegate> app = [UIApplication sharedApplication].delegate;
    SEL selector = NSSelectorFromString(@"window");
    UIWindow *appWindow = ((id (*)(id, SEL))objc_msgSend)(app, selector);
    if (appWindow) {
        
        UIViewController *vcT = appWindow.rootViewController;
        UIViewController *topCtr = JGSTopViewController(vcT);
        return topCtr;
    }
    
    appWindow = [UIApplication sharedApplication].windows.firstObject;
    UIViewController *vcT = appWindow.rootViewController;
    UIViewController *topCtr = JGSTopViewController(vcT);
    return topCtr;
}

- (UIViewController *)jg_visibleViwController {
    
    // UIAlertController、UIAlertView、UIActionSheet弹出后
    // 这些View 出现生成了一个新的window，加在了界面上面
    // keyWindow就会变成UIAlertControllerShimPresenterWindow这个类
    // delegate、keyWindow、rootViewController均需在主线程获取
    UIViewController *vcT = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topCtr = JGSTopViewController(vcT);
    
    //JGSLog(@"keyWindow: %p", [UIApplication sharedApplication].keyWindow);
    
    return topCtr;
}

#pragma mark - End

@end
