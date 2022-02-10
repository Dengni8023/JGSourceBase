//
//  JGSLoadingHUD.h
//  JGSHUD
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef JGSHUD_Loading
#define JGSHUD_Loading

#if __has_include(<JGSHUD/JGSLoadingHUD.h>)
#import <JGSHUD/UIView+JGSLoadingHUD.h>
#else
#import "UIView+JGSLoadingHUD.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface JGSLoadingHUD : NSObject

+ (void)showLoadingHUD;
+ (void)showLoadingHUDInView:(nullable UIView *)inView;
+ (void)showLoadingHUD:(nullable NSString *)message;
+ (void)showLoadingHUD:(nullable NSString *)message inView:(nullable UIView *)inView;

+ (void)showIndicatorLoadingHUD;
+ (void)showIndicatorLoadingHUDInView:(nullable UIView *)inView;
+ (void)showIndicatorLoadingHUD:(nullable NSString *)message;
+ (void)showIndicatorLoadingHUD:(nullable NSString *)message inView:(nullable UIView *)inView;

+ (void)showSpinningLoadingHUD;
+ (void)showSpinningLoadingHUDInView:(nullable UIView *)inView;
+ (void)showSpinningLoadingHUD:(nullable NSString *)message;
+ (void)showSpinningLoadingHUD:(nullable NSString *)message inView:(nullable UIView *)inView;

+ (void)showLoadingHUD:(JGSHUDType)type message:(nullable NSString *)message;
+ (void)showLoadingHUD:(JGSHUDType)type message:(nullable NSString *)message inView:(nullable UIView *)inView;

+ (void)hideLoading;
+ (void)hideAllLoading;

+ (void)hideLoadingInView:(nullable UIView *)inView;
+ (void)hideAllLoadingInView:(nullable UIView *)inView;

@end

NS_ASSUME_NONNULL_END

#endif
