//
//  UIView+JGSToast.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/26.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "UIView+JGSToast.h"
#import "MBProgressHUD.h"

@implementation JGSToastStyle

+ (instancetype)sharedStyle {
    
    static JGSToastStyle *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        
        instance.defaultPosition = JGSToastPositionCenter;
        instance.topMargin = 32.f;
        instance.bottomMargin = 32.f;
        instance.cornerRadius = 2.5f;
        instance.textLines = 0;
        
        instance.duration = 1.2f;
    });
    return instance;
}

- (UIColor *)backgroundColor {
    return _backgroundColor ?: [[UIColor blackColor] colorWithAlphaComponent:0.75];
}

- (UIFont *)textFont {
    return _textFont ?: [UIFont systemFontOfSize:16];
}

- (UIColor *)textColor {
    return _textColor ?: [UIColor whiteColor];
}

@end

@implementation UIView (JGSToast)

static NSPointerArray *JGSToastStack = nil;
+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        JGSToastStack = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
    });
}

#pragma mark - Message
- (void)jg_showToastWithMessage:(NSString *)message {
    [self jg_showToastWithMessage:message completion:nil];
}

- (void)jg_showToastWithMessage:(NSString *)message position:(JGSToastPosition)position {
    [self jg_showToastWithMessage:message position:position completion:nil];
}

- (void)jg_showToastWithMessage:(NSString *)message completion:(void (^)(void))completion {
    [self jg_showToastWithMessage:message position:[JGSToastStyle sharedStyle].defaultPosition completion:nil];
}

- (void)jg_showToastWithMessage:(NSString *)message position:(JGSToastPosition)position completion:(void (^)(void))completion {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.userInteractionEnabled = (completion != nil);
    hud.completionBlock = completion;
    [JGSToastStack addPointer:(void *)hud];
    
    hud.square = NO;
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    
    [self jg_CustomizeToasatHudStyle:hud position:position];
    [hud hideAnimated:YES afterDelay:[JGSToastStyle sharedStyle].duration];
}

#pragma mark - Icon
- (void)jg_showToastWithImage:(UIImage *)image {
    [self jg_showToastWithImage:image completion:nil];
}

- (void)jg_showToastWithImage:(UIImage *)image position:(JGSToastPosition)position {
    [self jg_showToastWithImage:image position:position completion:nil];
}

- (void)jg_showToastWithImage:(UIImage *)image completion:(void (^)(void))completion {
    [self jg_showToastWithImage:image position:[JGSToastStyle sharedStyle].defaultPosition completion:nil];
}

- (void)jg_showToastWithImage:(UIImage *)image position:(JGSToastPosition)position completion:(void (^)(void))completion {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.userInteractionEnabled = (completion != nil);
    hud.completionBlock = completion;
    [JGSToastStack addPointer:(void *)hud];
    
    hud.square = NO;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:image];
    
    [self jg_CustomizeToasatHudStyle:hud position:position];
    [hud hideAnimated:YES afterDelay:[JGSToastStyle sharedStyle].duration];
}

#pragma mark - IconMessage
- (void)jg_showToastWithIcon:(UIImage *)icon message:(NSString *)message {
    [self jg_showToastWithIcon:icon message:message completion:nil];
}

- (void)jg_showToastWithIcon:(UIImage *)icon message:(NSString *)message position:(JGSToastPosition)position {
    [self jg_showToastWithIcon:icon message:message position:position completion:nil];
}

- (void)jg_showToastWithIcon:(UIImage *)icon message:(NSString *)message completion:(void (^)(void))completion {
    [self jg_showToastWithIcon:icon message:message position:[JGSToastStyle sharedStyle].defaultPosition completion:nil];
}

- (void)jg_showToastWithIcon:(UIImage *)icon message:(NSString *)message position:(JGSToastPosition)position completion:(void (^)(void))completion {
    
    if (message && icon) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        hud.userInteractionEnabled = (completion != nil);
        hud.completionBlock = completion;
        [JGSToastStack addPointer:(void *)hud];
        
        hud.square = NO;
        hud.mode = MBProgressHUDModeCustomView;
        
        UIButton *tipsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tipsBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [tipsBtn setTitle:[NSString stringWithFormat:@"  %@", message] forState:UIControlStateNormal];
        [tipsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [tipsBtn setImage:icon forState:UIControlStateNormal];
        tipsBtn.enabled = NO;
        tipsBtn.adjustsImageWhenDisabled = NO;
        hud.customView = tipsBtn;
        
        [self jg_CustomizeToasatHudStyle:hud position:position];
        [hud hideAnimated:YES afterDelay:[JGSToastStyle sharedStyle].duration];
    }
    else if (message) {
        
        [self jg_showToastWithMessage:message position:position];
    }
    else if (icon) {
        
        [self jg_showToastWithImage:icon position:position];
    }
}

#pragma mark - Customize
- (void)jg_CustomizeToasatHudStyle:(MBProgressHUD *)hud position:(JGSToastPosition)position {
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeInsets = self.safeAreaInsets;
    }
    
    hud.minSize = CGSizeMake(width / 4.f, width / 4.f / 5.f);
    hud.margin = 6;
    
    CGFloat safeTopOffset = safeInsets.top + [JGSToastStyle sharedStyle].topMargin - height * 0.5;
    CGFloat safeBottomOffset = height - safeInsets.bottom - [JGSToastStyle sharedStyle].bottomMargin - height * 0.5;
    switch (position) {
        case JGSToastPositionTop:
            hud.offset = CGPointMake(0, safeTopOffset);
            break;
            
        case JGSToastPositionUp:
            hud.offset = CGPointMake(0, -height * 0.25);
            break;
            
        case JGSToastPositionLow:
            hud.offset = CGPointMake(0, height * 0.25);
            break;
            
        case JGSToastPositionBottom:
            hud.offset = CGPointMake(0, safeBottomOffset);
            break;
            
        case JGSToastPositionCenter:
            hud.offset = CGPointZero;
            break;
    }
    
    // 全屏背景
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundView.color = [UIColor clearColor];
    // 中间框
    hud.bezelView.layer.cornerRadius = [JGSToastStyle sharedStyle].cornerRadius;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = [JGSToastStyle sharedStyle].backgroundColor;
    
    // label
    hud.label.font = [JGSToastStyle sharedStyle].textFont;
    hud.label.textColor = [JGSToastStyle sharedStyle].textColor;
    hud.label.numberOfLines = [JGSToastStyle sharedStyle].textLines;
}

#pragma mark - Hide
- (void)jg_hideToast {
    [(MBProgressHUD *)JGSToastStack.allObjects.firstObject hideAnimated:YES];
}

- (void)jg_hideAllToast {
    [JGSToastStack.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [(MBProgressHUD *)obj hideAnimated:YES];
    }];
}

@end
