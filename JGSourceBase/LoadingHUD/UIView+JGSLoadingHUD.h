//
//  UIView+JGSLoadingHUD.h
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/26.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JGSHUDType) {
    JGSHUDTypeIndicator = 0, // 使用系统的UIActivityIndicatorView
    JGSHUDTypeSpinningCircle, // 使用JGSSpinningCircle
    JGSHUDTypeCustomView, // 自定义View
};

/**
 JGSLoadingHUD默认风格配置
 */
@interface JGSLoadingHUDStyle : NSObject

@property (nonatomic, strong, null_resettable) UIColor *backgroundColor; // HUD背景色，默认黑色28%透明度

@property (nonatomic, assign) JGSHUDType defaultType; // 默认展示HUD类型，默认JGSHUDTypeSpinningCircle
@property (nonatomic, strong, nullable) UIView *customView; // 展示类行为JGSHUDTypeCustomView时的自定义View

@property (nonatomic, assign) CGFloat bezelCornerRadius; // HUD中间框圆角，默认2.5
@property (nonatomic, strong, null_resettable) UIColor *bezelBackgroundColor; // HUD中间框背景色，默认28%白色，透明度90%

@property (nonatomic, strong, null_resettable) UIColor *indicatorColor; // JGSHUDTypeIndicator样式indicator颜色，默认白色

// SpinningCircle
@property (nonatomic, assign) CGFloat spinningRadius; // 圆环半径，默认32
@property (nonatomic, strong, null_resettable) UIColor *spinningLineColor; // 圆环颜色，默认RGBA {50, 155, 255, 1.0}
@property (nonatomic, assign) CGFloat spinningLineWidth; // 圆环线宽，默认2.0
@property (nonatomic, assign) BOOL spinningShadow; // 是否带模糊阴影，模糊半径为圆环线宽
@property (nonatomic, assign) CGFloat spinningDuration; // 动画执行旋转一圈所用时间，默认 M_PI_4

@property (nonatomic, strong, null_resettable) UIFont *textFont; // HUD文字字体，默认14号系统字体
@property (nonatomic, strong, null_resettable) UIColor *textColor; // HUD文字字色，默认白色，
@property (nonatomic, assign) NSUInteger textLines; // HUD文字行数，默认0-不限制行数

@property (nonatomic, assign) BOOL square; // HUD中间框是否为正方形
@property (nonatomic, assign) CGFloat bezelSquareWidthThanHeight; // HUD中间框默认为正方形，当square为NO且存在文字且宽大于高超过该值则长方形显示，默认32

+ (instancetype)sharedStyle;

@end

@interface UIView (JGSLoadingHUD)

- (void)jg_showLoadingHUD;
- (void)jg_showLoadingHUDWithMessage:(nullable NSString *)message;
- (void)jg_showLoadingHUDWithType:(JGSHUDType)type message:(nullable NSString *)message;

- (void)jg_hideLoading;
- (void)jg_hideAllLoading;

@end

NS_ASSUME_NONNULL_END
