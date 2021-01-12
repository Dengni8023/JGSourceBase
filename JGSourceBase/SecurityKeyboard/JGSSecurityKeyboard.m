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

@interface JGSSecurityKeyboard ()

@property (nonatomic, assign) BOOL hideToobar;
@property (nonatomic, assign) JGSKeyboardReturnType returnType;
@property (nonatomic, assign) CGRect keyboardFrame;

@property (nonatomic, strong) UIToolbar *keyboardTool;
@property (nonatomic, strong) JGSLetterKeyboard *letterKeyboard;
@property (nonatomic, strong) JGSSymbolKeyboard *symbolKeyboard;
@property (nonatomic, strong) JGSNumberKeyboard *numberKeyboard;
@property (nonatomic, copy) NSArray<JGSBaseKeyboard *> *keyboards;

@property (nonatomic, strong) NSTimer *deleteTimer;

@end

@implementation JGSSecurityKeyboard

#pragma mark - Life Cycle
- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(NSString *)title {
    return [self keyboardWithTextField:textField title:title randomNumPad:YES];
}

+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)enable {
    return [[self alloc] initWithTextField:textField title:title randomNumPad:enable];
}

- (instancetype)initWithTextField:(UITextField *)textField title:(NSString *)title randomNumPad:(BOOL)enable {
    
    self = [super init];
    if (self) {
        
        // 数字键盘随机开关
        JGSKeyboardNumberPadRandomEnable(enable);
        
        _textField = textField;
        _hideToobar = (title.length == 0);
        _title = title.length > 0 ? title : self.textField.placeholder;
        _returnType = (textField.returnKeyType == UIReturnKeyNext ? JGSKeyboardReturnTypeNext : JGSKeyboardReturnTypeDone);
        
        CGFloat keyboardWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat itemWidth = floor((keyboardWidth - JGSKeyboardInteritemSpacing * JGSKeyboardMaxItemsInLine) / JGSKeyboardMaxItemsInLine);
        CGFloat itemHeight = floor(itemWidth / JGSKeyboardKeyWidthHeightRatio);
        CGFloat keyboardHeight = JGSKeyboardKeyLineSpacing + (itemHeight + JGSKeyboardKeyLineSpacing) * JGSKeyboardLinesNumber;
        self.keyboardFrame = CGRectMake(0, 0, keyboardWidth, keyboardHeight);
        if (!self.hideToobar) {
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
    if (!self.hideToobar) {
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
}

- (NSArray<JGSBaseKeyboard *> *)keyboards {
    
    if (!_keyboards) {
        _keyboards = @[self.letterKeyboard, self.symbolKeyboard, self.numberKeyboard];
    }
    return _keyboards;
}

- (UIToolbar *)keyboardTool {
    
    if (!_keyboardTool) {
        
        _keyboardTool = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), JGSKeyboardToolbarHeight)];
        _keyboardTool.barTintColor = JGSKeyboardToolBarColor();
        
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        // 键盘切换
        JGSWeakSelf
        NSMutableArray *toolItems = @[].mutableCopy;
        [self.keyboards enumerateObjectsUsingBlock:^(JGSBaseKeyboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            JGSKeyboardToolbarItem *toolItem = [[JGSKeyboardToolbarItem alloc] initWithTitle:obj.title type:JGSKeyboardToolbarItemTypeSwitch action:^(JGSKeyboardToolbarItem * _Nonnull toolbarItem) {
                JGSStrongSelf
                [self switchKeyboardType:toolbarItem];
            }];
            obj.toolbarItem = toolItem;
            [toolItems addObject:toolItem];
            [toolItems addObject:flexSpace];
        }];
        
        // 标题
        JGSKeyboardToolbarItem *titleItem = [[JGSKeyboardToolbarItem alloc] initWithTitle:self.title type:JGSKeyboardToolbarItemTypeTitle action:nil];
        
        // 完成
        JGSKeyboardToolbarItem *doneItem = [[JGSKeyboardToolbarItem alloc] initWithTitle:@"完成" type:JGSKeyboardToolbarItemTypeDone action:^(JGSKeyboardToolbarItem * _Nonnull toolbarItem) {
            JGSStrongSelf
            [self completeTextInput:toolbarItem];
        }];
        
        [toolItems addObjectsFromArray:@[titleItem, flexSpace, doneItem]];
        _keyboardTool.items = toolItems;
    }
    return _keyboardTool;
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
}

- (void)completeTextInput:(JGSKeyboardToolbarItem *)sender {
    [self.textField resignFirstResponder];
}

@end
