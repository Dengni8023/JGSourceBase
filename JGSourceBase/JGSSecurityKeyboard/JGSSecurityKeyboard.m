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
#import "JGSBase+JGSPrivate.h"
#import "JGSCategory+NSData.h"
#import "JGSCategory+NSString.h"
#import <objc/runtime.h>

@interface JGSSecurityKeyboard ()

@property (nonatomic, assign, readonly) JGSKeyboardOptions keyboardOptions;
@property (nonatomic, assign, readonly) CGRect keyboardFrame;

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
    //JGSPrivateLog(@"<%@: %p>", NSStringFromClass([self class]), self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)keyboardWithTextInput:(id<JGSSecurityKeyboardTextInput>)textInput title:(NSString *)title {
    return [[self alloc] initWithTextInput:textInput title:title options:kNilOptions];
}

+ (instancetype)numberKeyboardWithTextInput:(id<JGSSecurityKeyboardTextInput>)textInput title:(NSString *)title {
    return [[self alloc] initWithTextInput:textInput title:title options:JGSKeyboardOptionNumber];
}

+ (instancetype)idCardKeyboardWithTextInput:(id<JGSSecurityKeyboardTextInput>)textInput title:(NSString *)title {
    return [[self alloc] initWithTextInput:textInput title:title options:JGSKeyboardOptionIDCard];
}

#pragma mark - Deprecated
+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(NSString *)title {
    return [self keyboardWithTextInput:textField title:title];
}

+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum {
    
    JGSSecurityKeyboard *instance = [self keyboardWithTextInput:textField title:title];
    if (instance) {
        
        instance.randomNumPad = randomNum;
    }
    return instance;
}

+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum enableFullAngle:(BOOL)fullAngle {
    
    JGSSecurityKeyboard *instance = [self keyboardWithTextInput:textField title:title];
    if (instance) {
        
        instance.randomNumPad = randomNum;
        instance.enableFullAngle = fullAngle;
    }
    return instance;
}

+ (instancetype)numberKeyboardWithTextField:(UITextField *)textField title:(NSString *)title {
    return [self numberKeyboardWithTextInput:textField title:title];
}

+ (instancetype)numberKeyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum {
    
    JGSSecurityKeyboard *instance = [self numberKeyboardWithTextField:textField title:title];
    if (instance) {
        
        instance.randomNumPad = randomNum;
    }
    return instance;
}

+ (instancetype)idCardKeyboardWithTextField:(UITextField *)textField title:(NSString *)title {
    return [self idCardKeyboardWithTextInput:textField title:title];
}

+ (instancetype)idCardKeyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum {
    
    JGSSecurityKeyboard *instance = [self idCardKeyboardWithTextInput:textField title:title];
    if (instance) {
        
        instance.randomNumPad = randomNum;
    }
    return instance;
}

#pragma mark - init
- (instancetype)initWithTextInput:(id<JGSSecurityKeyboardTextInput>)textInput title:(NSString *)title options:(JGSKeyboardOptions)options {
    
    self = [super init];
    if (self) {
        
        self.backgroundColor = JGSKeyboardBackgroundColor();
        
        self.aesEncryptInputCharByChar = NO;
        self.randomNumPad = YES;
        self.enableFullAngle = NO;
        self.enableHighlightedWhenTap = YES;
        
        // UITextField: clear、paste等处理
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
        // UITextView: clear、paste等处理
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputTextDidChange:) name:UITextViewTextDidChangeNotification object:nil];
        
        // 应用方向变化等导致键盘大小变化处理，考虑通知接收频率、及性能问题
        // 仅监听 UIKeyboardWillChangeFrameNotification 即可实现修改键盘高度操作
        // 通知执行顺序大概（键盘高度不实际更新是存在差异情况）如下，如在收到通知后更新键盘高度，部分通知会重复执行：
        // 1、UIApplicationDidChangeStatusBarOrientationNotification：应用转屏后执行一次，最先执行
        // 2、UIKeyboardWillChangeFrameNotification：键盘弹出、应用转屏均会执行，如果收到通知不进行键盘高度更新，则仅执行一次，每更新一次则会重复执行一次
        // 3、UIKeyboardDidChangeFrameNotification：与keyboardWillChangeFrame配对执行，如果收到通知不进行键盘高度更新，则仅执行一次，每更新一次则会重复执行两次
        // 4、UIKeyboardWillShowNotification：键盘弹出、应用转屏均会执行，如果收到通知不进行键盘高度更新，则仅执行一次，每更新一次则会重复执行一次
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        _title = title;//.length > 0 ? title : self.textField.placeholder;
        _textInput = textInput;
        
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
        
        _keyboardFrame = CGRectMake(0, self.title.length > 0 ? JGSKeyboardToolbarHeight : 0, keyboardSize.width, keyboardSize.height);
        CGFloat keyboardHeight = keyboardSize.height + (self.title.length > 0 ? JGSKeyboardToolbarHeight : 0);
        
        // 此处做初步的键盘高度计算，精确高度待键盘展示时更新高度约束
        // 此处高度必须非0，否则键盘不会展示，高度更新无效
        self.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), keyboardHeight);
        
        //[self addViewElements];
    }
    return self;
}

#pragma mark - Notification
- (void)textInputTextDidChange:(NSNotification *)noti {
    
    if ([noti.object isEqual:self.textInput]) {
        [self.textInput jg_textInputTextDidChange];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)noti {
    if (!self.textInput.isFirstResponder && self.textInput) {
        return;
    }
    
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
    
    // JGSPrivateLog(@"%@, %@", NSStringFromCGRect(self.frame), @(keyboardHeight));
    [self.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.firstItem isEqual:self] && obj.firstAttribute == NSLayoutAttributeHeight && obj.secondItem == nil) {
            // JGSPrivateLog(@"Update Height");
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

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (!self.superview && (self.randomPad || self.randomNumPad)) {
        
        // 键盘随机布局时每次键盘重新展示需要重新乱序
        // 因此在键盘隐藏时释放已显示键盘
        // 下次展示时子键盘重新初始化
        _keyboards = nil;
        if (self.randomPad) {
            _letterKeyboard = nil;
            _symbolKeyboard = nil;
        }
        if (self.randomNumPad) {
            _numberKeyboard = nil;
            _idCardKeyboard = nil;
        }
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
        _letterKeyboard = [[JGSLetterKeyboard alloc] initWithFrame:self.keyboardFrame type:(JGSKeyboardTypeLetter) securityKeyboard:self keyInput:^(JGSBaseKeyboard * _Nonnull kyboard, JGSKeyboardKey * _Nonnull key, JGSKeyboardKeyEvents keyEvent) {
            JGSStrongSelf
            [self keyboardKeyAction:kyboard key:key keyEvent:keyEvent];
        }];
    }
    return _letterKeyboard;
}

- (JGSSymbolKeyboard *)symbolKeyboard {
    
    if (!_symbolKeyboard) {
        JGSWeakSelf
        _symbolKeyboard = [[JGSSymbolKeyboard alloc] initWithFrame:self.keyboardFrame type:JGSKeyboardTypeSymbol securityKeyboard:self keyInput:^(JGSBaseKeyboard * _Nonnull kyboard, JGSKeyboardKey * _Nonnull key, JGSKeyboardKeyEvents keyEvent) {
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
        _numberKeyboard = [[JGSNumberKeyboard alloc] initWithFrame:self.keyboardFrame type:JGSKeyboardTypeNumber securityKeyboard:self keyInput:^(JGSBaseKeyboard * _Nonnull kyboard, JGSKeyboardKey * _Nonnull key, JGSKeyboardKeyEvents keyEvent) {
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
        _idCardKeyboard = [[JGSNumberKeyboard alloc] initWithFrame:self.keyboardFrame type:JGSKeyboardTypeIDCard securityKeyboard:self keyInput:^(JGSBaseKeyboard * _Nonnull kyboard, JGSKeyboardKey * _Nonnull key, JGSKeyboardKeyEvents keyEvent) {
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
    
    [self.textInput jg_keyboardInputText:text];
}

- (void)keyboardInputEnter:(JGSKeyboardKey *)sender {
    [self.textInput jg_keyboardDidInputReturnKey];
}

- (void)switchKeyboardType:(JGSKeyboardToolbarItem *)sender {
    
    [self.keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isShow = [obj.toolbarItem isEqual:sender];
        obj.hidden = !isShow;
    }];
    [self refreshKeyboardTool];
}

- (void)completeTextInput:(JGSKeyboardToolbarItem *)sender {
    [self.textInput resignFirstResponder];
}

#pragma mark - Property
- (BOOL)enableHighlightedWhenTap {
    
    if ([[UIScreen mainScreen] isCaptured]) {
        return NO;
    }
    
    return _enableHighlightedWhenTap;
}

- (UITextField *)textField  {
    return [self.textInput isKindOfClass:[UITextField class]] ? (UITextField *)self.textInput : nil;
}

#pragma mark - End

@end

@implementation JGSSecurityKeyboard (UITextInput)

static char kJGSSecurityKeyboardTextFieldAESIVKey; // AES 逐字符加密 iv
static char kJGSSecurityKeyboardTextFieldAESKeyKey; // AES 逐字符加密 key
static NSInteger JGSSecurityKeyboardAESKeySize = kCCKeySizeAES256;

#pragma mark - AES
- (NSDictionary<NSString *, NSString *> *)aes256KeyIvPair:(size_t)keyLength {
    
    /// TODO: KEY、IV安全处理，加解密参数不能原样存放在代码中
    /// 外部测试方式：
    /// 安全测试hook加解密方法获取加解密key、iv
    /// 应用包逆向后代码搜索hook获取到的参数
    /// 安全考虑代码中不能存在hook获取到的参数的原样数据
    NSCAssert(keyLength == kCCKeySizeAES128 || keyLength == kCCKeySizeAES192 || keyLength == kCCKeySizeAES256, @"The keyLength of AES must be (%@、%@、%@)", @(kCCKeySizeAES128), @(kCCKeySizeAES192), @(kCCKeySizeAES256));
    
    NSMutableDictionary<NSNumber *, NSDictionary<NSString *, NSString *> *> *instance = nil;
    
    // 已经生成对应长度的key-iv则返回
    NSDictionary<NSString *, NSString *> *keyIvPair = [instance objectForKey:@(keyLength)];
    if (keyIvPair.allKeys.count == 1 && keyIvPair.allValues.count == 1) {
        return keyIvPair;
    }
    
    NSString *originStr = [NSString stringWithFormat:@"%p-%@-%@-%@", self, NSStringFromClass([self class]), [NSProcessInfo processInfo].processName, @([[NSDate date] timeIntervalSince1970])];
    // 最少两次Base64
    NSString *base64 = [originStr jg_base64EncodeString];
    do {
        base64 = [base64 jg_base64EncodeString];
    } while (base64.length < keyLength);
    
    // iv: sub(多次base64, 0, 16)
    size_t blockSize = kCCBlockSizeAES128; // iv偏移，AES块最大为 kCCBlockSizeAES128
    NSString *iv = [base64 substringToIndex:blockSize];
    
    // reverse(sub(多次base64, 0, 32))
    NSString *tmp = [base64 substringToIndex:keyLength];
    NSMutableString *key = @"".mutableCopy;
    for (int i = 0; i < keyLength; i++) {
        NSString *str = [tmp substringWithRange:NSMakeRange(keyLength - 1 - i, 1)];
        [key appendString:str];
    }
    
    keyIvPair = @{key: iv};
    instance = instance ?: @{}.mutableCopy;
    [instance setObject:keyIvPair forKey:@(keyLength)];
    
    return keyIvPair;
}

- (NSString *)aesOperation:(CCOperation)operation text:(NSString *)text {
    
    if (text.length == 0) {
        return nil;
    }
    
    NSDictionary *keyIvPair = [self aes256KeyIvPair:JGSSecurityKeyboardAESKeySize];
    NSString *key = keyIvPair.allKeys.firstObject;
    NSString *iv = keyIvPair.allValues.firstObject;
    return [text jg_AESOperation:operation keyLength:JGSSecurityKeyboardAESKeySize key:key iv:iv];
}

@end
