//
//  JGSLoadingHUD.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/26.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSLoadingHUD.h"

@implementation JGSLoadingHUD

#pragma mark - Message
+ (void)showLoadingHUD {
    [self showLoadingHUD:nil];
}

+ (void)showLoadingHUDInView:(UIView *)inView {
    [self showLoadingHUD:nil inView:inView];
}

+ (void)showLoadingHUD:(NSString *)message {
    [self showLoadingHUD:message inView:nil];
}

+ (void)showLoadingHUD:(NSString *)message inView:(UIView *)inView {
    inView = inView ?: [UIApplication sharedApplication].keyWindow;
    [inView jg_showLoadingHUDWithMessage:message];
}

#pragma mark - Indicator
+ (void)showIndicatorLoadingHUD {
    [self showIndicatorLoadingHUD:nil];
}

+ (void)showIndicatorLoadingHUDInView:(UIView *)inView {
    [self showIndicatorLoadingHUD:nil inView:inView];
}

+ (void)showIndicatorLoadingHUD:(NSString *)message {
    [self showIndicatorLoadingHUD:message inView:nil];
}

+ (void)showIndicatorLoadingHUD:(NSString *)message inView:(UIView *)inView {
    inView = inView ?: [UIApplication sharedApplication].keyWindow;
    [inView jg_showLoadingHUDWithType:JGSHUDTypeIndicator message:message];
}

#pragma mark - Indicator
+ (void)showSpinningLoadingHUD {
    [self showSpinningLoadingHUD:nil];
}

+ (void)showSpinningLoadingHUDInView:(UIView *)inView {
    [self showSpinningLoadingHUD:nil inView:inView];
}

+ (void)showSpinningLoadingHUD:(NSString *)message {
    [self showSpinningLoadingHUD:message inView:nil];
}

+ (void)showSpinningLoadingHUD:(NSString *)message inView:(UIView *)inView {
    inView = inView ?: [UIApplication sharedApplication].keyWindow;
    [inView jg_showLoadingHUDWithType:JGSHUDTypeSpinningCircle message:message];
}

#pragma mark - Show
+ (void)showLoadingHUD:(JGSHUDType)type message:(NSString *)message {
    [self showLoadingHUD:type message:message inView:nil];
}

+ (void)showLoadingHUD:(JGSHUDType)type message:(NSString *)message inView:(UIView *)inView {
    inView = inView ?: [UIApplication sharedApplication].keyWindow;
    [inView jg_showLoadingHUDWithType:type message:message];
}

+ (void)hideLoading {
    [self hideLoadingInView:nil];
}
+ (void)hideAllLoading {
    [self hideAllLoadingInView:nil];
}

+ (void)hideLoadingInView:(UIView *)inView {
    inView = inView ?: [UIApplication sharedApplication].keyWindow;
    [inView jg_hideLoading];
}

+ (void)hideAllLoadingInView:(UIView *)inView {
    inView = inView ?: [UIApplication sharedApplication].keyWindow;
    [inView jg_hideAllLoading];
}

#pragma mark - End

@end
