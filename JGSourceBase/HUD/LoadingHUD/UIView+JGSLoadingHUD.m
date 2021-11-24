//
//  UIView+JGSLoadingHUD.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/26.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "UIView+JGSLoadingHUD.h"
#import "MBProgressHUD.h"
#import "JGSCategory.h"

@implementation JGSLoadingHUDStyle

+ (instancetype)sharedStyle {
    
    static JGSLoadingHUDStyle *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        
        instance.defaultType = JGSHUDTypeSpinningCircle;
        instance.bezelCornerRadius = 5.f;
        instance.spinningRadius = 28.f;
        instance.spinningLineWidth = 2.f;
        instance.spinningShadow = NO;
        instance.spinningDuration = M_PI_4;
        instance.textLines = 0;
        instance.square = YES;
        instance.bezelSquareWidthThanHeight = 28;
    });
    return instance;
}

- (UIColor *)backgroundColor {
    return _backgroundColor ?: [[UIColor blackColor] colorWithAlphaComponent:0.28];
}

- (UIColor *)bezelBackgroundColor {
    return _bezelBackgroundColor ?: [UIColor colorWithWhite:0.28 alpha:0.9];
}

- (UIColor *)indicatorColor {
    return _indicatorColor ?: [UIColor whiteColor];
}

- (UIColor *)spinningLineColor {
    return _spinningLineColor ?: JGSColorRGB(50, 155, 255);
}

- (UIFont *)textFont {
    return _textFont ?: [UIFont systemFontOfSize:14];
}

- (UIColor *)textColor {
    return _textColor ?: [UIColor whiteColor];
}

@end

/** 旋转圆环 */
@interface JGSSpinningCircle : UIView

@property (nonatomic, strong, null_resettable) UIColor *lineColor; // 圆环颜色，默认RGBA {50, 155, 255, 1.0}
@property (nonatomic, assign) CGFloat lineWidth; // 圆环线宽，默认2.0
@property (nonatomic, assign) BOOL isAnimating; // 是否执行动画
@property (nonatomic, assign) BOOL hasShadow; // 是否带模糊阴影，模糊半径为圆环线宽
@property (nonatomic, assign) CGFloat duration; // 动画执行旋转一圈所用时间，默认 M_PI_4
@property (nonatomic, assign) CGFloat progress; // 重绘时增加弧度角度

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/**
 带颜色圆环，默认弧度角度为
 
 @param radius 圆环半径，默认25
 @return instancetype
 */
- (instancetype)initWithRudius:(CGFloat)radius;

@end

@implementation UIView (JGSLoadingHUD)

static NSPointerArray *JGSLoadingHUDStack = nil;
+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        JGSLoadingHUDStack = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
    });
}

#pragma mark - Show
- (void)jg_showLoadingHUD {
    [self jg_showLoadingHUDWithType:[JGSLoadingHUDStyle sharedStyle].defaultType message:nil];
}

- (void)jg_showLoadingHUDWithMessage:(NSString *)message {
    [self jg_showLoadingHUDWithType:[JGSLoadingHUDStyle sharedStyle].defaultType message:message];
}

- (void)jg_showLoadingHUDWithType:(JGSHUDType)type message:(NSString *)message {
    
    [self jg_hideAllLoading];
    if (type == JGSHUDTypeCustomView && ![JGSLoadingHUDStyle sharedStyle].customView) {
        type = JGSHUDTypeIndicator;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    [JGSLoadingHUDStack addPointer:(void *)hud];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = nil;
    hud.label.text = message ? [NSString stringWithFormat:@"\n%@", message] : nil;
    
    switch (type) {
        case JGSHUDTypeIndicator: {
            UIActivityIndicatorView *appearance = [UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[MBProgressHUD class]]];
            appearance.color = [JGSLoadingHUDStyle sharedStyle].indicatorColor;
            hud.mode = MBProgressHUDModeIndeterminate;
        }
            break;
            
        case JGSHUDTypeSpinningCircle: {
            JGSSpinningCircle *circle = [[JGSSpinningCircle alloc] initWithRudius:[JGSLoadingHUDStyle sharedStyle].spinningRadius];
            circle.lineColor = [JGSLoadingHUDStyle sharedStyle].spinningLineColor;
            circle.lineWidth = [JGSLoadingHUDStyle sharedStyle].spinningLineWidth;
            circle.hasShadow = [JGSLoadingHUDStyle sharedStyle].spinningShadow;
            circle.duration = [JGSLoadingHUDStyle sharedStyle].spinningDuration;
            hud.customView = circle;
            circle.isAnimating = YES;
        }
            break;
            
        case JGSHUDTypeCustomView: {
            hud.customView = [JGSLoadingHUDStyle sharedStyle].customView;
        }
            break;
            
        default:
            break;
    }
    
    [self jg_customizeLoadingHudStyle:hud];
}

#pragma mark - Customize
- (void)jg_customizeLoadingHudStyle:(MBProgressHUD *)hud {
    
    CGFloat width = CGRectGetWidth(self.frame);// height = CGRectGetHeight(self.frame);
    CGFloat minWidth = MIN(48, width / 6.f);
    hud.minSize = CGSizeMake(minWidth, minWidth / 3.f);
    //hud.offset = CGPointMake(0, -height / 3.f);
    
    // 全屏背景
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundView.color = [JGSLoadingHUDStyle sharedStyle].backgroundColor;
    // 中间框
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = [JGSLoadingHUDStyle sharedStyle].bezelBackgroundColor;
    
    // label
    hud.label.font = [JGSLoadingHUDStyle sharedStyle].textFont;
    hud.label.textColor = [JGSLoadingHUDStyle sharedStyle].textColor;
    hud.label.numberOfLines = [JGSLoadingHUDStyle sharedStyle].textLines;
    
    hud.square = ([JGSLoadingHUDStyle sharedStyle].square || hud.label.text.length == 0);
    if (!hud.square) {
        [hud setNeedsLayout];
        [hud layoutIfNeeded];
        CGRect bezelFrame = hud.bezelView.frame;
        hud.square = CGRectGetWidth(bezelFrame) - CGRectGetHeight(bezelFrame) <= [JGSLoadingHUDStyle sharedStyle].bezelSquareWidthThanHeight;
    }
}

#pragma mark - Hide
- (void)jg_hideLoading {
    [(MBProgressHUD *)JGSLoadingHUDStack.allObjects.firstObject hideAnimated:YES];
}

- (void)jg_hideAllLoading {
    [JGSLoadingHUDStack.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [(MBProgressHUD *)obj hideAnimated:YES];
    }];
}

@end

@implementation JGSSpinningCircle

- (instancetype)initWithRudius:(CGFloat)radius {
    
    CGFloat width = (radius > 0 ? radius : [JGSLoadingHUDStyle sharedStyle].spinningRadius) * 2;
    self = [super initWithFrame:CGRectMake(0, 0, width, width)];
    if (self) {
        
        self.opaque = NO;
        self.progress = 0;
        
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width]];
    }
    return self;
}

- (void)setIsAnimating:(BOOL)animating {
    
    _isAnimating = animating;
    if(animating) {
        [UIView animateWithDuration:0.9 animations:^{
            self.alpha = 1.0;
        }];
        [self addRotationAnimation];
    }
    else {
        [self hide];
    }
}

- (void)hide {
    [UIView animateWithDuration:0.45 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.layer removeAllAnimations];
    }];
}

- (void)addRotationAnimation {
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
    rotationAnimation.duration = self.duration;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.cumulative = YES;
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation1"];
}

- (void)drawRect:(CGRect)rect {
    //[super drawRect:rect];
    
    self.progress += 0.1;
    while (self.progress > M_PI * 2) {
        self.progress -= M_PI * 2;
    }
    
    CGFloat strokeWidth = self.lineWidth;
    UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
    processBackgroundPath.lineWidth = strokeWidth;
    processBackgroundPath.lineCapStyle = kCGLineCapRound;
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = (self.bounds.size.width - 16 - strokeWidth)/2;
    
    // 起始点在垂直方向顶部居中
    CGFloat startAngle = M_PI_2 * 3 - M_PI_4 * 5;
    startAngle += self.progress;
    [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.1] set];
    
    UIBezierPath *processPath = [UIBezierPath bezierPath];
    processPath.lineCapStyle = kCGLineCapSquare;
    processPath.lineWidth = strokeWidth;
    CGFloat endAngle = ((float)M_PI_4 * 5 + startAngle);
    [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    if(self.hasShadow) {
        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, 0), self.lineWidth, self.lineColor.CGColor);
    }
    [self.lineColor set];
    [processPath stroke];
    CGContextRestoreGState(context);
    
    if (self.isAnimating) {
        [self addRotationAnimation];
    }
}

#pragma mark - Property
- (UIColor *)lineColor {
    return _lineColor ?: JGSColorRGB(50, 155, 255);
}

- (CGFloat)lineWidth {
    return _lineWidth > 0 ? _lineWidth : 2.f;
}

- (CGFloat)duration {
    return _duration > 0 ? _duration : M_PI_4;
}

#pragma mark - End

@end
