//
//  JGSSecurityKeyboard.h
//  JGSSecurityKeyboard
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#ifndef JGSSecurityKeyboard_h
#define JGSSecurityKeyboard_h

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCryptor.h>
#if __has_include(<JGSourceBase/UITextInput+JGSSecurityKeyboard.h>)
#import <JGSourceBase/UITextInput+JGSSecurityKeyboard.h>
#else
#import "UITextInput+JGSSecurityKeyboard.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 自定义安全软件盘，使用时，建议禁止三方软件盘，避免输入内容不符合软件盘定义的允许输入的内容
/// 在Appdelegate中实现如下方法：
/*
 - (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(UIApplicationExtensionPointIdentifier)extensionPointIdentifier {
     if ([extensionPointIdentifier isEqualToString:@"com.apple.keyboard-service"]) {
         return YES;
     }
     return NO;
 }
 */
@interface JGSSecurityKeyboard : UIView

/// This property is unavailable. Use JGSSecurityKeyboard.textInput instead!
@property (nonatomic, weak, readonly) UITextField *textField NS_UNAVAILABLE;

/// 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
@property (nonatomic, copy, nullable, readonly) NSString *title;

/// 键盘对应的输入框
@property (nonatomic, weak, readonly) id<JGSSecurityKeyboardTextInput> textInput;

/// 是否使用AES逐字符加密，输入内容逐字符进行 AES 加密后存入内存，默认 NO，此时内部对输入整体内容AES加密
/// secureTextEntry 输入时，输入框使用"•"掩码展示，输入框 text 返回一串"•"掩码
/// 需要使用 textField.jg_securityOriginText 获取原始内容
/// 部分安全检测机构要求内存逐字符加密，检测方式：使用frida获取进程内存输出txt文件，搜索密码明文
@property (nonatomic, assign) BOOL aesEncryptInputCharByChar;

/// 对于使用 JGSSecurityKeyboard 安全键盘的输入框，是否开启非数字键盘随机顺序，默认关闭
@property (nonatomic, assign) BOOL randomPad;

/// 对于使用 JGSSecurityKeyboard 安全键盘的输入框，是否开启数字键盘随机顺序，默认开启
@property (nonatomic, assign) BOOL randomNumPad;

/// 对于使用 JGSSecurityKeyboard 安全键盘的输入框，是否开启全角，默认关闭，支持全角时将支持全半角字符输入
@property (nonatomic, assign) BOOL enableFullAngle;

/// 键盘是否允许点击高亮，默认根据系统录屏状态判断，非录屏状态允许点击高亮，录屏状态不允许点击高亮
/// 从安全角度考虑，系统录屏状态强制禁止点击高亮，此时忽略用户设置
/// 非录屏状态下，外部设置优先
@property (nonatomic, assign) BOOL enableHighlightedWhenTap;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/// 自定义安全键盘，默认仅支持字母、符号（数字/符号混合）键盘切换，title为非空字符串时，顶部显示键盘切换快捷toolbar菜单、title、完成按钮，快捷菜单支持切换纯数字键盘，不支持切换身份证键盘
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
///     不显示toolbar时，键盘切换默认仅支持字母、符号键盘（数字、符号混合）切换
///     显示toolbar时，toolbar支持对应键盘快捷切换，支持切换纯数字键盘输入，身份证输入特定键盘不支持从此入口设置
/// @return instancetype
+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title;

/// 自定义安全键盘，默认仅支持字母、符号（数字/符号混合）键盘切换，title为非空字符串时，顶部显示键盘切换快捷toolbar菜单、title、完成按钮，快捷菜单支持切换纯数字键盘，不支持切换身份证键盘
/// @param textInput 键盘对应的输入框，支持UITextField、UITextView及其子类
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
///     不显示toolbar时，键盘切换默认仅支持字母、符号键盘（数字、符号混合）切换
///     显示toolbar时，toolbar支持对应键盘快捷切换，支持切换纯数字键盘输入，身份证输入特定键盘不支持从此入口设置
/// @return instancetype
+ (instancetype)keyboardWithTextInput:(id<JGSSecurityKeyboardTextInput>)textInput title:(nullable NSString *)title;

/// 自定义安全键盘，默认仅支持字母、符号（数字/符号混合）键盘切换，title为非空字符串时，顶部显示键盘切换快捷toolbar菜单、title、完成按钮，快捷菜单支持切换纯数字键盘，不支持切换身份证键盘
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
///     不显示toolbar时，键盘切换默认仅支持字母、符号键盘（数字、符号混合）切换
///     显示toolbar时，toolbar支持对应键盘快捷切换，支持切换纯数字键盘输入，身份证输入特定键盘不支持从此入口设置
/// @param randomNum 是否开启数字键盘随机顺序，默认开启
/// @return instancetype
+ (nullable instancetype)keyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title randomNumPad:(BOOL)randomNum DEPRECATED_MSG_ATTRIBUTE("Use + keyboardWithTextInput:title: and - jg_randomNumPad instead!");

/// 自定义安全键盘，默认仅支持字母、符号（数字/符号混合）键盘切换，title为非空字符串时，顶部显示键盘切换快捷toolbar菜单、title、完成按钮，快捷菜单支持切换纯数字键盘，不支持切换身份证键盘
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
///     不显示toolbar时，键盘切换默认仅支持字母、符号键盘（数字、符号混合）切换
///     显示toolbar时，toolbar支持对应键盘快捷切换，支持切换纯数字键盘输入，身份证输入特定键盘不支持从此入口设置
/// @param randomNum 是否开启数字键盘随机顺序，默认开启
/// @param fullAngle 是否开启全角，默认关闭，支持全角时将支持全半角字符输入
/// @return instancetype
+ (nullable instancetype)keyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title randomNumPad:(BOOL)randomNum enableFullAngle:(BOOL)fullAngle DEPRECATED_MSG_ATTRIBUTE("Use + keyboardWithTextInput:title: and - randomNumPad and - enableFullAngle instead!");

/// 自定义数字键盘，itle为非空字符串时，顶部显示toolbar菜单、title、完成按钮
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
/// @param randomNum 是否开启数字键盘随机顺序，默认开启
/// @return instancetype
+ (nullable instancetype)numberKeyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title randomNumPad:(BOOL)randomNum DEPRECATED_MSG_ATTRIBUTE("Use + numberKeyboardWithTextInput:title: and - randomNumPad instead!");

/// 自定义数字键盘，itle为非空字符串时，顶部显示toolbar菜单、title、完成按钮
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
/// @return instancetype
+ (instancetype)numberKeyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title;

/// 自定义数字键盘，itle为非空字符串时，顶部显示toolbar菜单、title、完成按钮
/// @param textInput 键盘对应的输入框，支持UITextField、UITextView及其子类
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
/// @return instancetype
+ (instancetype)numberKeyboardWithTextInput:(id<JGSSecurityKeyboardTextInput>)textInput title:(nullable NSString *)title;

/// 自定义身份证键盘，itle为非空字符串时，顶部显示toolbar菜单、title、完成按钮
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
/// @param randomNum 是否开启数字键盘随机顺序，默认开启
/// @return instancetype
+ (nullable instancetype)idCardKeyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title randomNumPad:(BOOL)randomNum DEPRECATED_MSG_ATTRIBUTE("Use + idCardKeyboardWithTextInput:title: and - randomNumPad instead!");

/// 自定义身份证键盘，itle为非空字符串时，顶部显示toolbar菜单、title、完成按钮
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
/// @return instancetype
+ (instancetype)idCardKeyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title;

/// 自定义身份证键盘，itle为非空字符串时，顶部显示toolbar菜单、title、完成按钮
/// @param textInput 键盘对应的输入框，支持UITextField、UITextView及其子类
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
/// @return instancetype
+ (instancetype)idCardKeyboardWithTextInput:(id<JGSSecurityKeyboardTextInput>)textInput title:(nullable NSString *)title;

@end

@interface JGSSecurityKeyboard (UITextInput)

/// 输入内容AES 加/解密 存/取
/// - Parameters:
///   - operation: AES加 / 解密
///   - text: 加解密内容
- (nullable NSString *)aesOperation:(CCOperation)operation text:(NSString *)text;

/// 判断当前键盘是否允许输入字符/字符串，内部判断当前文本输入键盘支持的输入字符，字符串存在当前支持的键盘均不允许输入的字符，则不允许输入
/// - Parameter inputText: 输入字符串
- (BOOL)shouldInputText:(NSString *)inputText;

@end

NS_ASSUME_NONNULL_END

#endif /* JGSSecurityKeyboard_h */
