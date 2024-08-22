//
//  UITextInput+JGSSecurityKeyboard.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/2/20.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "UITextInput+JGSSecurityKeyboard.h"
#import "JGSSecurityKeyboard.h"
#import "JGSBase+JGSPrivate.h"
#import <objc/runtime.h>

static NSString *JGSSecurityKeyboardSecChar = @"•";
static NSString *JGSSecurityKeyboardCRLFChar = @"\n";
static char kJGSSecurityKeyboardTextInputOriginTextKey; // 原始内容
static NSMapTable *JGSSecurityKeyboardTextInputDelegate = nil; // 存储Input对象与其delegate值

@implementation UITextField (JGSSecurityKeyboard)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        // 重写的系统方法处理，dealloc仅用作日志输出检测页面释放情况，dealloc在ARC不能通过@selector获取
        NSArray<NSString *> *oriSelectors = @[
            NSStringFromSelector(@selector(setDelegate:)),
            NSStringFromSelector(@selector(delegate)),
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
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        UITextPosition *begin = self.beginningOfDocument;
        UITextPosition *rangeStart = range.start;
        UITextPosition *rangeEnd = range.end;
        
        NSInteger location = [self offsetFromPosition:begin toPosition:rangeStart];
        NSInteger length = [self offsetFromPosition:rangeStart toPosition:rangeEnd];
        
        NSString *origin = self.jg_securityOriginText ?: @"";
        origin = [origin stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:text];
        self.jg_securityOriginText = origin;
        
        if (self.isSecureTextEntry) {
            // 掩码显示 "•"
            NSString *dotSecStr = @"";
            for (NSInteger i = 0; i < text.length; i++) {
                dotSecStr = [dotSecStr stringByAppendingString:JGSSecurityKeyboardSecChar];
            }
            text = dotSecStr;
        }
    }
    
    [self JGSSwizzing_replaceRange:range withText:text];
}

- (void)JGSSwizzing_setSecureTextEntry:(BOOL)secureTextEntry {
    
    [self JGSSwizzing_setSecureTextEntry:secureTextEntry];
    self.text = self.jg_securityOriginText;
}

#pragma mark - UITextFieldDelegate
- (void)JGSSwizzing_setDelegate:(id<UITextFieldDelegate>)delegate {
    
    [self JGSSwizzing_setDelegate:self];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (JGSSecurityKeyboardTextInputDelegate == nil) {
            JGSSecurityKeyboardTextInputDelegate = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
        }
    });
    
    [JGSSecurityKeyboardTextInputDelegate setObject:delegate forKey:self];
}

- (id<UITextFieldDelegate>)JGSSwizzing_delegate {
    return [self JGSSwizzing_delegate];
}

- (id<UITextFieldDelegate>)jg_textInputDelegate {
    return [JGSSecurityKeyboardTextInputDelegate objectForKey:self];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    id<UITextFieldDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [delegate textFieldShouldBeginEditing:self];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    id<UITextFieldDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        return [delegate textFieldDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    id<UITextFieldDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [delegate textFieldShouldEndEditing:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    id<UITextFieldDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        return [delegate textFieldDidEndEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason {
    
    id<UITextFieldDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:reason:)]) {
        return [delegate textFieldDidEndEditing:self reason:reason];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        
        JGSSecurityKeyboard *keyboard = (JGSSecurityKeyboard *)self.inputView;
        if (![keyboard shouldInputText:string]) {
            //JGSPrivateLog(@"Should not input: %@", string);
            return NO;
        }
    }
    
    BOOL shouldChange = YES;
    id<UITextFieldDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        shouldChange = [delegate textField:self shouldChangeCharactersInRange:range replacementString:string];
    }
    
    if (![self.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        return shouldChange;
    }
    
    // 安全键盘，允许输入之后，阻断系统输入相应
    // 直接文本替换，否则加密文本内容混乱
    UITextPosition *beginPos = [self positionFromPosition:self.beginningOfDocument offset:range.location];
    UITextPosition *endPos = [self positionFromPosition:beginPos offset:range.length];
    UITextRange *selectedRange = [self textRangeFromPosition:beginPos toPosition:endPos];
    
    if (!selectedRange.isEmpty || string.length > 0) {
        [self replaceRange:selectedRange withText:string];
    }
    else {
        UITextPosition *delStart = [self positionFromPosition:selectedRange.start offset:-1];
        UITextRange *delTextRange = [self textRangeFromPosition:delStart toPosition:selectedRange.start];
        [self replaceRange:delTextRange withText:string];
    }
    
    return NO;
}

- (void)textFieldDidChangeSelection:(UITextField *)textField API_AVAILABLE(ios(13.0), tvos(13.0)) {
    
    id<UITextFieldDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textFieldDidChangeSelection:)]) {
        return [delegate textFieldDidChangeSelection:self];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    id<UITextFieldDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [delegate textFieldShouldClear:self];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    id<UITextFieldDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [delegate textFieldShouldReturn:self];
    }
    return YES;
}

#ifdef __IPHONE_16_0
- (UIMenu *)textField:(UITextField *)textField editMenuForCharactersInRange:(NSRange)range suggestedActions:(NSArray<UIMenuElement *> *)suggestedActions API_AVAILABLE(ios(16.0)) {
    
    id<UITextFieldDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textField:editMenuForCharactersInRange:suggestedActions:)]) {
        return [delegate textField:self editMenuForCharactersInRange:range suggestedActions:suggestedActions];
    }
    return nil;
}

- (void)textField:(UITextField *)textField willPresentEditMenuWithAnimator:(id<UIEditMenuInteractionAnimating>)animator API_AVAILABLE(ios(16.0)) {
    
    id<UITextFieldDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textField:willPresentEditMenuWithAnimator:)]) {
        return [delegate textField:self willPresentEditMenuWithAnimator:animator];
    }
}

- (void)textField:(UITextField *)textField willDismissEditMenuWithAnimator:(id<UIEditMenuInteractionAnimating>)animator API_AVAILABLE(ios(16.0)) {
    
    id<UITextFieldDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textField:willDismissEditMenuWithAnimator:)]) {
        return [delegate textField:self willDismissEditMenuWithAnimator:animator];
    }
}
#endif

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
            NSStringFromSelector(@selector(setDelegate:)),
            NSStringFromSelector(@selector(delegate)),
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

#pragma mark - UITextViewDelegate
- (void)JGSSwizzing_setDelegate:(id<UITextViewDelegate>)delegate {
    
    [self JGSSwizzing_setDelegate:delegate ? self : nil];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (JGSSecurityKeyboardTextInputDelegate == nil) {
            JGSSecurityKeyboardTextInputDelegate = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
        }
    });
    
    [JGSSecurityKeyboardTextInputDelegate setObject:delegate forKey:self];
}

- (id<UITextViewDelegate>)JGSSwizzing_delegate {
    return [self JGSSwizzing_delegate];
}

- (id<UITextViewDelegate>)jg_textInputDelegate {
    return [JGSSecurityKeyboardTextInputDelegate objectForKey:self];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
        return [delegate textViewShouldBeginEditing:self];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
        return [delegate textViewShouldEndEditing:self];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
        return [delegate textViewDidBeginEditing:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
        return [delegate textViewDidEndEditing:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([self.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        
        JGSSecurityKeyboard *keyboard = (JGSSecurityKeyboard *)self.inputView;
        if (![keyboard shouldInputText:text]) {
            //JGSPrivateLog(@"Should not input: %@", text);
            return NO;
        }
    }
    
    BOOL shouldChange = YES;
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        shouldChange = [delegate textView:self shouldChangeTextInRange:range replacementText:text];
    }
    
    if (![self.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        return shouldChange;
    }
    
    // 安全键盘，允许输入之后，阻断系统输入相应
    // 直接文本替换，否则加密文本内容混乱
    UITextPosition *beginPos = [self positionFromPosition:self.beginningOfDocument offset:range.location];
    UITextPosition *endPos = [self positionFromPosition:beginPos offset:range.length];
    UITextRange *selectedRange = [self textRangeFromPosition:beginPos toPosition:endPos];
    
    if (!selectedRange.isEmpty || text.length > 0) {
        [self replaceRange:selectedRange withText:text];
    }
    else {
        UITextPosition *delStart = [self positionFromPosition:selectedRange.start offset:-1];
        UITextRange *delTextRange = [self textRangeFromPosition:delStart toPosition:selectedRange.start];
        [self replaceRange:delTextRange withText:text];
    }
    
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textViewDidChange:)]) {
        return [delegate textViewDidChange:self];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        return [delegate textViewDidChangeSelection:self];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    _Pragma("clang diagnostic push")
    _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")
    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)]) {
        return [delegate textView:self shouldInteractWithURL:URL inRange:characterRange];
    }
    _Pragma("clang diagnostic pop")
    
    return YES;
}
#pragma clang diagnostic pop

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:interaction:)]) {
        return [delegate textView:self shouldInteractWithURL:URL inRange:characterRange interaction:interaction];
    }
    else if ([delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)]) {
        JGSSuppressWarning_DeprecatedDeclarations(
                                                  return [delegate textView:self shouldInteractWithURL:URL inRange:characterRange];
                                                  );
    }
    return YES;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    _Pragma("clang diagnostic push")
    _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")
    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)]) {
        return [delegate textView:self shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
    }
    _Pragma("clang diagnostic pop")
    return YES;
}
#pragma clang diagnostic pop
    
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:interaction:)]) {
        return [delegate textView:self shouldInteractWithTextAttachment:textAttachment inRange:characterRange interaction:interaction];
    }
    else if ([delegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)]) {
        JGSSuppressWarning_DeprecatedDeclarations(
                                                  return [delegate textView:self shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
                                                  );
    }
    return YES;
}

#ifdef __IPHONE_16_0
- (UIMenu *)textView:(UITextView *)textView editMenuForTextInRange:(NSRange)range suggestedActions:(NSArray<UIMenuElement *> *)suggestedActions API_AVAILABLE(ios(16.0)) {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textView:editMenuForTextInRange:suggestedActions:)]) {
        return [delegate textView:self editMenuForTextInRange:range suggestedActions:suggestedActions];
    }
    return nil;
}

- (void)textView:(UITextView *)textView willPresentEditMenuWithAnimator:(id<UIEditMenuInteractionAnimating>)animator API_AVAILABLE(ios(16.0)) {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textView:willPresentEditMenuWithAnimator:)]) {
        return [delegate textView:self willPresentEditMenuWithAnimator:animator];
    }
}

- (void)textView:(UITextView *)textView willDismissEditMenuWithAnimator:(id<UIEditMenuInteractionAnimating>)animator API_AVAILABLE(ios(16.0)) {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(textView:willDismissEditMenuWithAnimator:)]) {
        return [delegate textView:self willDismissEditMenuWithAnimator:animator];
    }
}
#endif

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [delegate scrollViewDidScroll:self];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [delegate scrollViewDidZoom:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [delegate scrollViewWillBeginDragging:self];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [delegate scrollViewWillEndDragging:self withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [delegate scrollViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [delegate scrollViewWillBeginDecelerating:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [delegate scrollViewDidEndDecelerating:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [delegate scrollViewDidEndScrollingAnimation:self];
    }
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [delegate viewForZoomingInScrollView:self];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [delegate scrollViewWillBeginZooming:self withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [delegate scrollViewDidEndZooming:self withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [delegate scrollViewShouldScrollToTop:self];
    }
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [delegate scrollViewDidScrollToTop:self];
    }
}

- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView {
    
    id<UITextViewDelegate> delegate = [self jg_textInputDelegate];
    if ([delegate respondsToSelector:@selector(scrollViewDidChangeAdjustedContentInset:)]) {
        [delegate scrollViewDidChangeAdjustedContentInset:self];
    }
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
