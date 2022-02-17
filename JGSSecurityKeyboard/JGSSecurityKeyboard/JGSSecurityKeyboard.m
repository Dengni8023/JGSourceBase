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

@interface JGSSecurityKeyboard ()

@property (nonatomic, assign) JGSKeyboardOptions keyboardOptions;
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
    return [[self alloc] initWithTextField:textField title:title options:kNilOptions];
}

+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum {
    textField.jg_randomNumPad = randomNum;
    return [self keyboardWithTextField:textField title:title];
}

+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum enableFullAngle:(BOOL)fullAngle {
    textField.jg_randomNumPad = randomNum;
    textField.jg_enableFullAngle = fullAngle;
    return [self keyboardWithTextField:textField title:title];
}

+ (instancetype)numberKeyboardWithTextField:(UITextField *)textField title:(NSString *)title {
    return [[self alloc] initWithTextField:textField title:title options:JGSKeyboardOptionNumber];
}

+ (instancetype)numberKeyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum {
    
    textField.jg_randomNumPad = randomNum;
    return [self numberKeyboardWithTextField:textField title:title];
}

+ (instancetype)idCardKeyboardWithTextField:(UITextField *)textField title:(NSString *)title {
    return [[self alloc] initWithTextField:textField title:title options:JGSKeyboardOptionIDCard];
}

+ (instancetype)idCardKeyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum {
    
    textField.jg_randomNumPad = randomNum;
    return [self idCardKeyboardWithTextField:textField title:title];
}

- (instancetype)initWithTextField:(UITextField *)textField title:(NSString *)title options:(JGSKeyboardOptions)options {
    
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
        
        _textField = textField;
        _title = title;//.length > 0 ? title : self.textField.placeholder;
        _keyboardOptions = options & (JGSKeyboardOptionLetter | JGSKeyboardOptionSymbol | JGSKeyboardOptionNumber | JGSKeyboardOptionIDCard);
        if (!_keyboardOptions) {
            _keyboardOptions = (JGSKeyboardOptionLetter | JGSKeyboardOptionSymbol);
            if (self.title.length > 0) {
                // 有标题工具栏时，可从标题工具栏切换纯数字键盘
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

#pragma mark - Notification
- (void)textFieldTextDidChange:(NSNotification *)noti {
    
    if ([noti.object isEqual:self.textField]) {
        [self.textField jg_checkClearInputChangeText];
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
        _letterKeyboard = [[JGSLetterKeyboard alloc] initWithFrame:self.keyboardFrame type:(JGSKeyboardTypeLetter) textField:self.textField keyInput:^(JGSBaseKeyboard * _Nonnull kyboard, JGSKeyboardKey * _Nonnull key, JGSKeyboardKeyEvents keyEvent) {
            JGSStrongSelf
            [self keyboardKeyAction:kyboard key:key keyEvent:keyEvent];
        }];
    }
    return _letterKeyboard;
}

- (JGSSymbolKeyboard *)symbolKeyboard {
    
    if (!_symbolKeyboard) {
        JGSWeakSelf
        _symbolKeyboard = [[JGSSymbolKeyboard alloc] initWithFrame:self.keyboardFrame type:JGSKeyboardTypeSymbol textField:self.textField keyInput:^(JGSBaseKeyboard * _Nonnull kyboard, JGSKeyboardKey * _Nonnull key, JGSKeyboardKeyEvents keyEvent) {
            JGSStrongSelf
            [self keyboardKeyAction:kyboard key:key keyEvent:keyEvent];
        }];
        _symbolKeyboard.hidden = YES;
    }
    return _symbolKeyboard;
}

- (JGSNumberKeyboard *)numberKeyboard {
    
    if (!_numberKeyboard) {
        JGSWeakSelf
        _numberKeyboard = [[JGSNumberKeyboard alloc] initWithFrame:self.keyboardFrame type:JGSKeyboardTypeNumber textField:self.textField keyInput:^(JGSBaseKeyboard * _Nonnull kyboard, JGSKeyboardKey * _Nonnull key, JGSKeyboardKeyEvents keyEvent) {
            JGSStrongSelf
            [self keyboardKeyAction:kyboard key:key keyEvent:keyEvent];
        }];
        _numberKeyboard.hidden = YES;
    }
    return _numberKeyboard;
}

- (JGSBaseKeyboard *)idCardKeyboard {
    
    if (!_idCardKeyboard) {
        JGSWeakSelf
        _idCardKeyboard = [[JGSNumberKeyboard alloc] initWithFrame:self.keyboardFrame type:JGSKeyboardTypeIDCard textField:self.textField keyInput:^(JGSBaseKeyboard * _Nonnull kyboard, JGSKeyboardKey * _Nonnull key, JGSKeyboardKeyEvents keyEvent) {
            JGSStrongSelf
            [self keyboardKeyAction:kyboard key:key keyEvent:keyEvent];
        }];
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
    
    if (self.textField.returnKeyType != UIReturnKeyNext) {
        [self.textField resignFirstResponder];
    }
    
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
