//
//  UIView+JGSToast.h
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/26.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT CGFloat const JGSToastTopBottomMargin;
typedef NS_ENUM(NSInteger, JGSToastPosition) {
    JGSToastPositionCenter = 0, // 视图居中，默认
    JGSToastPositionTop, // SafeArea顶边距JGSToastStyle.topMargin
    JGSToastPositionUp, // 视图 1/4顶部
    JGSToastPositionLow, // 视图 1/4底部
    JGSToastPositionBottom, // SafeArea底边距JGSToastStyle.bottomMargin
};

/**
 JGSToast默认风格配置
 */
@interface JGSToastStyle : NSObject

@property (nonatomic, assign) JGSToastPosition defaultPosition; // 默认显示位置，默认为JGSToastPositionCenter
@property (nonatomic, assign) CGFloat topMargin; // Toast顶部显示时与顶部间距，默认32
@property (nonatomic, assign) CGFloat bottomMargin; // Toast底部显示时与底部间距，默认32

@property (nonatomic, assign) CGFloat cornerRadius; // Toast圆角，默认2.5
@property (nonatomic, strong, null_resettable) UIColor *backgroundColor; // Toast背景色，默认黑色75%透明度

@property (nonatomic, strong, null_resettable) UIFont *textFont; // Toast文字字体，默认16号系统字体
@property (nonatomic, strong, null_resettable) UIColor *textColor; // Toast文字字色，默认白色
@property (nonatomic, assign) NSUInteger textLines; // Toast文字行数，默认0-不限制行数

@property (nonatomic, assign) CGFloat duration; // Toast可以自动隐藏时显示时间，超过该时间后将隐藏，默认1.2s

+ (instancetype)sharedStyle;

@end

/**
 显示Toast，当completion不为空时，整个inView在Toast未消失时不可点击
 Toast背景完全透明，默认中间框为黑色50%透明度
 */
@interface UIView (JGSToast)

#pragma mark - Message
- (void)jg_showToastWithMessage:(NSString *)message;
- (void)jg_showToastWithMessage:(NSString *)message position:(JGSToastPosition)position;
- (void)jg_showToastWithMessage:(NSString *)message completion:(nullable void (^)(void))completion;
- (void)jg_showToastWithMessage:(NSString *)message position:(JGSToastPosition)position completion:(nullable void (^)(void))completion;

#pragma mark - Icon
- (void)jg_showToastWithImage:(UIImage *)image;
- (void)jg_showToastWithImage:(UIImage *)image position:(JGSToastPosition)position;
- (void)jg_showToastWithImage:(UIImage *)image completion:(nullable void (^)(void))completion;
- (void)jg_showToastWithImage:(UIImage *)image position:(JGSToastPosition)position completion:(nullable void (^)(void))completion;

#pragma mark - IconMessage
- (void)jg_showToastWithIcon:(nullable UIImage *)icon message:(nullable NSString *)message;
- (void)jg_showToastWithIcon:(nullable UIImage *)icon message:(nullable NSString *)message position:(JGSToastPosition)position;
- (void)jg_showToastWithIcon:(nullable UIImage *)icon message:(nullable NSString *)message completion:(nullable void (^)(void))completion;
/** icon message同时存在则单行展示 */
- (void)jg_showToastWithIcon:(nullable UIImage *)icon message:(nullable NSString *)message position:(JGSToastPosition)position completion:(nullable void (^)(void))completion;

#pragma mark - Hide
- (void)jg_hideToast;
- (void)jg_hideAllToast;

@end

NS_ASSUME_NONNULL_END
