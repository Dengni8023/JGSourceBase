//
//  UITextInput+JGSSecurityKeyboard.m
//  JGSourceBase-d7db3116
//
//  Created by 梅继高 on 2022/2/20.
//

#import "UITextInput+JGSSecurityKeyboard.h"
#import "JGSSecurityKeyboard.h"
#import "JGSBase+JGSPrivate.h"
#import <objc/runtime.h>

static NSString *JGSSecurityKeyboardSecChar = @"•";
static NSString *JGSSecurityKeyboardCRLFChar = @"\n";
static char kJGSSecurityKeyboardTextInputOriginTextKey; // 原始内容

@implementation UITextField (JGSSecurityKeyboard)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        // 重写的系统方法处理，dealloc仅用作日志输出检测页面释放情况，dealloc在ARC不能通过@selector获取
        NSArray<NSString *> *oriSelectors = @[
            NSStringFromSelector(@selector(text)),
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

- (void)JGSSwizzing_setText:(NSString *)text {
    
    self.jg_securityOriginText = text;
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]] && self.isSecureTextEntry) {
        // 掩码显示 "•"
        NSString *dotSecStr = @"";
        for (NSInteger i = 0; i < text.length; i++) {
            dotSecStr = [dotSecStr stringByAppendingString:JGSSecurityKeyboardSecChar];
        }
        text = dotSecStr;
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
        
        if (action == @selector(paste:) && self.text.length > 0) {
            // 仅空白状态允许粘贴
            return NO;
        }
        else if (action == @selector(select:) || action == @selector(selectAll:) || action == @selector(copy:) || action == @selector(cut:)) {
            // 禁止选择、全选、复制、剪切
            return NO;
        }
#ifdef __IPHONE_15_0
        // iOS 15提供从相机拍扫文字功能
        else if (action == @selector(captureTextFromCamera:)) {
            // 禁止从相机拍扫文字
            return NO;
        }
#else
        // iOS 15提供从相机拍扫文字功能
        // Xcode 13以下版本使用字符串获取 selector
        else if (action == NSSelectorFromString(@"captureTextFromCamera:")) {
            // 禁止从相机拍扫文字
            return NO;
        }
#endif
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
        // 掩码显示 "•"
        NSString *dotSecStr = @"";
        for (NSInteger i = 0; i < text.length; i++) {
            dotSecStr = [dotSecStr stringByAppendingString:JGSSecurityKeyboardSecChar];
        }
        text = dotSecStr;
    }
    [self JGSSwizzing_replaceRange:range withText:text];
}

- (void)JGSSwizzing_setSecureTextEntry:(BOOL)secureTextEntry {
    
    [self JGSSwizzing_setSecureTextEntry:secureTextEntry];
    self.text = self.jg_securityOriginText;
}

#pragma mark - securityOriginText
- (void)setJg_securityOriginText:(NSString *)jg_securityOriginText {
    
    if (![self.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        return;
    }
    
    JGSSecurityKeyboard *securityKeyboard = (JGSSecurityKeyboard *)self.inputView;
    if (!securityKeyboard.aesEncryptInputCharByChar) {
        NSString *secText = [securityKeyboard aesOperation:kCCEncrypt text:jg_securityOriginText];
        objc_setAssociatedObject(self, &kJGSSecurityKeyboardTextInputOriginTextKey, secText, OBJC_ASSOCIATION_COPY_NONATOMIC);
        return;
    }
    
    NSMutableArray<NSString *> *secText = @[].mutableCopy;
    for (NSInteger i = 0; i < jg_securityOriginText.length; i++) {
        NSString *charText = [jg_securityOriginText substringWithRange:NSMakeRange(i, 1)];
        [secText addObject:[securityKeyboard aesOperation:kCCEncrypt text:charText]];
    }
    objc_setAssociatedObject(self, &kJGSSecurityKeyboardTextInputOriginTextKey, secText.copy, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)jg_securityOriginText {
    
    if (![self.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        return self.text;
    }
    
    JGSSecurityKeyboard *securityKeyboard = (JGSSecurityKeyboard *)self.inputView;
    if (!securityKeyboard.aesEncryptInputCharByChar) {
        
        NSString *secText = objc_getAssociatedObject(self, &kJGSSecurityKeyboardTextInputOriginTextKey);
        return [securityKeyboard aesOperation:kCCDecrypt text:secText];
    }
    
    NSArray<NSString *> *secText = objc_getAssociatedObject(self, &kJGSSecurityKeyboardTextInputOriginTextKey);
    NSMutableString *jg_securityOriginText = @"".mutableCopy;
    for (NSString *obj in secText) {
        [jg_securityOriginText appendString:[securityKeyboard aesOperation:kCCDecrypt text:obj]];
    }
    
    return jg_securityOriginText.copy;
}

#pragma mark - Input
- (void)jg_keyboardInputText:(NSString *)text {
    
    text = text ?: @"";
    if (text.length == 0 && self.text.length == 0) {
        return;
    }
    
    UITextRange *selectedRange = self.selectedTextRange;
    if (!selectedRange) {
        return;
    }
    
    NSRange editRange = NSMakeRange(self.text.length, 0);
    UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
    UITextPosition *beginPos = [self beginningOfDocument];
    editRange.location = [self offsetFromPosition:beginPos toPosition:position];
    editRange.length = [self offsetFromPosition:selectedRange.start toPosition:selectedRange.end];
    
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)] &&
        ![self.delegate textField:self shouldChangeCharactersInRange:editRange replacementString:text]) {
        return;
    }
    
    if (editRange.length > 0 || text.length > 0) {
        [self replaceRange:selectedRange withText:text];
    }
    else {
        UITextPosition *delStart = [self positionFromPosition:selectedRange.start offset:-1];
        UITextRange *delTextRange = [self textRangeFromPosition:delStart toPosition:selectedRange.start];
        [self replaceRange:delTextRange withText:text];
    }
}

- (void)jg_keyboardDidInputReturnKey {
    
    if ([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        [self.delegate textFieldShouldReturn:self];
    }
    else if (self.returnKeyType != UIReturnKeyNext) {
        [self resignFirstResponder];
    }
}

- (void)jg_textInputTextDidChange {
    
    // 点击 clear、paste 输入时未执行 replaceRange:withText: 直接发送 UITextFieldTextDidChangeNotification 通知
    // 因安全键盘输入时禁止选择、全选、复制、剪切，仅空白状态时允许粘贴
    // 此处在长度不一致时需要设置text以更新jg_securityOriginText
    if (self.JGSSwizzing_text.length == self.jg_securityOriginText.length) {
        return;
    }
    self.text = [self JGSSwizzing_text];
}

#pragma mark - AES
- (void)setJg_aesEncryptInputCharByChar:(BOOL)jg_aesEncryptInputCharByChar {
    
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        // 加密
        JGSSecurityKeyboard *inputView = (JGSSecurityKeyboard *)self.inputView;
        inputView.aesEncryptInputCharByChar = jg_aesEncryptInputCharByChar;
    }
}

- (BOOL)jg_aesEncryptInputCharByChar {
    
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        // 加密
        JGSSecurityKeyboard *inputView = (JGSSecurityKeyboard *)self.inputView;
        return inputView.aesEncryptInputCharByChar;
    }
    return NO;
}

#pragma mark - End

@end

@implementation UITextView (JGSSecurityKeyboard)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        // 重写的系统方法处理，dealloc仅用作日志输出检测页面释放情况，dealloc在ARC不能通过@selector获取
        NSArray<NSString *> *oriSelectors = @[
            NSStringFromSelector(@selector(text)),
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

- (void)JGSSwizzing_setText:(NSString *)text {
    
    self.jg_securityOriginText = text;
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]] && self.isSecureTextEntry) {
        // 掩码显示 "•"
        NSString *dotSecStr = @"";
        for (NSInteger i = 0; i < text.length; i++) {
            NSString *idxText = [text substringWithRange:NSMakeRange(i, 1)];
            if ([idxText isEqualToString:JGSSecurityKeyboardCRLFChar]) {
                dotSecStr = [dotSecStr stringByAppendingString:idxText];
            }
            else {
                dotSecStr = [dotSecStr stringByAppendingString:JGSSecurityKeyboardSecChar];
            }
        }
        text = dotSecStr;
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
        
        if (action == @selector(paste:) && self.text.length > 0) {
            // 仅空白状态允许粘贴
            return NO;
        }
        else if (action == @selector(select:) || action == @selector(selectAll:) || action == @selector(copy:) || action == @selector(cut:)) {
            // 禁止选择、全选、复制、剪切
            return NO;
        }
#ifdef __IPHONE_15_0
        // iOS 15提供从相机拍扫文字功能
        else if (action == @selector(captureTextFromCamera:)) {
            // 禁止从相机拍扫文字
            return NO;
        }
#else
        // iOS 15提供从相机拍扫文字功能
        // Xcode 13以下版本使用字符串获取 selector
        else if (action == NSSelectorFromString(@"captureTextFromCamera:")) {
            // 禁止从相机拍扫文字
            return NO;
        }
#endif
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
        // 掩码显示 "•"
        NSString *dotSecStr = @"";
        for (NSInteger i = 0; i < text.length; i++) {
            NSString *idxText = [text substringWithRange:NSMakeRange(i, 1)];
            if ([idxText isEqualToString:JGSSecurityKeyboardCRLFChar]) {
                dotSecStr = [dotSecStr stringByAppendingString:idxText];
            }
            else {
                dotSecStr = [dotSecStr stringByAppendingString:JGSSecurityKeyboardSecChar];
            }
        }
        text = dotSecStr;
    }
    [self JGSSwizzing_replaceRange:range withText:text];
}

- (void)JGSSwizzing_setSecureTextEntry:(BOOL)secureTextEntry {
    
    [self JGSSwizzing_setSecureTextEntry:secureTextEntry];
    self.text = self.jg_securityOriginText;
}

#pragma mark - securityOriginText
- (void)setJg_securityOriginText:(NSString *)jg_securityOriginText {
    
    if (![self.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        return;
    }
    
    JGSSecurityKeyboard *securityKeyboard = (JGSSecurityKeyboard *)self.inputView;
    if (!securityKeyboard.aesEncryptInputCharByChar) {
        NSString *secText = [securityKeyboard aesOperation:kCCEncrypt text:jg_securityOriginText];
        objc_setAssociatedObject(self, &kJGSSecurityKeyboardTextInputOriginTextKey, secText, OBJC_ASSOCIATION_COPY_NONATOMIC);
        return;
    }
    
    NSMutableArray<NSString *> *secText = @[].mutableCopy;
    for (NSInteger i = 0; i < jg_securityOriginText.length; i++) {
        NSString *charText = [jg_securityOriginText substringWithRange:NSMakeRange(i, 1)];
        [secText addObject:[securityKeyboard aesOperation:kCCEncrypt text:charText]];
    }
    objc_setAssociatedObject(self, &kJGSSecurityKeyboardTextInputOriginTextKey, secText.copy, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)jg_securityOriginText {
    
    if (![self.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        return self.text;
    }
    
    JGSSecurityKeyboard *securityKeyboard = (JGSSecurityKeyboard *)self.inputView;
    if (!securityKeyboard.aesEncryptInputCharByChar) {
        
        NSString *secText = objc_getAssociatedObject(self, &kJGSSecurityKeyboardTextInputOriginTextKey);
        return [securityKeyboard aesOperation:kCCDecrypt text:secText];
    }
    
    NSArray<NSString *> *secText = objc_getAssociatedObject(self, &kJGSSecurityKeyboardTextInputOriginTextKey);
    NSMutableString *jg_securityOriginText = @"".mutableCopy;
    for (NSString *obj in secText) {
        [jg_securityOriginText appendString:[securityKeyboard aesOperation:kCCDecrypt text:obj]];
    }
    
    return jg_securityOriginText.copy;
}

#pragma mark - Input
- (void)jg_keyboardInputText:(NSString *)text {
    
    text = text ?: @"";
    if (text.length == 0 && self.text.length == 0) {
        return;
    }
    
    UITextRange *selectedRange = self.selectedTextRange;
    if (!selectedRange) {
        return;
    }
    
    NSRange editRange = NSMakeRange(self.text.length, 0);
    UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
    UITextPosition *beginPos = [self beginningOfDocument];
    editRange.location = [self offsetFromPosition:beginPos toPosition:position];
    editRange.length = [self offsetFromPosition:selectedRange.start toPosition:selectedRange.end];
    
    if ([self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)] &&
        ![self.delegate textView:self shouldChangeTextInRange:editRange replacementText:text]) {
        return;
    }
    
    if (editRange.length > 0 || text.length > 0) {
        [self replaceRange:selectedRange withText:text];
    }
    else {
        UITextPosition *delStart = [self positionFromPosition:selectedRange.start offset:-1];
        UITextRange *delTextRange = [self textRangeFromPosition:delStart toPosition:selectedRange.start];
        [self replaceRange:delTextRange withText:text];
    }
}

- (void)jg_keyboardDidInputReturnKey {
    
    [self jg_keyboardInputText:JGSSecurityKeyboardCRLFChar];
}

- (void)jg_textInputTextDidChange {
    
    // 点击 paste 输入时未执行 replaceRange:withText: 直接发送 UITextViewTextDidChangeNotification 通知
    // 因安全键盘输入时禁止选择、全选、复制、剪切，仅空白状态时允许粘贴
    // 此处在长度不一致时需要设置text以更新jg_securityOriginText
    if (self.JGSSwizzing_text.length == self.jg_securityOriginText.length) {
        return;
    }
    self.text = [self JGSSwizzing_text];
}

#pragma mark - End

@end
