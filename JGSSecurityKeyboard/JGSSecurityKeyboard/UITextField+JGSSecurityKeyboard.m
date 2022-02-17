//
//  UITextField+JGSSecurityKeyboard.m
//  JGSSecurityKeyboard
//
//  Created by 梅继高 on 2022/2/17.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "UITextField+JGSSecurityKeyboard.h"
#import "JGSSecurityKeyboard.h"
#import "JGSBase.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation UITextField (JGSSecurityKeyboard)

static char kJGSSecurityKeyboardTextFieldOriginKey; // 原始内容
static char kJGSSecurityKeyboardAESEncryptInputCharByCharKey; // 是否使用逐字符加密
static char kJGSSecurityKeyboardTextFieldAESIVKey; // AES 逐字符加密 iv
static char kJGSSecurityKeyboardTextFieldAESKeyKey; // AES 逐字符加密 key
static char kJGSSecurityKeyboardIsRandomPadKey; // 非数字键盘随机排序
static char kJGSSecurityKeyboardIsRandomNumPadKey; // 数字键盘随机排序
static char kJGSSecurityKeyboardEnableFullAngleKey; // 否开启全角
static char kJGSSecurityKeyboardEnableHighlightedTapKey; // 是否允许点击高亮

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

#pragma mark - UI展示控制
- (void)setJg_randomPad:(BOOL)jg_randomPad {
    objc_setAssociatedObject(self, &kJGSSecurityKeyboardIsRandomPadKey, @(jg_randomPad), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)jg_randomPad {
    
    NSNumber *setVale = objc_getAssociatedObject(self, &kJGSSecurityKeyboardIsRandomPadKey);
    return setVale ? [setVale boolValue] : NO;
}

- (void)setJg_randomNumPad:(BOOL)jg_randomNumPad {
    objc_setAssociatedObject(self, &kJGSSecurityKeyboardIsRandomNumPadKey, @(jg_randomNumPad), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)jg_randomNumPad {
    
    NSNumber *setVale = objc_getAssociatedObject(self, &kJGSSecurityKeyboardIsRandomNumPadKey);
    return setVale ? [setVale boolValue] : YES;
}

- (void)setJg_enableFullAngle:(BOOL)jg_enableFullAngle {
    objc_setAssociatedObject(self, &kJGSSecurityKeyboardEnableFullAngleKey, @(jg_enableFullAngle), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)jg_enableFullAngle {
    
    NSNumber *setVale = objc_getAssociatedObject(self, &kJGSSecurityKeyboardEnableFullAngleKey);
    return setVale ? [setVale boolValue] : NO;
}

- (void)setJg_enableHighlightedWhenTap:(BOOL)jg_enableHighlightedWhenTap {
    objc_setAssociatedObject(self, &kJGSSecurityKeyboardEnableHighlightedTapKey, @(jg_enableHighlightedWhenTap), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)jg_enableHighlightedWhenTap {
    
    if ([[UIScreen mainScreen] isCaptured]) {
        return NO;
    }
    
    NSNumber *setVale = objc_getAssociatedObject(self, &kJGSSecurityKeyboardEnableHighlightedTapKey);
    return setVale ? [setVale boolValue] : YES;
}

#pragma mark - End

@end
