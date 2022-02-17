//
//  JGSSecurityKeyboard.h
//  JGSSecurityKeyboard
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for JGSSecurityKeyboard.
FOUNDATION_EXPORT double JGSSecurityKeyboardVersionNumber;

//! Project version string for JGSSecurityKeyboard.
FOUNDATION_EXPORT const unsigned char JGSSecurityKeyboardVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JGSSecurityKeyboard/PublicHeader.h>

#ifndef JGS_SecurityKeyboard
#define JGS_SecurityKeyboard

#if __has_include(<JGSSecurityKeyboard/JGSSecurityKeyboard.h>)
#import <JGSSecurityKeyboard/UITextField+JGSSecurityKeyboard.h>
#else
#import "UITextField+JGSSecurityKeyboard.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface JGSSecurityKeyboard : UIView

@property (nonatomic, copy, nullable, readonly) NSString *title;
@property (nonatomic, weak, readonly) UITextField *textField; // 输入框

/// 点击高亮，从 textfield 设置 jg_enableHighlightedWhenTap
@property (nonatomic, assign) BOOL enableHighlightedWhenTap DEPRECATED_MSG_ATTRIBUTE("This property is unavailable. Use UITextField.jg_enableHighlightedWhenTap instead!");

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
+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title randomNumPad:(BOOL)randomNum DEPRECATED_MSG_ATTRIBUTE("Use keyboardWithTextField:title: and UITextField.jg_randomNumPad instead!");

/// 自定义安全键盘，默认仅支持字母、符号（数字/符号混合）键盘切换，title为非空字符串时，顶部显示键盘切换快捷toolbar菜单、title、完成按钮，快捷菜单支持切换纯数字键盘，不支持切换身份证键盘
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
///     不显示toolbar时，键盘切换默认仅支持字母、符号键盘（数字、符号混合）切换
///     显示toolbar时，toolbar支持对应键盘快捷切换，支持切换纯数字键盘输入，身份证输入特定键盘不支持从此入口设置
/// @param randomNum 是否开启数字键盘随机顺序，默认开启
/// @param fullAngle 是否开启全角，默认关闭，支持全角时将支持全半角字符输入
/// @return instancetype
+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title randomNumPad:(BOOL)randomNum enableFullAngle:(BOOL)fullAngle DEPRECATED_MSG_ATTRIBUTE("Use keyboardWithTextField:title: and UITextField.jg_randomNumPad and UITextField.jg_enableFullAngle instead!");

/// 自定义数字键盘，itle为非空字符串时，顶部显示toolbar菜单、title、完成按钮
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
/// @param randomNum 是否开启数字键盘随机顺序，默认开启
/// @return instancetype
+ (instancetype)numberKeyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title randomNumPad:(BOOL)randomNum DEPRECATED_MSG_ATTRIBUTE("Use numberKeyboardWithTextField:title: and UITextField.jg_randomNumPad instead!");

/// 自定义数字键盘，itle为非空字符串时，顶部显示toolbar菜单、title、完成按钮
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
/// @return instancetype
+ (instancetype)numberKeyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title;

/// 自定义身份证键盘，itle为非空字符串时，顶部显示toolbar菜单、title、完成按钮
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
/// @param randomNum 是否开启数字键盘随机顺序，默认开启
/// @return instancetype
+ (instancetype)idCardKeyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title randomNumPad:(BOOL)randomNum DEPRECATED_MSG_ATTRIBUTE("Use idCardKeyboardWithTextField:title: and UITextField.jg_randomNumPad instead!");

/// 自定义身份证键盘，itle为非空字符串时，顶部显示toolbar菜单、title、完成按钮
/// @param textField 键盘对应的输入框
/// @param title 键盘顶部toolbar显示时的标题，可为空字符串或nil，若title为空或nil，则不显示键盘顶部toolbar
/// @return instancetype
+ (instancetype)idCardKeyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title;

@end

NS_ASSUME_NONNULL_END

#endif
