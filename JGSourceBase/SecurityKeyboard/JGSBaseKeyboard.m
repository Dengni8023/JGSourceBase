//
//  JGSBaseKeyboard.m
//  
//
//  Created by 梅继高 on 2019/5/31.
//

#import "JGSBaseKeyboard.h"
#import "JGSCategory.h"

FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarColor(void) {
    return JGSColorRGB(253, 253, 253); // 系统键盘截图取色
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarTitleColor(void) {
    return [[UIColor grayColor] colorWithAlphaComponent:0.7]; // 系统默认placeholder颜色 70% gray(50% white)
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarItemTitleColor(void) {
    return JGSColorRGB(66, 66, 66); // 系统键盘截图取色
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarItemSelectedTitleColor(void) {
    return JGSColorRGB(68, 121, 251); // 系统键盘截图取色
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardBackgroundColor(void) {
    return JGSColorRGB(209, 213, 217); // 系统键盘截图取色
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardKeyInputColor(void) {
    return JGSColorRGB(255, 255, 255); // 系统键盘截图取色
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardKeyFuncColor(void) {
    return JGSColorRGB(173, 178, 188); // 系统键盘截图取色
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardKeyTitleColor(void) {
    return JGSColorRGB(0, 0, 0);// 系统键盘截图取色
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardKeyHighlightedTitleColor(void) {
    return [JGSKeyboardKeyTitleColor() colorWithAlphaComponent:JGSKeyboardHighlightedColorAlpha];
}

FOUNDATION_EXTERN UIFont * const JGSKeyboardToolBarTitleFont(void) {
    return [UIFont systemFontOfSize:16];
}

FOUNDATION_EXTERN UIFont * const JGSKeyboardToolBarItemTitleFont(void) {
    return [UIFont boldSystemFontOfSize:16];
}

FOUNDATION_EXTERN UIFont * const JGSKeyboardKeyInputTitleFont(void) {
    return [UIFont systemFontOfSize:20];
}

FOUNDATION_EXTERN UIFont * const JGSKeyboardKeyFuncTitleFont(void) {
    return [UIFont systemFontOfSize:16];
}

CGFloat const JGSKeyboardHighlightedColorAlpha = 0.6;
CGFloat const JGSKeyboardToolbarHeight = 40.f;
NSInteger const JGSKeyboardLinesNumber = 4;
NSInteger const JGSKeyboardMaxItemsInLine = 10;
NSInteger const JGSKeyboardNumberItemsInLine = 4;
CGFloat const JGSKeyboardInteritemSpacing = 6.f;
CGFloat const JGSKeyboardKeyLineSpacing = 10.f;
CGFloat const JGSKeyboardKeyWidthHeightRatio = 0.75;

@implementation JGSKeyboardToolbarItem

@dynamic customView;

#pragma mark - Life Cycle
- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

- (instancetype)initWithTitle:(NSString *)title type:(JGSKeyboardToolbarItemType)type action:(void (^)(JGSKeyboardToolbarItem * _Nonnull))action {
    
    UIButton *cusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cusBtn.titleLabel.font = JGSKeyboardToolBarItemTitleFont();
    [cusBtn setTitle:title forState:UIControlStateNormal];
    [cusBtn addTarget:self action:@selector(customBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    switch (type) {
        case JGSKeyboardToolbarItemTypeSwitch: {
            [cusBtn setTitleColor:JGSKeyboardToolBarItemTitleColor() forState:UIControlStateNormal];
            [cusBtn setTitleColor:JGSKeyboardToolBarItemSelectedTitleColor() forState:UIControlStateDisabled];
        }
            break;
            
        case JGSKeyboardToolbarItemTypeTitle: {
            cusBtn.titleLabel.font = JGSKeyboardToolBarTitleFont();
            [cusBtn setTitleColor:JGSKeyboardToolBarTitleColor() forState:UIControlStateNormal];
        }
            break;
            
        case JGSKeyboardToolbarItemTypeDone: {
            [cusBtn setTitleColor:JGSKeyboardToolBarItemSelectedTitleColor() forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    UIColor *highlightedColor = [[cusBtn titleColorForState:UIControlStateNormal] colorWithAlphaComponent:JGSKeyboardHighlightedColorAlpha];
    [cusBtn setTitleColor:highlightedColor forState:UIControlStateHighlighted];
    
    [cusBtn sizeToFit];
    self = [self initWithCustomView:cusBtn];
    if (self) {
        
        self.customView = cusBtn;
        _barItemAction = action;
        if (type == JGSKeyboardToolbarItemTypeTitle) {
            cusBtn.enabled = NO;
        }
    }
    return self;
}

- (void)customBtnTouched:(UIButton *)sender {
    
    if (self.barItemAction) {
        self.barItemAction(self);
    }
}

@end

@interface JGSKeyboardKey () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIColor *normalBgColor;
@property (nonatomic, strong) UIColor *highlightedBgColor;

@end

@implementation JGSKeyboardKey

#pragma mark - Life Cycle
- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
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
        _highlightedBgColor = (type == JGSKeyboardKeyTypeInput ? JGSKeyboardKeyFuncColor() : JGSKeyboardKeyInputColor());
        _shiftStatus = JGSKeyboardShiftKeyDefault;
        
        self.backgroundColor = self.normalBgColor;
        self.font = (type == JGSKeyboardKeyTypeInput ? JGSKeyboardKeyInputTitleFont() : JGSKeyboardKeyFuncTitleFont());
        self.textColor = JGSKeyboardKeyTitleColor();
        self.highlightedTextColor =  [self.textColor colorWithAlphaComponent:JGSKeyboardHighlightedColorAlpha];
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
        self.shiftStatus = (self.shiftStatus == JGSKeyboardShiftKeyDefault ? JGSKeyboardShiftKeySelected : JGSKeyboardShiftKeyDefault);
        self.backgroundColor = (self.shiftStatus == JGSKeyboardShiftKeyDefault ? self.normalBgColor : self.highlightedBgColor);
    }
    else {
        self.backgroundColor = self.highlightedBgColor;
    }
    self.highlighted = YES;
    [self setNeedsDisplay];
    
    if (self.type != JGSKeyboardKeyTypeInput &&
        self.type != JGSKeyboardKeyTypeEnter) {
        if (self.action) {
            self.action(self, JGSKeyboardKeyEventTapDown);
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.type == JGSKeyboardKeyTypeShift ||
        CGRectContainsPoint(self.bounds, [touches.anyObject locationInView:self])) {
        return;
    }
    
    self.backgroundColor = self.normalBgColor;
    self.highlighted = NO;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
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

#pragma mark - Draw
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    switch (self.type) {
        case JGSKeyboardKeyTypeShift: {
            
            // 绘制箭头
            CGFloat centerX = CGRectGetWidth(rect) * 0.5;
            CGFloat centerY = CGRectGetHeight(rect) * 0.5;
            
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, centerX - 4, centerY);
            CGPathAddLineToPoint(path, NULL, centerX - 10, centerY);
            CGPathAddLineToPoint(path, NULL, centerX, centerY - 10);
            CGPathAddLineToPoint(path, NULL, centerX + 10, centerY);
            CGPathAddLineToPoint(path, NULL, centerX + 4, centerY);
            CGPathAddLineToPoint(path, NULL, centerX + 4, centerY + 8);
            CGPathAddLineToPoint(path, NULL, centerX - 4, centerY + 8);
            CGPathAddLineToPoint(path, NULL, centerX - 4, centerY);
            
            // 长选中Shift
            if (self.shiftStatus == JGSKeyboardShiftKeyLongSelected) {
                CGPathMoveToPoint(path, NULL, centerX - 4, centerY + 12);
                CGPathAddLineToPoint(path, NULL, centerX + 4, centerY + 12);
            }
            
            CGPathCloseSubpath(path);
            
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(ctx, 1.5f);
            CGContextSetLineCap(ctx, kCGLineCapButt);
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
            CGPathAddLineToPoint(path, NULL, centerX + 12, centerY - 8);
            CGPathAddLineToPoint(path, NULL, centerX + 12, centerY + 8);
            CGPathAddLineToPoint(path, NULL, centerX - 4, centerY + 8);
            CGPathAddLineToPoint(path, NULL, centerX - 12, centerY);
            CGPathAddLineToPoint(path, NULL, centerX - 4, centerY - 8);
            
            // 正常状态黑色x
            if (!self.highlighted) {
                CGPathMoveToPoint(path, NULL, centerX - 2, centerY - 4);
                CGPathAddLineToPoint(path, NULL, centerX + 6, centerY + 4);
                CGPathMoveToPoint(path, NULL, centerX - 2, centerY + 4);
                CGPathAddLineToPoint(path, NULL, centerX + 6, centerY - 4);
            }
            
            CGPathCloseSubpath(path);
            
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(ctx, 1.5f);
            CGContextSetLineCap(ctx, kCGLineCapButt);
            CGContextSetLineJoin(ctx, kCGLineJoinRound);
            CGContextSetStrokeColorWithColor(ctx, self.textColor.CGColor);
            CGContextAddPath(ctx, path);
            CGContextStrokePath(ctx);
            
            // 选中填充
            if (self.highlighted) {
                CGContextSetFillColorWithColor(ctx, self.textColor.CGColor);
                CGContextAddPath(ctx, path);
                CGContextFillPath(ctx);
                
                // 选中状态白色x
                CGPathMoveToPoint(path, NULL, centerX - 2, centerY - 4);
                CGPathAddLineToPoint(path, NULL, centerX + 6, centerY + 4);
                CGPathMoveToPoint(path, NULL, centerX - 2, centerY + 4);
                CGPathAddLineToPoint(path, NULL, centerX + 6, centerY - 4);
                CGPathCloseSubpath(path);
                
                CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
                CGContextAddPath(ctx, path);
                CGContextStrokePath(ctx);
            }
            
            CGPathRelease(path);
        }
            break;
            
        case JGSKeyboardKeyTypeSymbolSwitch2Half:
        case JGSKeyboardKeyTypeSymbolSwitch2Full: {
            
            // 绘制切换全半角地球
            CGFloat centerX = CGRectGetWidth(rect) * 0.5;
            CGFloat centerY = CGRectGetHeight(rect) * 0.5;
            CGFloat radius = CGRectGetWidth(rect) * 0.25;
            
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(ctx, 1.5f);
            CGContextSetLineCap(ctx, kCGLineCapButt);
            CGContextSetLineJoin(ctx, kCGLineJoinRound);
            CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0 alpha:0.52].CGColor);
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

@end

NSString * const JGSKeyboardTitleLetters = @"Abc";
NSString * const JGSKeyboardTitleSymbolWithNumber = @".?123";
NSString * const JGSKeyboardTitleSymbols = @"#+=";
NSString * const JGSKeyboardTitleNumbers = @"123";
FOUNDATION_EXTERN NSString * const JGSKeyboardTitleForType(JGSKeyboardType type) {
    
    //JGSKeyboardTypeLetter = 0, // 英文字母键盘
    //JGSKeyboardTypeSymbol, // 符号键盘
    //JGSKeyboardTypeNumber, // 数字键盘
    NSArray *titles = @[JGSKeyboardTitleLetters, JGSKeyboardTitleSymbols, JGSKeyboardTitleNumbers];
    NSInteger typeIdx = type - JGSKeyboardTypeLetter;
    if (typeIdx >= 0 && typeIdx < titles.count) {
        return titles[typeIdx];
    }
    return titles.firstObject;
}

FOUNDATION_EXTERN NSString * const JGSKeyboardReturnTitleForType(JGSKeyboardReturnType type) {
    
    //JGSKeyboardReturnTypeDone = 0, // 完成
    //JGSKeyboardReturnTypeNext, // 下一项
    NSArray *titles = @[@"完成", @"下一项"];
    NSInteger typeIdx = type - JGSKeyboardReturnTypeDone;
    if (typeIdx >= 0 && typeIdx < titles.count) {
        return titles[typeIdx];
    }
    return titles.firstObject;
}

@implementation JGSBaseKeyboard

#pragma mark - Life Cycle
- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

- (instancetype)initWithFrame:(CGRect)frame type:(JGSKeyboardType)type returnKeyType:(JGSKeyboardReturnType)returnKeyType keyInput:(void (^)(JGSBaseKeyboard * _Nonnull, JGSKeyboardKey * _Nonnull, JGSKeyboardKeyEvents))keyInput {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _type = type;
        _title = JGSKeyboardTitleForType(type);
        _returnKeyTitle = JGSKeyboardReturnTitleForType(returnKeyType);
        _keyInput = keyInput;
    }
    return self;
}

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

@end
