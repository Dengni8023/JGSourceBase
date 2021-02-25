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
#import <objc/runtime.h>

@interface UITextField (JGSSecurityKeyboard)

@property (nonatomic, copy) NSString *jgsSecurityOriginText;

// 右侧clear点击清空输入文本，不执行replace操作，需要检查记录的输入文本与文本框文本长度是否一致
- (void)jgsCheckClearInputChangeText;

@end

@interface JGSSecurityKeyboard ()

@property (nonatomic, assign) JGSKeyboardReturnType returnType;
@property (nonatomic, assign) CGRect keyboardFrame;

@property (nonatomic, strong) UIToolbar *keyboardTool;
@property (nonatomic, strong) JGSKeyboardToolbarItem *keyboardTitleItem;
@property (nonatomic, strong) JGSKeyboardToolbarItem *keyboardDoneItem;

@property (nonatomic, strong) JGSLetterKeyboard *letterKeyboard;
@property (nonatomic, strong) JGSSymbolKeyboard *symbolKeyboard;
@property (nonatomic, strong) JGSNumberKeyboard *numberKeyboard;
@property (nonatomic, copy) NSArray<JGSBaseKeyboard *> *keyboards;

@property (nonatomic, strong) NSTimer *deleteTimer;

@end

@implementation JGSSecurityKeyboard

#pragma mark - Life Cycle
- (void)dealloc {
    JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(NSString *)title {
    return [self keyboardWithTextField:textField title:title randomNumPad:YES];
}

+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum {
    return [self keyboardWithTextField:textField title:title randomNumPad:randomNum enableFullAngle:NO];
}

+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum enableFullAngle:(BOOL)fullAngle {
    return [[self alloc] initWithTextField:textField title:title randomNumPad:randomNum enableFullAngle:fullAngle];
}

- (instancetype)initWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)randomNum enableFullAngle:(BOOL)fullAngle {
    
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            
            UITextField *noteField = note.object;
            if ([noteField isEqual:textField] && [noteField isSecureTextEntry]) {
                [noteField jgsCheckClearInputChangeText];
            }
        }];
        
        JGSKeyboardNumberPadRandomEnable(randomNum); // 数字键盘随机开关
        JGSKeyboardSymbolFullAngleEnable(fullAngle); // 字符键盘支持全角
        
        _textField = textField;
        _title = title;//.length > 0 ? title : self.textField.placeholder;
        _returnType = (textField.returnKeyType == UIReturnKeyNext ? JGSKeyboardReturnTypeNext : JGSKeyboardReturnTypeDone);
        
        CGFloat keyboardWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat itemWidth = floor((keyboardWidth - JGSKeyboardInteritemSpacing * JGSKeyboardMaxItemsInLine) / JGSKeyboardMaxItemsInLine);
        CGFloat itemHeight = floor(itemWidth / JGSKeyboardKeyWidthHeightRatio);
        CGFloat keyboardHeight = JGSKeyboardKeyLineSpacing + (itemHeight + JGSKeyboardKeyLineSpacing) * JGSKeyboardLinesNumber;
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
        self.backgroundColor = JGSKeyboardBackgroundColor();
        
        [self addViewElements];
    }
    return self;
}

#pragma mark - View
- (void)addViewElements {
    
    // 键盘顶部工具条
    if (self.title.length > 0 && self.keyboardTool) {
        [self addSubview:self.keyboardTool];
    }
    
    // 键盘
    JGSWeakSelf
    [self.keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        JGSStrongSelf
        [self addSubview:obj];
        
        // 默认显示英文字母键盘
        BOOL isShow = [obj isEqual:self.letterKeyboard];
        obj.toolbarItem.customView.enabled = !isShow;
        obj.hidden = !isShow;
    }];
    [self refreshKeyboardTool];
}

- (NSArray<JGSBaseKeyboard *> *)keyboards {
    
    if (!_keyboards) {
        _keyboards = @[self.letterKeyboard, self.symbolKeyboard, self.numberKeyboard];
    }
    return _keyboards;
}

- (UIToolbar *)keyboardTool {
    
    if (_keyboardTool) {
        return _keyboardTool;
    }
    
    _keyboardTool = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), JGSKeyboardToolbarHeight)];
    _keyboardTool.barTintColor = JGSKeyboardToolBarColor();
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    // 键盘切换
    JGSWeakSelf
    [self.keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        JGSKeyboardToolbarItem *toolItem = [[JGSKeyboardToolbarItem alloc] initWithTitle:obj.title type:JGSKeyboardToolbarItemTypeSwitch action:^(JGSKeyboardToolbarItem * _Nonnull toolbarItem) {
            JGSStrongSelf
            [self switchKeyboardType:toolbarItem];
        }];
        obj.toolbarItem = toolItem;
    }];
    
    // 标题
    _keyboardTitleItem = [[JGSKeyboardToolbarItem alloc] initWithTitle:self.title type:JGSKeyboardToolbarItemTypeTitle action:nil];
    
    // 完成
    _keyboardDoneItem = [[JGSKeyboardToolbarItem alloc] initWithTitle:@"完成" type:JGSKeyboardToolbarItemTypeDone action:^(JGSKeyboardToolbarItem * _Nonnull toolbarItem) {
        JGSStrongSelf
        [self completeTextInput:toolbarItem];
    }];
    
    _keyboardTool.items = @[flexSpace, flexSpace, self.keyboardTitleItem, flexSpace, self.keyboardDoneItem];
    
    return _keyboardTool;
}

- (void)refreshKeyboardTool {
    
    if (!self.keyboardTool.superview) {
        return;
    }
    
    // 键盘顶部Tool标题居中，当前键盘对应的切换item不显示
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    JGSWeakSelf
    NSMutableArray *leftItems = @[].mutableCopy;
    NSMutableArray *rightItems = @[self.keyboardDoneItem].mutableCopy;
    [self.keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.isHidden) {
            [leftItems addObject:obj.toolbarItem];
            [leftItems addObject:flexSpace];
            
            [rightItems insertObject:flexSpace atIndex:0];
            if (idx > 0) {
                [rightItems insertObject:flexSpace atIndex:0];
            }
        }
    }];
    
    NSMutableArray *toolItems = leftItems.mutableCopy;
    [toolItems addObject:self.keyboardTitleItem];
    [toolItems addObjectsFromArray:rightItems];
    [self.keyboardTool setItems:toolItems];
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
                obj.toolbarItem.customView.enabled = YES;
            }];
            
            switch (keyboard.type) {
                case JGSKeyboardTypeLetter: {
                    self.symbolKeyboard.hidden = NO;
                    self.symbolKeyboard.toolbarItem.customView.enabled = NO;
                }
                    break;
                    
                case JGSKeyboardTypeSymbol: {
                    self.letterKeyboard.hidden = NO;
                    self.letterKeyboard.toolbarItem.customView.enabled = NO;
                }
                    break;
                    
                case JGSKeyboardTypeNumber: {
                    if (key.type == JGSKeyboardKeyTypeSwitch2Symbol) {
                        self.symbolKeyboard.hidden = NO;
                        self.symbolKeyboard.toolbarItem.customView.enabled = NO;
                    }
                    else /*if (key.type == JGSKeyboardKeyTypeSwitch2Letter)*/ {
                        self.letterKeyboard.hidden = NO;
                        self.letterKeyboard.toolbarItem.customView.enabled = NO;
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
        obj.toolbarItem.customView.enabled = !isShow;
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
        
        Class cls = [self class];
        // 重写的系统方法处理，dealloc仅用作日志输出检测页面释放情况，dealloc在ARC不能通过@selector获取
        NSArray<NSString *> *oriSelectors = @[NSStringFromSelector(@selector(text)),
                                              NSStringFromSelector(@selector(setText:)),
                                              NSStringFromSelector(@selector(replaceRange:withText:)),
                                              NSStringFromSelector(@selector(canPerformAction:withSender:)),
                                              ];
        for (NSString *oriSelName in oriSelectors) {
            
            SEL originSelector = NSSelectorFromString(oriSelName);
            Method originMethod = class_getInstanceMethod(cls, originSelector);
            IMP originImpl = method_getImplementation(originMethod);
            
            SEL swizzledSelector = NSSelectorFromString([@"JGSSwizzing_" stringByAppendingString:oriSelName]);
            Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
            IMP swizzledImpl = method_getImplementation(swizzledMethod);
            
            /*
             严谨的方法替换逻辑：检查运行时源方法的实现是否已执行
             将新的实现添加到源方法，用来做检查用，避免源方法没有实现（有实现，但运行时尚未执行到该方法的实现）
             如果源方法已有实现，会返回 NO，此时直接交换源方法与新方法的实现即可
             如果源方法尚未实现，会返回 YES，此时新的实现已替换原方法的实现，需要将源方法的实现替换到新方法
             
             对于部分代理方法，可能存在该类本身是没有进行实现的，此时将新的实现添加到源方法必返回YES
             之后不需要在进行其他操作，在新的实现内部如需执行源方法，需要判断新方法与源方法实现是否一致，一致时则不能执行原方法(否则死循环)
             */
            BOOL didAddMethod = class_addMethod(cls, originSelector, swizzledImpl, method_getTypeEncoding(swizzledMethod));
            if (originImpl) {
                if (didAddMethod) {
                    class_replaceMethod(cls, swizzledSelector, originImpl, method_getTypeEncoding(originMethod));
                }
                else {
                    method_exchangeImplementations(originMethod, swizzledMethod);
                }
            }
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
    
    // 右侧clear按钮情况输入时发送UITextFieldTextDidChangeNotification通知，无其他回调
    // 需要判断文本框展示内容长度与记录的输入内容长度是否一致
    // 长度不一致则表示点击了clear，此时清理输入内容
    if ([self JGSSwizzing_text].length == self.jgsSecurityOriginText.length) {
        return;
    }
    self.text = nil;
}

- (void)JGSSwizzing_setText:(NSString *)text {
    
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]] && self.isSecureTextEntry) {
        self.jgsSecurityOriginText = text;
        for (NSInteger i = 0; i < text.length; i++) {
            text = [text stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:JGSSecurityKeyboardSecChar];
        }
    }
    [self JGSSwizzing_setText:text];
}

- (NSString *)JGSSwizzing_text {
    
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]] && self.isSecureTextEntry) {
        return self.jgsSecurityOriginText;
    }
    return [self JGSSwizzing_text];
}

- (BOOL)JGSSwizzing_canPerformAction:(SEL)action withSender:(id)sender {
    
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]] && self.isSecureTextEntry) {
        if (action == @selector(paste:) || action == @selector(copy:) || action == @selector(cut:)) {
            return NO; // 禁止粘贴、复制、剪切
        }
        else if (action == @selector(select:) || action == @selector(selectAll:)) {
            return NO; // 禁止选择、全选
        }
    }
    return [self JGSSwizzing_canPerformAction:action withSender:sender];
}

- (void)JGSSwizzing_replaceRange:(UITextRange *)range withText:(NSString *)text {
    
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]] && self.isSecureTextEntry) {
        
        // 记录的原字符串更新
        UITextPosition *begin = self.beginningOfDocument;
        UITextPosition *rangeStart = range.start;
        UITextPosition *rangeEnd = range.end;
        
        NSInteger location = [self offsetFromPosition:begin toPosition:rangeStart];
        NSInteger length = [self offsetFromPosition:rangeStart toPosition:rangeEnd];
        
        NSString *origin = self.jgsSecurityOriginText ?: @"";
        origin = [origin stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:text];
        [self setJgsSecurityOriginText:origin];
        
        // 加密
        text = [self secTextWithText:text];
    }
    [self JGSSwizzing_replaceRange:range withText:text];
}

- (NSString *)secTextWithText:(NSString *)text {
    
    for (NSInteger i = 0; i < text.length; i++) {
        text = [text stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:JGSSecurityKeyboardSecChar];
    }
    return text;
}

@end
