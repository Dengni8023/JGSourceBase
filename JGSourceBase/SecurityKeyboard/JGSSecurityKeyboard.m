//
//  JGSSecurityKeyboard.m
//  
//
//  Created by 梅继高 on 2019/5/29.
//

#import "JGSSecurityKeyboard.h"
#import "JGSLetterKeyboard.h"
#import "JGSNumberKeyboard.h"
#import "JGSSymbolKeyboard.h"
#import "JGSBase.h"
#import <objc/runtime.h>

@interface UITextField (JGSSecurityKeyboard)

@property (nonatomic, copy) NSString *jgsSecurityOriginText;

// 右侧clear点击清空输入文本，不执行replace操作，需要检查记录的输入文本与文本框文本长度是否一致
- (void)jgsCheckClearInputChangeText;

@end

@interface JGSSecurityKeyboard ()

@property (nonatomic, assign) JGSKeyboardOptions keyboardOptions;
@property (nonatomic, assign) JGSKeyboardReturnType returnType;
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
        
        // 应用方向变化处理
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillChangeOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        
        self.backgroundColor = JGSKeyboardBackgroundColor();
        JGSKeyboardNumberPadRandomEnable(randomNum); // 数字键盘随机开关
        JGSKeyboardSymbolFullAngleEnable(fullAngle); // 字符键盘支持全角
        
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
        
        CGFloat keyboardWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat itemWidth = floor((keyboardWidth - JGSKeyboardInteritemSpacing() * JGSKeyboardMaxItemsInLine) / JGSKeyboardMaxItemsInLine);
        CGFloat itemHeight = floor(itemWidth / JGSKeyboardKeyWidthHeightRatio());
        CGFloat keyboardHeight = JGSKeyboardKeyLineSpacing() + (itemHeight + JGSKeyboardKeyLineSpacing()) * JGSKeyboardLinesNumber;
        self.keyboardFrame = CGRectMake(0, 0, keyboardWidth, keyboardHeight);
        if (self.title.length > 0) {
            self.keyboardFrame = CGRectMake(0, JGSKeyboardToolbarHeight, keyboardWidth, keyboardHeight);
            keyboardHeight += JGSKeyboardToolbarHeight;
        }
        if (@available(iOS 11.0, *)) {
            UIWindow *window = [UIApplication sharedApplication].keyWindow ?: [UIApplication sharedApplication].windows.firstObject;
            keyboardHeight += window.safeAreaInsets.bottom;
        }
        self.frame = CGRectMake(0, 0, keyboardWidth, keyboardHeight);
        
        [self addViewElements];
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

//- (void)applicationWillChangeOrientation:(NSNotification *)noti {
//    if (!self.textField.isFirstResponder) {
//        return;
//    }
//
//    self.textField.inputView = nil;
//}
//
//- (void)applicationDidChangeOrientation:(NSNotification *)noti {
//    if (!self.textField.isFirstResponder) {
//        return;
//    }
//
//    JGSLog(@"%@", NSStringFromCGRect(self.frame));
//}
//
//- (void)keyboardWillChangeFrame:(NSNotification *)noti {
//    if (!self.textField.isFirstResponder) {
//        return;
//    }
//
//    JGSLog(@"%@: %@", noti.name, noti.userInfo);
//}
//
//- (void)keyboardDidChangeFrame:(NSNotification *)noti {
//    if (!self.textField.isFirstResponder) {
//        return;
//    }
//
//    CGFloat keyboardWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
//    CGFloat itemWidth = floor((keyboardWidth - JGSKeyboardInteritemSpacing() * JGSKeyboardMaxItemsInLine) / JGSKeyboardMaxItemsInLine);
//    CGFloat itemHeight = floor(itemWidth / JGSKeyboardKeyWidthHeightRatio());
//    CGFloat keyboardHeight = JGSKeyboardKeyLineSpacing() + (itemHeight + JGSKeyboardKeyLineSpacing()) * JGSKeyboardLinesNumber;
//    self.keyboardFrame = CGRectMake(0, 0, keyboardWidth, keyboardHeight);
//    if (self.title.length > 0) {
//        self.keyboardFrame = CGRectMake(0, JGSKeyboardToolbarHeight, keyboardWidth, keyboardHeight);
//        keyboardHeight += JGSKeyboardToolbarHeight;
//    }
//    if (@available(iOS 11.0, *)) {
//        UIWindow *window = [UIApplication sharedApplication].keyWindow ?: [UIApplication sharedApplication].windows.firstObject;
//        keyboardHeight += window.safeAreaInsets.bottom;
//    }
//    self.frame = CGRectMake(0, 0, keyboardWidth, keyboardHeight);
////    self.textField.inputView = self;
//
//    JGSLog(@"%@: %@", noti.name, noti.userInfo);
//}
//
//- (void)textFieldTextDidBeginEditing:(NSNotification *)noti {
//    if (![noti.object isEqual:self.textField]) {
//        return;
//    }
//
//    CGFloat keyboardWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
//    CGFloat itemWidth = floor((keyboardWidth - JGSKeyboardInteritemSpacing() * JGSKeyboardMaxItemsInLine) / JGSKeyboardMaxItemsInLine);
//    CGFloat itemHeight = floor(itemWidth / JGSKeyboardKeyWidthHeightRatio());
//    CGFloat keyboardHeight = JGSKeyboardKeyLineSpacing() + (itemHeight + JGSKeyboardKeyLineSpacing()) * JGSKeyboardLinesNumber;
//    self.keyboardFrame = CGRectMake(0, 0, keyboardWidth, keyboardHeight);
//    if (self.title.length > 0) {
//        self.keyboardFrame = CGRectMake(0, JGSKeyboardToolbarHeight, keyboardWidth, keyboardHeight);
//        keyboardHeight += JGSKeyboardToolbarHeight;
//    }
//    if (@available(iOS 11.0, *)) {
//        UIWindow *window = [UIApplication sharedApplication].keyWindow ?: [UIApplication sharedApplication].windows.firstObject;
//        keyboardHeight += window.safeAreaInsets.bottom;
//    }
//    self.frame = CGRectMake(0, 0, keyboardWidth, keyboardHeight);
//
//    JGSLog(@"%@", NSStringFromCGRect(self.frame));
//}

#pragma mark - View
//- (void)layoutSubviews {
//    [super layoutSubviews];
//    
//    JGSLog(@"%@", NSStringFromCGRect(self.frame));
//    
//    // 键盘顶部工具条
//    if (self.title.length > 0 && self.keyboardTool) {
//        self.keyboardTool.frame = CGRectMake(0, 0, self.frame.size.width, JGSKeyboardToolbarHeight);
//    }
//    
//    // 键盘
//    JGSWeakSelf
//    [self.keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        JGSStrongSelf
//        obj.frame = self.keyboardFrame;
//    }];
//}

//- (void)willMoveToSuperview:(UIView *)newSuperview {
//    [super willMoveToSuperview:newSuperview];
//    if (newSuperview) {
//        [self addViewElements];
//    }
//    else if (self.superview) {
//        [self.keyboardTool removeFromSuperview];
//        [self.keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [obj removeFromSuperview];
//        }];
//    }
//}

- (void)addViewElements {
    
    // 键盘顶部工具条
    if (self.title.length > 0 && self.keyboardTool) {
        self.keyboardTool.frame = CGRectMake(0, 0, self.frame.size.width, JGSKeyboardToolbarHeight);
        [self addSubview:self.keyboardTool];
        
        self.keyboardTool.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    // 键盘
    JGSWeakSelf
    [self.keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        JGSStrongSelf
        obj.frame = self.keyboardFrame;
        [self addSubview:obj];
        [obj enableHighlightedWhenTap:self.enableHighlightedWhenTap];
        
        obj.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // 默认显示英文字母键盘
        BOOL isShow = idx == 0;
        obj.hidden = !isShow;
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
    
    _keyboardTool = [[JGSKeyboardToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, JGSKeyboardToolbarHeight) title:self.title];
    
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

@end

@implementation UITextField (JGSSecurityKeyboard)

static char kJGSSecurityKeyboardTextFieldOriginKey;
static NSString *JGSSecurityKeyboardSecChar = @"•";

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

- (void)setJgsSecurityOriginText:(NSString *)jgsSecurityOriginText {
    objc_setAssociatedObject(self, &kJGSSecurityKeyboardTextFieldOriginKey, jgsSecurityOriginText, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)jgsSecurityOriginText {
    return objc_getAssociatedObject(self, &kJGSSecurityKeyboardTextFieldOriginKey);
}

- (void)jgsCheckClearInputChangeText {
    
    // 点击clear、paste输入时发送UITextFieldTextDidChangeNotification通知，无其他回调
    // 因安全键盘输入时禁止选择、全选、复制、剪切，仅空白状态是允许粘贴
    // 此处在长度不一致时需要设置text以更新jgsSecurityOriginText
    if (self.JGSSwizzing_text.length == self.jgsSecurityOriginText.length) {
        return;
    }
    self.text = [self JGSSwizzing_text];
}

- (void)JGSSwizzing_setText:(NSString *)text {
    
    self.jgsSecurityOriginText = text;
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]] && self.isSecureTextEntry) {
        for (NSInteger i = 0; i < text.length; i++) {
            text = [text stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:JGSSecurityKeyboardSecChar];
        }
    }
    [self JGSSwizzing_setText:text];
}

- (NSString *)JGSSwizzing_text {
    
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        return self.jgsSecurityOriginText;
    }
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
    
    NSString *origin = self.jgsSecurityOriginText ?: @"";
    origin = [origin stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:text];
    self.jgsSecurityOriginText = origin;
    
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]] && self.isSecureTextEntry) {
        // 加密
        text = [self secTextWithText:text];
    }
    [self JGSSwizzing_replaceRange:range withText:text];
}

- (void)JGSSwizzing_setSecureTextEntry:(BOOL)secureTextEntry {
    
    [self JGSSwizzing_setSecureTextEntry:secureTextEntry];
    self.text = self.jgsSecurityOriginText;
}

- (NSString *)secTextWithText:(NSString *)text {
    
    for (NSInteger i = 0; i < text.length; i++) {
        text = [text stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:JGSSecurityKeyboardSecChar];
    }
    return text;
}

@end
