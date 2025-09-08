//
//  JGSBaseKeyboard.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSBaseKeyboard.h"
#import "JGSBase+Private.h"

@interface JGSKeyboardKey () <UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) UIColor *normalBgColor;
@property (nonatomic, strong, readonly) UIColor *highlightedBgColor;

@end

@implementation JGSKeyboardKey

#pragma mark - Life Cycle
- (void)dealloc {
    //JGSPrivateLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

- (instancetype)initWithType:(JGSKeyboardKeyType)type text:(NSString *)text frame:(CGRect)frame {
    
    // 微调按钮宽度，防止小数点像素值导致导致边缘出现异常线条
    CGFloat scale = [UIScreen mainScreen].scale;
    frame.size.width = round(frame.size.width * scale) / scale;
    frame.size.height = round(frame.size.height * scale) / scale;
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _type = type;
        _normalBgColor = (type == JGSKeyboardKeyTypeInput ? JGSKeyboardKeyInputColor() : JGSKeyboardKeyFuncColor());
        self.shiftStatus = JGSKeyboardShiftKeyDefault;
        
        self.backgroundColor = self.normalBgColor;
        self.font = (type == JGSKeyboardKeyTypeInput ? JGSKeyboardKeyInputTitleFont() : JGSKeyboardKeyFuncTitleFont());
        self.textColor = JGSKeyboardKeyTitleColor();
        self.textAlignment = NSTextAlignmentCenter;
        self.text = text;
        self.layer.cornerRadius = 4.f;
        self.layer.masksToBounds = YES;
        
        // 点击事件处理
        self.userInteractionEnabled = YES;
        if (type == JGSKeyboardKeyTypeShift) {
            // Shift增加双击处理
            UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
            doubleTapGesture.numberOfTapsRequired = 2;
            doubleTapGesture.numberOfTouchesRequired = 1;
            [self addGestureRecognizer:doubleTapGesture];
        }
        else if (type == JGSKeyboardKeyTypeDelete) {
            // 删除增加长按处理
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
            [self addGestureRecognizer:longPressGesture];
        }
    }
    return self;
}

- (UIColor *)highlightedBgColor {
    
    JGSBaseKeyboard *keyboard = [self.superview isKindOfClass:[JGSBaseKeyboard class]] ? (JGSBaseKeyboard *)self.superview : nil;
    if (keyboard.securityKeyboard.enableHighlightedWhenTap) {
        return self.type == JGSKeyboardKeyTypeInput ? JGSKeyboardKeyFuncColor() : JGSKeyboardKeyInputColor();
    }
    else {
        return self.type == JGSKeyboardKeyTypeInput ? JGSKeyboardKeyInputColor() : JGSKeyboardKeyFuncColor();
    }
}

- (void)setShiftStatus:(JGSKeyboardShiftKeyStatus)shiftStatus {
    
    _shiftStatus = shiftStatus;
    self.backgroundColor = (self.shiftStatus == JGSKeyboardShiftKeyDefault ? self.normalBgColor : self.highlightedBgColor);
    self.highlighted = NO;
    [self setNeedsDisplay];
}

#pragma mark - Action
- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        
        if (sender.numberOfTapsRequired == 2) {
            
            if (self.type != JGSKeyboardKeyTypeShift) {
                return;
            }
            
            if (sender.state == UIGestureRecognizerStateEnded) {
                if (self.shiftStatus != JGSKeyboardShiftKeyLongSelected) {
                    self.shiftStatus = JGSKeyboardShiftKeyLongSelected;
                }
                self.backgroundColor = (self.shiftStatus == JGSKeyboardShiftKeyDefault ? self.normalBgColor : self.highlightedBgColor);
                self.highlighted = NO;
                [self setNeedsDisplay];
                
                if (self.action) {
                    self.action(self, JGSKeyboardKeyEventDoubleTap);
                }
            }
        }
    }
    else if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        
        if (sender.state == UIGestureRecognizerStateBegan) {
            
            self.backgroundColor = self.highlightedBgColor;
            self.highlighted = YES;
            [self setNeedsDisplay];
            
            if (self.action) {
                self.action(self, JGSKeyboardKeyEventLongPressBegin);
            }
        }
        else if (sender.state == UIGestureRecognizerStateEnded) {
            
            self.backgroundColor = self.normalBgColor;
            self.highlighted = NO;
            [self setNeedsDisplay];
            
            if (self.action) {
                self.action(self, JGSKeyboardKeyEventLongPressEnd);
            }
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.type == JGSKeyboardKeyTypeShift) {
        
        // shift 点击状态变化
        self.shiftStatus = (self.shiftStatus == JGSKeyboardShiftKeyDefault ? JGSKeyboardShiftKeySelected : JGSKeyboardShiftKeyDefault);
        self.backgroundColor = (self.shiftStatus == JGSKeyboardShiftKeyDefault ? self.normalBgColor : self.highlightedBgColor);
    }
    else {
        self.backgroundColor = self.highlightedBgColor;
    }
    self.highlighted = YES;
    [self setNeedsDisplay];
    
    // 非输入按钮、且非回车按钮响应按下事件
    if (self.type != JGSKeyboardKeyTypeInput &&
        self.type != JGSKeyboardKeyTypeEnter) {
        if (self.action) {
            self.action(self, JGSKeyboardKeyEventTapDown);
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // shift 点击开始即响应点击事件，后续不需要继续响应
    if (self.type == JGSKeyboardKeyTypeShift) {
        return;
    }
    
    // 点击滑动事件判断当前点位置，更新按钮样式
    BOOL inside = CGRectContainsPoint(self.bounds, [touches.anyObject locationInView:self]);
    self.backgroundColor = inside ? self.highlightedBgColor : self.normalBgColor;
    self.highlighted = inside;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // shift 点击开始即响应点击事件，后续不需要继续响应
    if (self.type == JGSKeyboardKeyTypeShift ||
        !CGRectContainsPoint(self.bounds, [touches.anyObject locationInView:self])) {
        return;
    }
    
    self.backgroundColor = self.normalBgColor;
    self.highlighted = NO;
    [self setNeedsDisplay];
    
    if (self.action) {
        self.action(self, JGSKeyboardKeyEventTapEnded);
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // shift 点击开始即响应点击事件，后续不需要继续响应
    if (self.type == JGSKeyboardKeyTypeShift) {
        return;
    }
    
    // 当我们正在触摸屏幕的时候，如果出现了低电量、有电话呼入等等这样的系统事件时候，低电量或者电话的窗口会置为前台，这个时候touchesCancelled方法就会被调用。
    // 因为在软件运行过程中不可避免的会发生由iOS系统发出的一些事件，导致触摸事件的中断，所以一般建议要实现touchesCancelled这个方法，一般情况下直接调用touchesEnd即可。
    self.backgroundColor = self.normalBgColor;
    self.highlighted = NO;
    [self setNeedsDisplay];
}

#pragma mark - Draw
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat roundPx = 1.4f;
    switch (self.type) {
        case JGSKeyboardKeyTypeShift: {
            
            // 绘制箭头
            CGFloat centerX = CGRectGetWidth(rect) * 0.5;
            CGFloat centerY = CGRectGetHeight(rect) * 0.5;
            
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, centerX - 4, centerY);
            CGPathAddLineToPoint(path, NULL, centerX - 10, centerY);
            CGPathAddLineToPoint(path, NULL, centerX - 10, centerY - roundPx);
            CGPathAddLineToPoint(path, NULL, centerX - roundPx * 0.5, centerY - 10);
            CGPathAddLineToPoint(path, NULL, centerX + roundPx * 0.5, centerY - 10);
            CGPathAddLineToPoint(path, NULL, centerX + 10, centerY - roundPx);
            CGPathAddLineToPoint(path, NULL, centerX + 10, centerY);
            CGPathAddLineToPoint(path, NULL, centerX + 4, centerY);
            CGPathAddLineToPoint(path, NULL, centerX + 4, centerY + 8 - roundPx);
            CGPathAddArc(path, NULL, centerX + 4 - roundPx, centerY + 8 - roundPx, roundPx, 0, M_PI_2, NO);
            CGPathAddLineToPoint(path, NULL, centerX - 4 + roundPx, centerY + 8);
            CGPathAddArc(path, NULL, centerX - 4 + roundPx, centerY + 8 - roundPx, roundPx, M_PI_2, M_PI, NO);
            CGPathAddLineToPoint(path, NULL, centerX - 4, centerY);
            
            // 长选中Shift
            if (self.shiftStatus == JGSKeyboardShiftKeyLongSelected) {
                CGPathMoveToPoint(path, NULL, centerX - 4, centerY + 12);
                CGPathAddLineToPoint(path, NULL, centerX + 4, centerY + 12);
            }
            
            CGPathCloseSubpath(path);
            
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(ctx, 1.2f);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            CGContextSetLineJoin(ctx, kCGLineJoinRound);
            CGContextSetStrokeColorWithColor(ctx, self.textColor.CGColor);
            CGContextAddPath(ctx, path);
            CGContextStrokePath(ctx);
            
            // 选中填充
            if (self.shiftStatus != JGSKeyboardShiftKeyDefault) {
                CGContextSetFillColorWithColor(ctx, self.textColor.CGColor);
                CGContextAddPath(ctx, path);
                CGContextFillPath(ctx);
            }
            
            CGPathRelease(path);
        }
            break;
            
        case JGSKeyboardKeyTypeDelete: {
            
            // 绘制箭头
            CGFloat centerX = CGRectGetWidth(rect) * 0.5;
            CGFloat centerY = CGRectGetHeight(rect) * 0.5;
            
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, centerX - 4, centerY - 8);
            CGPathAddLineToPoint(path, NULL, centerX + 12 - roundPx, centerY - 8);
            CGPathAddArc(path, NULL, centerX + 12 - roundPx, centerY - 8 + roundPx, roundPx, -M_PI_2, 0, NO);
            CGPathAddLineToPoint(path, NULL, centerX + 12, centerY + 8 - roundPx);
            CGPathAddArc(path, NULL, centerX + 12 - roundPx, centerY + 8 - roundPx, roundPx, 0, M_PI_2, NO);
            CGPathAddLineToPoint(path, NULL, centerX - 4, centerY + 8);
            CGPathAddLineToPoint(path, NULL, centerX - 12, centerY + roundPx * 0.5);
            CGPathAddLineToPoint(path, NULL, centerX - 12, centerY - roundPx * 0.5);
            CGPathAddLineToPoint(path, NULL, centerX - 4, centerY - 8);
            CGPathCloseSubpath(path);
            
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(ctx, 1.2f);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            CGContextSetLineJoin(ctx, kCGLineJoinRound);
            CGContextSetStrokeColorWithColor(ctx, self.textColor.CGColor);
            CGContextAddPath(ctx, path);
            
            // 选中填充
            if (self.highlighted) {
                CGContextFillPath(ctx);
            }
            
            CGContextStrokePath(ctx);
            CGPathRelease(path);
            
            // 绘制x
            CGMutablePathRef xPath = CGPathCreateMutable();
            CGPathMoveToPoint(xPath, NULL, centerX - 2, centerY - 4);
            CGPathAddLineToPoint(xPath, NULL, centerX + 6, centerY + 4);
            CGPathMoveToPoint(xPath, NULL, centerX - 2, centerY + 4);
            CGPathAddLineToPoint(xPath, NULL, centerX + 6, centerY - 4);
            CGPathCloseSubpath(xPath);
            
            // 选中状态白色x
            CGContextSetStrokeColorWithColor(ctx, self.highlighted ? [UIColor whiteColor].CGColor : self.textColor.CGColor);
            CGContextAddPath(ctx, xPath);
            CGContextStrokePath(ctx);
            CGPathRelease(xPath);
        }
            break;
            
        case JGSKeyboardKeyTypeSymbolSwitch2Half:
        case JGSKeyboardKeyTypeSymbolSwitch2Full: {
            
            // 绘制切换全半角地球
            CGFloat centerX = CGRectGetWidth(rect) * 0.5;
            CGFloat centerY = CGRectGetHeight(rect) * 0.5;
            CGFloat radius = MIN(CGRectGetWidth(rect) * 0.28, CGRectGetHeight(rect) * 0.4);
            
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(ctx, 1.2f);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            CGContextSetLineJoin(ctx, kCGLineJoinRound);
            CGContextSetStrokeColorWithColor(ctx, [self.textColor colorWithAlphaComponent:0.67].CGColor);
            CGContextAddArc(ctx, centerX, centerY, radius, 0, M_PI * 2.f, NO);
            CGContextStrokePath(ctx);
            
            CGFloat lrRadius = 1.25 * radius; // (R-0.5r)^2 + r^2 = R^2
            CGFloat angle = asin(radius / lrRadius);
            CGContextAddArc(ctx, centerX + 0.5 * radius - lrRadius, centerY, lrRadius, - angle, angle, NO);
            CGContextStrokePath(ctx);
            CGContextAddArc(ctx, centerX - 0.5 * radius + lrRadius, centerY, lrRadius, M_PI - angle, M_PI + angle, NO);
            CGContextStrokePath(ctx);
            
            CGFloat tbRadius = 5.f / 4 * (16.f / 25 + 25.f / 36) * radius; // (R-0.4r)^2 + (r*5/6)^2 = R^2
            angle = asin(radius * 0.75 / tbRadius);
            CGContextAddArc(ctx, centerX, centerY - radius * 0.5 - tbRadius, tbRadius, M_PI_2 - angle, M_PI_2 + angle, NO);
            CGContextStrokePath(ctx);
            CGContextAddArc(ctx, centerX, centerY + radius * 0.5 + tbRadius, tbRadius, M_PI * 1.5 - angle, M_PI * 1.5 + angle, NO);
            CGContextStrokePath(ctx);
            
            CGContextMoveToPoint(ctx, centerX - radius, centerY);
            CGContextAddLineToPoint(ctx, centerX + radius, centerY);
            CGContextMoveToPoint(ctx, centerX, centerY - radius);
            CGContextAddLineToPoint(ctx, centerX, centerY + radius);
            CGContextStrokePath(ctx);
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - End

@end

@interface JGSBaseKeyboard ()

@property (nonatomic, assign, readonly) CGFloat keyboardWidth;

@end

@implementation JGSBaseKeyboard

#pragma mark - Life Cycle
- (void)dealloc {
    //JGSPrivateLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

- (instancetype)initWithFrame:(CGRect)frame type:(JGSKeyboardType)type securityKeyboard:(JGSSecurityKeyboard *)securityKeyboard keyInput:(void (^)(JGSBaseKeyboard * _Nonnull, JGSKeyboardKey * _Nonnull, JGSKeyboardKeyEvents))keyInput {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _securityKeyboard = securityKeyboard;
        _type = type;
        _title = JGSKeyboardTitleForType(type);
        _returnKeyTitle = JGSKeyboardReturnTitleForType(securityKeyboard.textInput.returnKeyType);
        _keyInput = keyInput;
        
        _keyboardWidth = CGRectGetWidth(frame);
        
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

#pragma mark - Action
- (BOOL)keyboardKeyAction:(JGSKeyboardKey *)key event:(JGSKeyboardKeyEvents)event {
    
    switch (key.type) {
        case JGSKeyboardKeyTypeInput: {
            
            if (event != JGSKeyboardKeyEventTapEnded) {
                return NO;
            }
            
            // 输入内容
            if (self.keyInput) {
                self.keyInput(self, key, event);
            }
        }
            break;
            
        case JGSKeyboardKeyTypeShift: {
            
            if (event != JGSKeyboardKeyEventTapDown &&
                event != JGSKeyboardKeyEventDoubleTap) {
                return NO;
            }
        }
            break;
            
        case JGSKeyboardKeyTypeDelete: {
            
            if (event != JGSKeyboardKeyEventTapDown &&
                event != JGSKeyboardKeyEventLongPressBegin &&
                event != JGSKeyboardKeyEventLongPressEnd) {
                return NO;
            }
            
            // 删除内容
            if (self.keyInput) {
                self.keyInput(self, key, event);
            }
        }
            break;
            
        case JGSKeyboardKeyTypeSwitch2Letter:
        case JGSKeyboardKeyTypeSwitch2Symbol:
        case JGSKeyboardKeyTypeSwitch2Number: {
            
            if (event != JGSKeyboardKeyEventTapDown) {
                return NO;
            }
            
            // 切换键盘
            if (self.keyInput) {
                self.keyInput(self, key, event);
            }
        }
            break;
            
        case JGSKeyboardKeyTypeSymbolSwitch2Symbols:
        case JGSKeyboardKeyTypeSymbolSwitch2Numbers:
        case JGSKeyboardKeyTypeSymbolSwitch2Half:
        case JGSKeyboardKeyTypeSymbolSwitch2Full: {
            
            // 符号键盘内部切换
            if (event != JGSKeyboardKeyEventTapDown) {
                return NO;
            }
        }
            break;
            
        case JGSKeyboardKeyTypeEnter: {
            
            if (event != JGSKeyboardKeyEventTapEnded) {
                return NO;
            }
            
            // 输入回车
            if (self.keyInput) {
                self.keyInput(self, key, event);
            }
        }
            break;
            
        default:
            return NO;
            break;
    }
    return YES;
}

#pragma mark - End

@end
