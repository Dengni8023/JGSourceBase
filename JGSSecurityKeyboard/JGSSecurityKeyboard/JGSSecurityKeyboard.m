//
//  JGSSecurityKeyboard.m
//  JGSSecurityKeyboard
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSSecurityKeyboard.h"
#import "JGSLetterKeyboard.h"
#import "JGSNumberKeyboard.h"
#import "JGSSymbolKeyboard.h"
#import "JGSBase.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonCrypto.h>

@interface UITextField (JGSSecurityKeyboard_Private)

// 右侧clear点击清空输入文本，不执行replace操作，需要检查记录的输入文本与文本框文本长度是否一致
- (void)jgsCheckClearInputChangeText;

@end

@interface JGSSecurityKeyboard ()

@property (nonatomic, assign) JGSKeyboardOptions keyboardOptions;
@property (nonatomic, assign) JGSKeyboardReturnType returnType;
@property (nonatomic, assign) BOOL numberPadRandom; // 是否开启数字键盘随机顺序，默认开启
@property (nonatomic, assign) BOOL symbolFullAngle; // 是否开启全角，默认关闭，支持全角时将支持全半角字符输入

@property (nonatomic, assign) CGRect keyboardFrame;

@property (nonatomic, strong) JGSKeyboardToolbar *keyboardTool;
@property (nonatomic, strong) JGSLetterKeyboard *letterKeyboard;
@property (nonatomic, strong) JGSSymbolKeyboard *symbolKeyboard;
@property (nonatomic, strong) JGSNumberKeyboard *numberKeyboard;
@property (nonatomic, strong) JGSNumberKeyboard *idCardKeyboard;
@property (nonatomic, copy) NSArray<JGSBaseKeyboard *> *keyboards;

@property (nonatomic, strong) NSTimer *deleteTimer;

@end

@implementation JGSSecurityKeyboard

#pragma mark - Life Cycle
- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(NSString *)title {
    return [self keyboardWithTextField:textField title:title randomNumPad:YES];
}

+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum {
    return [self keyboardWithTextField:textField title:title randomNumPad:randomNum enableFullAngle:NO];
}

+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum enableFullAngle:(BOOL)fullAngle {
    return [[self alloc] initWithTextField:textField title:title randomNumPad:randomNum enableFullAngle:fullAngle options:kNilOptions];
}

+ (instancetype)numberKeyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum {
    return [[self alloc] initWithTextField:textField title:title randomNumPad:randomNum enableFullAngle:NO options:JGSKeyboardOptionNumber];
}

+ (instancetype)idCardKeyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum {
    return [[self alloc] initWithTextField:textField title:title randomNumPad:randomNum enableFullAngle:NO options:JGSKeyboardOptionIDCard];
}

- (instancetype)initWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum enableFullAngle:(BOOL)fullAngle options:(JGSKeyboardOptions)options {
    
    self = [super init];
    if (self) {
        
        // clear、paste等处理
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
        
        // 应用方向变化等导致键盘大小变化处理，考虑通知接收频率、及性能问题
        // 仅监听 UIKeyboardWillChangeFrameNotification 即可实现修改键盘高度操作
        // 通知执行顺序大概（键盘高度不实际更新是存在差异情况）如下：
        // 1、UIApplicationDidChangeStatusBarOrientationNotification：应用转屏后执行一次，最先执行
        // 2、UIKeyboardWillChangeFrameNotification：键盘弹出、应用转屏均会执行，如果收到通知不进行键盘高度更新，则仅执行一次，每更新一次则会重复执行一次
        // 3、UIKeyboardDidChangeFrameNotification：与keyboardWillChangeFrame配对执行，如果收到通知不进行键盘高度更新，则仅执行一次，每更新一次则会重复执行两次
        // 4、UIKeyboardWillShowNotification：键盘弹出、应用转屏均会执行，如果收到通知不进行键盘高度更新，则仅执行一次，每更新一次则会重复执行一次
        
        // 经测试：
        // 1、在键盘高度不实际更新（调用更新方法，但是键盘实际高度不变）的情况下 UIKeyboardWillShowNotification 执行顺序在 UIKeyboardDidChangeFrameNotification 之后
        // 2、其他情况 UIKeyboardWillShowNotification、UIKeyboardDidChangeFrameNotification 执行顺序和高度更新的时机存在关联，可自行测试
        
        // 收到 UIKeyboardWillChangeFrameNotification、UIKeyboardWillShowNotification、UIKeyboardDidChangeFrameNotification 时：
        // 1、需要判断当前输入框是否有焦点，多个输入框同时存在时，系统通知可能多次发送
        // 2、每个通知处理方法均可执行键盘高度更新，UIKeyboardDidChangeFrameNotification 更新则会重复更新键盘高度，不建议在此处更新
        // 3、UIKeyboardWillShowNotification 通知中更新高度，则需要待转屏动画执行结束后键盘高度更新才会执行
        // 综上，键盘高度更新在 UIKeyboardWillChangeFrameNotification 中进行最合适
        
        // 转屏时 UIKeyboardWillShowNotification 通知首次执行在 UIKeyboardDidChangeFrameNotification 通知之后
        // 如仅在UIKeyboardWillShowNotification更新键盘高度，键盘转屏动画完成之后才会执行键盘高度更新操作，键盘高度变化不流畅
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
        
        self.backgroundColor = JGSKeyboardBackgroundColor();
        self.numberPadRandom = randomNum; // 数字键盘随机开关
        self.symbolFullAngle = fullAngle; // 字符键盘支持全角
        
        _textField = textField;
        
        _title = title;//.length > 0 ? title : self.textField.placeholder;
        _returnType = (textField.returnKeyType == UIReturnKeyNext ? JGSKeyboardReturnTypeNext : JGSKeyboardReturnTypeDone);
        if (options != kNilOptions) {
            _keyboardOptions = options & (JGSKeyboardOptionLetter | JGSKeyboardOptionSymbol | JGSKeyboardOptionNumber | JGSKeyboardOptionIDCard);
        }
        else {
            _keyboardOptions = (JGSKeyboardOptionLetter | JGSKeyboardOptionSymbol);
            if (self.title.length > 0) {
                _keyboardOptions = (_keyboardOptions | JGSKeyboardOptionNumber);
            }
        }
        
        BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
        NSString *orientation = isPortrait ? @"Portrait" : @"Landscape";
        NSString *sizeInfo = [JGSKeyboardSizeInfo() objectForKey:orientation];
        CGSize keyboardSize = CGSizeFromString(sizeInfo);
        
        self.keyboardFrame = CGRectMake(0, self.title.length > 0 ? JGSKeyboardToolbarHeight : 0, keyboardSize.width, keyboardSize.height);
        CGFloat keyboardHeight = keyboardSize.height + (self.title.length > 0 ? JGSKeyboardToolbarHeight : 0);
        
        // 此处做初步的键盘高度计算，精确高度待键盘展示时更新高度约束
        // 此处高度必须非0，否则键盘不会展示，高度更新无效
        self.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), keyboardHeight);
        
        //[self addViewElements];
    }
    return self;
}

- (void)setEnableHighlightedWhenTap:(BOOL)enableHighlightedWhenTap {
    _enableHighlightedWhenTap = enableHighlightedWhenTap;
    if (!self.superview) {
        return;
    }
    
    [self.keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enableHighlightedWhenTap:enableHighlightedWhenTap];
    }];
}

#pragma mark - Notification
- (void)textFieldTextDidChange:(NSNotification *)noti {
    
    if ([noti.object isEqual:self.textField]) {
        [self.textField jgsCheckClearInputChangeText];
    }
}

- (void)applicationDidChangeStatusBarOrientation:(NSNotification *)noti {
    if (!self.textField.isFirstResponder) {
        return;
    }
    
    //JGSLog();
    //[self updateHeightConstraints];
}

- (void)keyboardWillChangeFrame:(NSNotification *)noti {
    if (!self.textField.isFirstResponder) {
        return;
    }
    
    //JGSLog();
    [self updateHeightConstraints];
}

- (void)keyboardWillShow:(NSNotification *)noti {
    if (!self.textField.isFirstResponder) {
        return;
    }
    
    //JGSLog();
    //[self updateHeightConstraints];
}

- (void)keyboardDidChangeFrame:(NSNotification *)noti {
    if (!self.textField.isFirstResponder) {
        return;
    }
    
    //JGSLog();
    //[self updateHeightConstraints];
}

- (void)updateHeightConstraints {
    
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    NSString *orientation = isPortrait ? @"Portrait" : @"Landscape";
    NSString *sizeInfo = [JGSKeyboardSizeInfo() objectForKey:orientation];
    CGSize keyboardSize = CGSizeFromString(sizeInfo);
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow ?: [UIApplication sharedApplication].windows.firstObject;
        safeAreaInsets = window.safeAreaInsets;
    }
    
    CGFloat keyboardHeight = keyboardSize.height + safeAreaInsets.bottom;
    if (self.title.length > 0) {
        keyboardHeight += JGSKeyboardToolbarHeight;
    }
    
    // JGSLog(@"%@, %@", NSStringFromCGRect(self.frame), @(keyboardHeight));
    [self.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.firstItem isEqual:self] && obj.firstAttribute == NSLayoutAttributeHeight && obj.secondItem == nil) {
            // 在文本框第一次开始编辑收到通知 UITextFieldTextDidBeginEditingNotification 时，键盘高度约束尚未添加
            // 此时无法执行高度更新，即使进行更新操作，也不会执行到此处，因此更新无效
            // 首次高度更新必须在收到通知 UIKeyboardWillShowNotification 时进行
            // JGSLog(@"Update Height");
            obj.constant = keyboardHeight;
            *stop = YES;
        }
    }];
}

#pragma mark - View
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview != nil) {
        [self addViewElements];
    }
    else if (self.superview) {
        [self.keyboardTool removeFromSuperview];
        [self.keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
    }
}

- (void)addViewElements {
    
    // 键盘顶部工具条
    if (self.title.length > 0 && self.keyboardTool) {
        
        if ([self.keyboardTool.superview isEqual:self]) {
            return;
        }
        
        //self.keyboardTool.frame = CGRectMake(0, 0, self.frame.size.width, JGSKeyboardToolbarHeight);
        [self addSubview:self.keyboardTool];
        
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.keyboardTool attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.f constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.keyboardTool attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:0];
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:self.keyboardTool attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0];
        [self addConstraints:@[leading, top, trailing]];
    }
    
    // 键盘
    JGSWeakSelf
    [self.keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        JGSStrongSelf
        [obj enableHighlightedWhenTap:self.enableHighlightedWhenTap];
        
        // 默认显示英文字母键盘
        BOOL isShow = idx == 0;
        obj.hidden = !isShow;
        
        if ([obj.superview isEqual:self]) {
            return;
        }
        
        //obj.frame = self.keyboardFrame;
        [self addSubview:obj];
        
        obj.translatesAutoresizingMaskIntoConstraints = NO;
        if (@available(iOS 11.0, *)) {
            
            NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:obj attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.safeAreaLayoutGuide attribute:NSLayoutAttributeLeading multiplier:1.f constant:0];
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:obj attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:0];
            if ([self.keyboardTool.superview isEqual:self]) {
                top = [NSLayoutConstraint constraintWithItem:obj attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.keyboardTool attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
            }
            NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:obj attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.safeAreaLayoutGuide attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0];
            NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:obj attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.safeAreaLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
            [self addConstraints:@[leading, top, trailing, bottom]];
        }
        else {
            
            NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:obj attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.f constant:0];
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:obj attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:0];
            if ([self.keyboardTool.superview isEqual:self]) {
                top = [NSLayoutConstraint constraintWithItem:obj attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.keyboardTool attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
            }
            NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:obj attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0];
            NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:obj attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
            [self addConstraints:@[leading, top, trailing, bottom]];
        }
    }];
    [self refreshKeyboardTool];
}

- (NSArray<JGSBaseKeyboard *> *)keyboards {
    
    if (!_keyboards) {
        NSMutableArray *keyboards = @[].mutableCopy;
        if (self.keyboardOptions & JGSKeyboardOptionLetter) {
            [keyboards addObject:self.letterKeyboard];
        }
        if (self.keyboardOptions & JGSKeyboardOptionSymbol) {
            [keyboards addObject:self.symbolKeyboard];
        }
        if (self.keyboardOptions & JGSKeyboardOptionNumber) {
            [keyboards addObject:self.numberKeyboard];
        }
        if (self.keyboardOptions & JGSKeyboardOptionIDCard) {
            [keyboards addObject:self.idCardKeyboard];
        }
        
        // 键盘切换
        JGSWeakSelf
        [keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            JGSStrongSelf
            JGSKeyboardToolbarItem *toolItem = [[JGSKeyboardToolbarItem alloc] initWithTitle:obj.title type:JGSKeyboardToolbarItemTypeSwitch target:self action:@selector(switchKeyboardType:)];
            obj.toolbarItem = toolItem;
        }];
        
        _keyboards = keyboards.copy;
    }
    return _keyboards;
}

- (JGSKeyboardToolbar *)keyboardTool {
    
    if (_keyboardTool) {
        return _keyboardTool;
    }
    
    _keyboardTool = [[JGSKeyboardToolbar alloc] initWithTitle:self.title];
    
    // 完成
    [self.keyboardTool.doneToolbarItem setTarget:self action:@selector(completeTextInput:)];
    
    return _keyboardTool;
}

- (void)refreshKeyboardTool {
    
    if (!self.keyboardTool.superview) {
        return;
    }
    
    // 键盘顶部Tool标题居中，当前键盘对应的切换item不显示
    NSMutableArray *leftItems = @[].mutableCopy;
    if (self.keyboards.count > 1) {
        [self.keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (obj.isHidden) {
                [leftItems addObject:obj.toolbarItem];
            }
        }];
    }
    
    self.keyboardTool.leftToolbarItems = leftItems;
}

- (JGSLetterKeyboard *)letterKeyboard {
    
    if (!_letterKeyboard) {
        JGSWeakSelf
        _letterKeyboard = [[JGSLetterKeyboard alloc] initWithFrame:self.keyboardFrame type:(JGSKeyboardTypeLetter) returnKeyType:self.returnType keyInput:^(JGSBaseKeyboard * _Nonnull kyboard, JGSKeyboardKey * _Nonnull key, JGSKeyboardKeyEvents keyEvent) {
            JGSStrongSelf
            [self keyboardKeyAction:kyboard key:key keyEvent:keyEvent];
        }];
    }
    return _letterKeyboard;
}

- (JGSSymbolKeyboard *)symbolKeyboard {
    
    if (!_symbolKeyboard) {
        JGSWeakSelf
        _symbolKeyboard = [[JGSSymbolKeyboard alloc] initWithFrame:self.keyboardFrame type:JGSKeyboardTypeSymbol returnKeyType:self.returnType keyInput:^(JGSBaseKeyboard * _Nonnull kyboard, JGSKeyboardKey * _Nonnull key, JGSKeyboardKeyEvents keyEvent) {
            JGSStrongSelf
            [self keyboardKeyAction:kyboard key:key keyEvent:keyEvent];
        }];
        _symbolKeyboard.showFullAngle = self.symbolFullAngle;
        _symbolKeyboard.hidden = YES;
    }
    return _symbolKeyboard;
}

- (JGSNumberKeyboard *)numberKeyboard {
    
    if (!_numberKeyboard) {
        JGSWeakSelf
        _numberKeyboard = [[JGSNumberKeyboard alloc] initWithFrame:self.keyboardFrame type:JGSKeyboardTypeNumber returnKeyType:self.returnType keyInput:^(JGSBaseKeyboard * _Nonnull kyboard, JGSKeyboardKey * _Nonnull key, JGSKeyboardKeyEvents keyEvent) {
            JGSStrongSelf
            [self keyboardKeyAction:kyboard key:key keyEvent:keyEvent];
        }];
        _numberKeyboard.ramdomNum = self.numberPadRandom;
        _numberKeyboard.hidden = YES;
    }
    return _numberKeyboard;
}

- (JGSBaseKeyboard *)idCardKeyboard {
    
    if (!_idCardKeyboard) {
        JGSWeakSelf
        _idCardKeyboard = [[JGSNumberKeyboard alloc] initWithFrame:self.keyboardFrame type:JGSKeyboardTypeIDCard returnKeyType:self.returnType keyInput:^(JGSBaseKeyboard * _Nonnull kyboard, JGSKeyboardKey * _Nonnull key, JGSKeyboardKeyEvents keyEvent) {
            JGSStrongSelf
            [self keyboardKeyAction:kyboard key:key keyEvent:keyEvent];
        }];
        _numberKeyboard.ramdomNum = self.numberPadRandom;
        _idCardKeyboard.hidden = YES;
    }
    return _idCardKeyboard;
}

#pragma mark - Action
- (void)keyboardKeyAction:(JGSBaseKeyboard *)keyboard key:(JGSKeyboardKey *)key keyEvent:(JGSKeyboardKeyEvents)keyEvent {
    
    switch (key.type) {
        case JGSKeyboardKeyTypeInput: {
            [self keyboardInputText:key.text];
        }
            break;
            
        case JGSKeyboardKeyTypeDelete: {
            if (keyEvent == JGSKeyboardKeyEventTapDown) {
                [self keyboardInputText:key.text];
            }
            else if (keyEvent == JGSKeyboardKeyEventLongPressBegin) {
                [self keyboardInputBeginDelete];
            }
            else if (keyEvent == JGSKeyboardKeyEventLongPressEnd) {
                [self keyboardInputEndDelete];
            }
        }
            break;
            
        case JGSKeyboardKeyTypeSwitch2Letter:
        case JGSKeyboardKeyTypeSwitch2Number:
        case JGSKeyboardKeyTypeSwitch2Symbol: {
            
            [self.keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.hidden = YES;
            }];
            
            switch (keyboard.type) {
                case JGSKeyboardTypeLetter: {
                    self.symbolKeyboard.hidden = NO;
                }
                    break;
                    
                case JGSKeyboardTypeSymbol: {
                    self.letterKeyboard.hidden = NO;
                }
                    break;
                    
                case JGSKeyboardTypeNumber: {
                    if (key.type == JGSKeyboardKeyTypeSwitch2Symbol) {
                        self.symbolKeyboard.hidden = NO;
                    }
                    else /*if (key.type == JGSKeyboardKeyTypeSwitch2Letter)*/ {
                        self.letterKeyboard.hidden = NO;
                    }
                }
                    break;
                    
                default:
                    break;
            }
            [self refreshKeyboardTool];
        }
            break;
            
        case JGSKeyboardKeyTypeEnter: {
            [self keyboardInputEnter:key];
        }
            break;
            
        default:
            break;
    }
}

- (void)keyboardInputBeginDelete {
    
    [self.deleteTimer invalidate]; self.deleteTimer = nil;
    if (@available(iOS 10.0, *)) {
        JGSWeakSelf
        self.deleteTimer = [NSTimer timerWithTimeInterval:0.05 repeats:YES block:^(NSTimer * _Nonnull timer) {
            JGSStrongSelf
            [self keyboardInputText:nil];
        }];
    } else {
        self.deleteTimer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(keyboardInputDeleteTimer:) userInfo:nil repeats:YES];
    }
    
    self.deleteTimer.fireDate = [NSDate distantPast];
    [[NSRunLoop mainRunLoop] addTimer:self.deleteTimer forMode:NSRunLoopCommonModes];
}

- (void)keyboardInputDeleteTimer:(NSTimer *)timer {
    [self keyboardInputText:nil];
}

- (void)keyboardInputEndDelete {
    [self.deleteTimer invalidate]; self.deleteTimer = nil;
}

- (void)keyboardInputText:(NSString *)text {
    
    text = text ?: @"";
    if (text.length == 0 && self.textField.text.length == 0) {
        return;
    }
    
    UITextRange *selectedRange = self.textField.selectedTextRange;
    if (!selectedRange) {
        return;
    }
    
    NSRange editRange = NSMakeRange(self.textField.text.length, 0);
    UITextPosition *position = [self.textField positionFromPosition:selectedRange.start offset:0];
    UITextPosition *beginPos = [self.textField beginningOfDocument];
    editRange.location = [self.textField offsetFromPosition:beginPos toPosition:position];
    editRange.length = [self.textField offsetFromPosition:selectedRange.start toPosition:selectedRange.end];
    
    if ([self.textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)] &&
        ![self.textField.delegate textField:self.textField shouldChangeCharactersInRange:editRange replacementString:text]) {
        return;
    }
    
    if (editRange.length > 0 || text.length > 0) {
        [self.textField replaceRange:selectedRange withText:text];
    }
    else {
        UITextPosition *delStart = [self.textField positionFromPosition:selectedRange.start offset:-1];
        UITextRange *delTextRange = [self.textField textRangeFromPosition:delStart toPosition:selectedRange.start];
        [self.textField replaceRange:delTextRange withText:text];
    }
}

- (void)keyboardInputEnter:(JGSKeyboardKey *)sender {
    
    if ([self.textField.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        [self.textField.delegate textFieldShouldReturn:self.textField];
    }
    else {
        [self.textField resignFirstResponder];
    }
}

- (void)switchKeyboardType:(JGSKeyboardToolbarItem *)sender {
    
    [self.keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isShow = [obj.toolbarItem isEqual:sender];
        obj.hidden = !isShow;
    }];
    [self refreshKeyboardTool];
}

- (void)completeTextInput:(JGSKeyboardToolbarItem *)sender {
    [self.textField resignFirstResponder];
}

#pragma mark - End

@end

@implementation UITextField (JGSSecurityKeyboard)

static char kJGSSecurityKeyboardTextFieldOriginKey;
static char kJGSSecurityKeyboardAESEncryptInputCharByCharKey;
static char kJGSSecurityKeyboardTextFieldAESIVKey;
static char kJGSSecurityKeyboardTextFieldAESKeyKey;
static NSString *JGSSecurityKeyboardSecChar = @"•";
static NSInteger JGSSecurityKeyboardAESKeySize = kCCKeySizeAES256;

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        // 重写的系统方法处理，dealloc仅用作日志输出检测页面释放情况，dealloc在ARC不能通过@selector获取
        NSArray<NSString *> *oriSelectors = @[NSStringFromSelector(@selector(text)),
                                              NSStringFromSelector(@selector(setText:)),
                                              NSStringFromSelector(@selector(replaceRange:withText:)),
                                              NSStringFromSelector(@selector(setSecureTextEntry:)),
                                              NSStringFromSelector(@selector(canPerformAction:withSender:)),
        ];
        for (NSString *oriSelName in oriSelectors) {
            
            SEL originalSelector = NSSelectorFromString(oriSelName);
            SEL swizzledSelector = NSSelectorFromString([@"JGSSwizzing_" stringByAppendingString:oriSelName]);
            
            JGSRuntimeSwizzledMethod(class, originalSelector, swizzledSelector);
        }
    });
}

- (void)setJg_securityOriginText:(NSString *)jg_securityOriginText {
    
    if (!self.jg_aesEncryptInputCharByChar) {
        NSString *secText = [self jg_aesOperation:kCCEncrypt text:jg_securityOriginText];
        objc_setAssociatedObject(self, &kJGSSecurityKeyboardTextFieldOriginKey, secText, OBJC_ASSOCIATION_COPY_NONATOMIC);
        return;
    }
    
    NSMutableArray<NSString *> *secText = @[].mutableCopy;
    for (NSInteger i = 0; i < jg_securityOriginText.length; i++) {
        NSString *charText = [jg_securityOriginText substringWithRange:NSMakeRange(i, 1)];
        [secText addObject:[self jg_aesOperation:kCCEncrypt text:charText]];
    }
    objc_setAssociatedObject(self, &kJGSSecurityKeyboardTextFieldOriginKey, secText.copy, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)jg_securityOriginText {
    
    if (!self.jg_aesEncryptInputCharByChar) {
        
        NSString *secText = objc_getAssociatedObject(self, &kJGSSecurityKeyboardTextFieldOriginKey);
        return [self jg_aesOperation:kCCDecrypt text:secText];
    }
    
    NSArray<NSString *> *secText = objc_getAssociatedObject(self, &kJGSSecurityKeyboardTextFieldOriginKey);
    NSMutableString *jg_securityOriginText = @"".mutableCopy;
    for (NSString *obj in secText) {
        [jg_securityOriginText appendString:[self jg_aesOperation:kCCDecrypt text:obj]];
    }
    
    return jg_securityOriginText.copy;
}

- (void)jgsCheckClearInputChangeText {
    
    // 点击clear、paste输入时发送UITextFieldTextDidChangeNotification通知，无其他回调
    // 因安全键盘输入时禁止选择、全选、复制、剪切，仅空白状态时允许粘贴
    // 此处在长度不一致时需要设置text以更新jg_securityOriginText
    if (self.JGSSwizzing_text.length == self.jg_securityOriginText.length) {
        return;
    }
    self.text = [self JGSSwizzing_text];
}

- (void)JGSSwizzing_setText:(NSString *)text {
    
    self.jg_securityOriginText = text;
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]] && self.isSecureTextEntry) {
        for (NSInteger i = 0; i < text.length; i++) {
            text = [text stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:JGSSecurityKeyboardSecChar];
        }
    }
    [self JGSSwizzing_setText:text];
}

- (NSString *)JGSSwizzing_text {
    
    // textField.text 不能直接返回输入原始值，原始值通过 textField.jg_securityOriginText 获取，避免调试hook系统接口抓取输入原始值
    //if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
    //    return self.jg_securityOriginText;
    //}
    return [self JGSSwizzing_text];
}

- (BOOL)JGSSwizzing_canPerformAction:(SEL)action withSender:(id)sender {
    
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        // 安全键盘输入时禁止选择、全选、复制、剪切
        // 仅空白状态是允许粘贴
        if (action == @selector(paste:) && self.text.length > 0) {
            return NO; // 空白状态是允许粘贴
        }
        else if (action == @selector(select:) || action == @selector(selectAll:) || action == @selector(copy:) || action == @selector(cut:)) {
            return NO; // 禁止选择、全选、复制、剪切
        }
    }
    
    return [self JGSSwizzing_canPerformAction:action withSender:sender];
}

- (void)JGSSwizzing_replaceRange:(UITextRange *)range withText:(NSString *)text {
    
    // 记录的原字符串更新
    UITextPosition *begin = self.beginningOfDocument;
    UITextPosition *rangeStart = range.start;
    UITextPosition *rangeEnd = range.end;
    
    NSInteger location = [self offsetFromPosition:begin toPosition:rangeStart];
    NSInteger length = [self offsetFromPosition:rangeStart toPosition:rangeEnd];
    
    NSString *origin = self.jg_securityOriginText ?: @"";
    origin = [origin stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:text];
    self.jg_securityOriginText = origin;
    
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]] && self.isSecureTextEntry) {
        // 加密
        text = [self secTextWithText:text];
    }
    [self JGSSwizzing_replaceRange:range withText:text];
}

- (void)JGSSwizzing_setSecureTextEntry:(BOOL)secureTextEntry {
    
    [self JGSSwizzing_setSecureTextEntry:secureTextEntry];
    self.text = self.jg_securityOriginText;
}

- (NSString *)secTextWithText:(NSString *)text {
    
    for (NSInteger i = 0; i < text.length; i++) {
        text = [text stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:JGSSecurityKeyboardSecChar];
    }
    return text;
}

#pragma mark - AES
- (void)setJg_aesEncryptInputCharByChar:(BOOL)jg_aesEncryptInputCharByChar {
    objc_setAssociatedObject(self, &kJGSSecurityKeyboardAESEncryptInputCharByCharKey, @(jg_aesEncryptInputCharByChar), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)jg_aesEncryptInputCharByChar {
    
    NSNumber *aesEncrypt = objc_getAssociatedObject(self, &kJGSSecurityKeyboardAESEncryptInputCharByCharKey);
    return aesEncrypt ? [aesEncrypt boolValue] : NO;
}

- (NSString *)jg_aesBase64EncodeString:(NSString *)string {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    // 选择NSDataBase64EncodingEndLineWithLineFeed保持Android、ios、后台统一
    return [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (NSString *)jg_aesOperationIv {
    
    NSString *aesIv = objc_getAssociatedObject(self, &kJGSSecurityKeyboardTextFieldAESIVKey);
    if (aesIv.length > 0) {
        return aesIv;
    }
    
    NSInteger ivSize = kCCBlockSizeAES128;
    NSString *originStr = [NSString stringWithFormat:@"%p-%@-%@", self, NSStringFromClass([self class]), [NSProcessInfo processInfo].processName];
    // 最少两次Base64
    NSString *base64 = [self jg_aesBase64EncodeString:originStr];
    do {
        base64 = [self jg_aesBase64EncodeString:base64];
    } while (base64.length < ivSize);
    
    // sub(两次base64, 0, 16)
    base64 = [base64 substringToIndex:ivSize];
    aesIv = base64.copy;
    
    objc_setAssociatedObject(self, &kJGSSecurityKeyboardTextFieldAESIVKey, aesIv, OBJC_ASSOCIATION_COPY_NONATOMIC);
    //JGSLog(@"\nOri:\t%@\nIv:\t%@", originStr, aesIv);
    return aesIv;
}

- (NSString *)jg_aesOperationKey {
    
    NSString *aesKey = objc_getAssociatedObject(self, &kJGSSecurityKeyboardTextFieldAESKeyKey);
    if (aesKey.length > 0) {
        return aesKey;
    }
    
    NSInteger keySize = JGSSecurityKeyboardAESKeySize;
    NSString *originStr = [NSString stringWithFormat:@"%p-%@-%@", self, NSStringFromClass([self class]), [NSProcessInfo processInfo].processName];
    // 最少两次Base64
    NSString *base64 = [self jg_aesBase64EncodeString:originStr];
    do {
        base64 = [self jg_aesBase64EncodeString:base64];
    } while (base64.length < keySize);
    
    // reverse(sub(两次base64, 0, 16))
    base64 = [base64 substringToIndex:keySize];
    NSMutableString *key = [NSMutableString stringWithCapacity:base64.length];
    for (NSInteger i = 0; i < base64.length; i++) {
        [key insertString:[base64 substringWithRange:NSMakeRange(i, 1)] atIndex:0];
    }
    
    aesKey = key.copy;
    objc_setAssociatedObject(self, &kJGSSecurityKeyboardTextFieldAESKeyKey, aesKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
    //JGSLog(@"\nOri:\t%@\nKey:\t%@", originStr, aesKey);
    return aesKey;
}

- (NSString *)jg_aesOperation:(CCOperation)operation text:(NSString *)text {
    
    if (text.length == 0) {
        return nil;
    }
    
    NSData *data = operation == kCCEncrypt ? [text dataUsingEncoding:NSUTF8StringEncoding] : [[NSData alloc] initWithBase64EncodedString:text options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (data.length == 0) {
        return nil;
    }
    
    NSString *key = [self jg_aesOperationKey];
    NSString *iv = [self jg_aesOperationIv];
    NSUInteger dataLength = data.length;
    void const *contentBytes = data.bytes;
    void const *keyBytes = [key dataUsingEncoding:NSUTF8StringEncoding].bytes;
    
    // 初始偏移向量，默认全置零，避免iv长度不符合规范情况导致无法解析
    // 便宜向量长度为块大小 BlockSize
    char ivBytes[kCCBlockSizeAES128 + 1];
    memset(ivBytes, 0, sizeof(ivBytes));
    [iv getCString:ivBytes maxLength:sizeof(ivBytes) encoding:NSUTF8StringEncoding];
    
    size_t operationSize = dataLength + kCCBlockSizeAES128; // 密文长度 <= 明文长度 + BlockSize
    void *operationBytes = malloc(operationSize);
    if (operationBytes == NULL) {
        return nil;
    }
    
    size_t actualOutSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation, kCCAlgorithmAES, kCCOptionPKCS7Padding, keyBytes, JGSSecurityKeyboardAESKeySize, ivBytes, contentBytes, dataLength, operationBytes, operationSize, &actualOutSize);
    if (cryptStatus != kCCSuccess) {
        
        free(operationBytes); operationBytes = NULL;
        return nil;
    }
    
    // operationBytes 自动释放
    NSData *aesData = [NSData dataWithBytesNoCopy:operationBytes length:actualOutSize];
    if (aesData.length == 0) {
        return nil;
    }
    
    switch (operation) {
        case kCCEncrypt: {
            
            // 加密Data不能直接转UTF8字符串，需使用base64编码
            // 选择NSDataBase64EncodingEndLineWithLineFeed保持Android、ios、后台统一
            return [aesData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        }
            break;
            
        case kCCDecrypt: {
            
            // 解密Data不能直接转UTF8字符串，需使用base64解码
            return [[NSString alloc] initWithData:aesData encoding:NSUTF8StringEncoding];
        }
            break;
    }
    
    return nil;
}

#pragma mark - End

@end
