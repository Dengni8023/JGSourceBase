//
//  JGSToast.h
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/26.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+JGSToast.h"

NS_ASSUME_NONNULL_BEGIN

/**
 显示Toast，当completion不为空时，整个inView在Toast未消失时不可点击
 Toast背景完全透明，中间框为黑色50%透明度
 */
@interface JGSToast : NSObject

#pragma mark - Message
+ (void)showToastWithMessage:(NSString *)message;
+ (void)showToastWithMessage:(NSString *)message position:(JGSToastPosition)position;
+ (void)showToastWithMessage:(NSString *)message inView:(nullable UIView *)inView;
+ (void)showToastWithMessage:(NSString *)message completion:(nullable void (^)(void))completion;
+ (void)showToastWithMessage:(NSString *)message inView:(nullable UIView *)inView completion:(nullable void (^)(void))completion;
+ (void)showToastWithMessage:(NSString *)message inView:(nullable UIView *)inView position:(JGSToastPosition)position completion:(nullable void (^)(void))completion;

#pragma mark - Icon
+ (void)showToastWithIcon:(UIImage *)icon;
+ (void)showToastWithIcon:(UIImage *)icon position:(JGSToastPosition)position;
+ (void)showToastWithIcon:(UIImage *)icon inView:(nullable UIView *)inView;
+ (void)showToastWithIcon:(UIImage *)icon completion:(nullable void (^)(void))completion;
+ (void)showToastWithIcon:(UIImage *)icon inView:(nullable UIView *)inView completion:(nullable void (^)(void))completion;
+ (void)showToastWithIcon:(UIImage *)icon inView:(nullable UIView *)inView position:(JGSToastPosition)position completion:(nullable void (^)(void))completion;

#pragma mark - Custom View
+ (void)showToastWithIcon:(nullable UIImage *)icon message:(nullable NSString *)message;
+ (void)showToastWithIcon:(nullable UIImage *)icon message:(nullable NSString *)message inView:(nullable UIView *)inView;
+ (void)showToastWithIcon:(nullable UIImage *)icon message:(nullable NSString *)message completion:(nullable void (^)(void))completion;
+ (void)showToastWithIcon:(nullable UIImage *)icon message:(nullable NSString *)message inView:(nullable UIView *)inView completion:(nullable void (^)(void))completion;
/** icon message同时存在则单行展示 */
+ (void)showToastWithIcon:(nullable UIImage *)icon message:(nullable NSString *)message inView:(nullable UIView *)inView position:(JGSToastPosition)position completion:(nullable void (^)(void))completion;

+ (void)hideToast; // 隐藏Keywindow最先的一条Toast
+ (void)hideAllToast; // 隐藏Keywindow所有Toast
+ (void)hideToastInView:(nullable UIView *)inView; // 隐藏最先的一条Toast
+ (void)hideAllToastInView:(nullable UIView *)inView; // 隐藏所有Toast

@end

NS_ASSUME_NONNULL_END
