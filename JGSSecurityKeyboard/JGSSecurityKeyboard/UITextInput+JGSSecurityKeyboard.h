//
//  UITextInput+JGSSecurityKeyboard.h
//  JGSourceBase-d7db3116
//
//  Created by 梅继高 on 2022/2/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JGSSKTextInput <UITextInput>

/// 对于使用 JGSSecurityKeyboard 安全键盘 secureTextEntry = YES 时，输入框展示一串"•"掩码
/// inputView.text = 一串"•"掩码
/// inputView.jg_securityOriginText = 原始内容
@property (nullable, nonatomic, copy) NSString *jg_securityOriginText;

@end

@interface UITextField (JGSSecurityKeyboard) <JGSSKTextInput>

/// 是否使用AES逐字符加密，输入内容逐字符进行 AES 加密后存入内存，默认 NO，此时内部对输入整体内容AES加密
/// secureTextEntry 输入时，输入框使用"•"掩码展示，输入框 text 返回一串"•"掩码
/// 需要使用 textField.jg_securityOriginText 获取原始内容
/// 部分安全检测机构要求内存逐字符加密，检测方式：使用frida获取进程内存输出txt文件，搜索密码明文
@property (nonatomic, assign) BOOL jg_aesEncryptInputCharByChar DEPRECATED_MSG_ATTRIBUTE("This property is unavailable. Use JGSSecurityKeyboard.aesEncryptInputCharByChar instead!");

// 右侧clear点击清空输入文本，不执行replace操作，需要检查记录的输入文本与文本框文本长度是否一致
- (void)jg_checkClearInputChangeText;

@end

//@interface UITextView (JGSSecurityKeyboard) <JGSSKTextInput>
//
//@end

NS_ASSUME_NONNULL_END
