//
//  UITextInput+JGSSecurityKeyboard.h
//  JGSourceBase-d7db3116
//
//  Created by 梅继高 on 2022/2/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JGSSecurityKeyboardTextInput <UITextInput>

@required

/// 对于使用 JGSSecurityKeyboard 安全键盘 secureTextEntry = YES 时，输入框展示一串"•"掩码
/// textInput.text = 一串"•"掩码
/// textInput.jg_securityOriginText = 原始内容
@property (nullable, nonatomic, copy) NSString *jg_securityOriginText;

- (void)jg_keyboardInputText:(nullable NSString *)text;
- (void)jg_keyboardDidInputReturnKey;
- (void)jg_textInputTextDidChange;

/// 当前输入框是否已获取焦点，继承自 UIResponder。
/// UITextField、UITextView 系统内置已实现该方法
@property (nonatomic, readonly) BOOL isFirstResponder;

/// 注销键盘焦点，继承自 UIResponder。
/// UITextField、UITextView 系统内置已实现该方法
- (BOOL)resignFirstResponder;

@end

@interface UITextField (JGSSecurityKeyboard) <JGSSecurityKeyboardTextInput, UITextFieldDelegate>

/// 是否使用AES逐字符加密，输入内容逐字符进行 AES 加密后存入内存，默认 NO，此时内部对输入整体内容AES加密
/// secureTextEntry 输入时，输入框使用"•"掩码展示，输入框 text 返回一串"•"掩码
/// 需要使用 textField.jg_securityOriginText 获取原始内容
/// 部分安全检测机构要求内存逐字符加密，检测方式：使用frida获取进程内存输出txt文件，搜索密码明文
@property (nonatomic, assign) BOOL jg_aesEncryptInputCharByChar DEPRECATED_MSG_ATTRIBUTE("This property is unavailable. Use JGSSecurityKeyboard.aesEncryptInputCharByChar instead!");

@end

@interface UITextView (JGSSecurityKeyboard) <JGSSecurityKeyboardTextInput, UITextViewDelegate>

@end

NS_ASSUME_NONNULL_END
