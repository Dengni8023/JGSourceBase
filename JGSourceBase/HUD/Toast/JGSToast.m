//
//  JGSToast.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/26.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSToast.h"

@implementation JGSToast

#pragma mark - message
+ (void)showToastWithMessage:(NSString *)message {
    [self showToastWithMessage:message inView:nil];
}

+ (void)showToastWithMessage:(NSString *)message position:(JGSToastPosition)position {
    [self showToastWithMessage:message inView:nil position:position completion:nil];
}

+ (void)showToastWithMessage:(NSString *)message inView:(UIView *)inView {
    [self showToastWithMessage:message inView:inView completion:nil];
}

+ (void)showToastWithMessage:(NSString *)message completion:(void (^)(void))completion {
    [self showToastWithMessage:message inView:nil completion:completion];
}

+ (void)showToastWithMessage:(NSString *)message inView:(UIView *)inView completion:(void (^)(void))completion {
    [self showToastWithMessage:message inView:nil position:[JGSToastStyle sharedStyle].defaultPosition completion:completion];
}

+ (void)showToastWithMessage:(NSString *)message inView:(UIView *)inView position:(JGSToastPosition)position completion:(nullable void (^)(void))completion {
    
    inView = inView ?: [UIApplication sharedApplication].keyWindow;
    [inView jg_showToastWithMessage:message position:position completion:completion];
}

#pragma mark - icon
+ (void)showToastWithIcon:(UIImage *)icon {
    [self showToastWithIcon:icon inView:nil];
}

+ (void)showToastWithIcon:(UIImage *)icon position:(JGSToastPosition)position {
    [self showToastWithIcon:icon inView:nil position:position completion:nil];
}

+ (void)showToastWithIcon:(UIImage *)icon inView:(UIView *)inView {
    [self showToastWithIcon:icon inView:inView completion:nil];
}

+ (void)showToastWithIcon:(UIImage *)icon completion:(void (^)(void))completion {
    [self showToastWithIcon:icon inView:nil completion:completion];
}

+ (void)showToastWithIcon:(UIImage *)icon inView:(UIView *)inView completion:(void (^)(void))completion {
    [self showToastWithIcon:icon inView:inView position:[JGSToastStyle sharedStyle].defaultPosition completion:completion];
}

+ (void)showToastWithIcon:(UIImage *)icon inView:(UIView *)inView position:(JGSToastPosition)position completion:(nullable void (^)(void))completion {
    
    inView = inView ?: [UIApplication sharedApplication].keyWindow;
    [inView jg_showToastWithImage:icon position:position completion:completion];
}

#pragma mark - message & icon
+ (void)showToastWithIcon:(UIImage *)icon message:(NSString *)message {
    [self showToastWithIcon:icon message:message inView:nil];
}

+ (void)showToastWithIcon:(UIImage *)icon message:(NSString *)message inView:(UIView *)inView {
    [self showToastWithIcon:icon message:message inView:inView completion:nil];
}

+ (void)showToastWithIcon:(UIImage *)icon message:(NSString *)message completion:(void (^)(void))completion {
    [self showToastWithIcon:icon message:message inView:nil completion:completion];
}

+ (void)showToastWithIcon:(UIImage *)icon message:(NSString *)message inView:(UIView *)inView completion:(void (^)(void))completion {
    [self showToastWithIcon:icon message:message inView:inView position:[JGSToastStyle sharedStyle].defaultPosition completion:completion];
}

+ (void)showToastWithIcon:(UIImage *)icon message:(NSString *)message inView:(UIView *)inView position:(JGSToastPosition)position completion:(void (^)(void))completion {
    
    inView = inView ?: [UIApplication sharedApplication].keyWindow;
    [inView jg_showToastWithIcon:icon message:message position:position completion:completion];
}

#pragma mark - Hide
+ (void)hideToast {
    [self hideToastInView:nil];
}

+ (void)hideAllToast {
    [self hideAllToastInView:nil];
}

+ (void)hideToastInView:(UIView *)inView {
    
    inView = inView ?: [UIApplication sharedApplication].keyWindow;
    [inView jg_hideToast];
}

+ (void)hideAllToastInView:(UIView *)inView {
    
    inView = inView ?: [UIApplication sharedApplication].keyWindow;
    [inView jg_hideAllToast];
}

#pragma mark - End

@end
