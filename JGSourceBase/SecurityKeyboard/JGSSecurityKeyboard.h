//
//  JGSSecurityKeyboard.h
//  
//
//  Created by 梅继高 on 2019/5/29.
//

#import <UIKit/UIKit.h>

#ifndef JGS_SecurityKeyboard
#define JGS_SecurityKeyboard
#endif

NS_ASSUME_NONNULL_BEGIN

@interface JGSSecurityKeyboard : UIView

@property (nonatomic, copy, nullable, readonly) NSString *title;
@property (nonatomic, weak, readonly) UITextField *textField; // 输入框
@property (nonatomic, assign) BOOL enableHighlightedWhenTap; // 点击高亮，默认允许点击高亮

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
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
///     不显示toolbar时，键盘切换默认仅支持字母、符号键盘（数字、符号混合）切换
///     显示toolbar时，toolbar支持对应键盘快捷切换，支持切换纯数字键盘输入，身份证输入特定键盘不支持从此入口设置
/// @param randomNum 是否开启数字键盘随机顺序，默认开启
/// @return instancetype
+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title randomNumPad:(BOOL)randomNum;

/// 自定义安全键盘，默认仅支持字母、符号（数字/符号混合）键盘切换，title为非空字符串时，顶部显示键盘切换快捷toolbar菜单、title、完成按钮，快捷菜单支持切换纯数字键盘，不支持切换身份证键盘
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
///     不显示toolbar时，键盘切换默认仅支持字母、符号键盘（数字、符号混合）切换
///     显示toolbar时，toolbar支持对应键盘快捷切换，支持切换纯数字键盘输入，身份证输入特定键盘不支持从此入口设置
/// @param randomNum 是否开启数字键盘随机顺序，默认开启
/// @param fullAngle 是否开启全角，默认关闭，支持全角时将支持全半角字符输入
/// @return instancetype
+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title randomNumPad:(BOOL)randomNum enableFullAngle:(BOOL)fullAngle;

/// 自定义数字键盘，itle为非空字符串时，顶部显示toolbar菜单、title、完成按钮
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
/// @param randomNum 是否开启数字键盘随机顺序，默认开启
/// @return instancetype
+ (instancetype)numberKeyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title randomNumPad:(BOOL)randomNum;

/// 自定义身份证键盘，itle为非空字符串时，顶部显示toolbar菜单、title、完成按钮
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
/// @param randomNum 是否开启数字键盘随机顺序，默认开启
/// @return instancetype
+ (instancetype)idCardKeyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title randomNumPad:(BOOL)randomNum;

@end

@interface UITextField (JGSSecurityKeyboard)

/// 是否使用AES逐字符加密，输入内容逐字符进行 AES 加密后存入内存，默认 NO，此时内部对输入整体内容AES加密
/// secureTextEntry 输入时，输入框使用"•"掩码展示，输入框 text 返回一串"•"掩码
/// 需要使用 textField.jg_securityOriginText 获取原始内容
/// 部分安全检测机构要求内存逐字符加密，检测方式：使用frida获取进程内存输出txt文件，搜索密码明文
@property (nonatomic, assign) BOOL jg_aesEncryptInputCharByChar;

/// 对于使用 JGSSecurityKeyboard 安全键盘 secureTextEntry = YES 时，输入框展示一串"•"掩码
/// textField.text = 一串"•"掩码
/// textField.jg_securityOriginText = 原始内容
@property (nonatomic, copy) NSString *jg_securityOriginText;

@end

NS_ASSUME_NONNULL_END
