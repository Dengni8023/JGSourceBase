//
//  UITextField+JGSSecurityKeyboard.h
//  JGSSecurityKeyboard
//
//  Created by 梅继高 on 2022/2/17.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (JGSSecurityKeyboard)

/// 是否使用AES逐字符加密，输入内容逐字符进行 AES 加密后存入内存，默认 NO，此时内部对输入整体内容AES加密
/// secureTextEntry 输入时，输入框使用"•"掩码展示，输入框 text 返回一串"•"掩码
/// 需要使用 textField.jg_securityOriginText 获取原始内容
/// 部分安全检测机构要求内存逐字符加密，检测方式：使用frida获取进程内存输出txt文件，搜索密码明文
@property (nonatomic, assign) BOOL jg_aesEncryptInputCharByChar;

/// 对于使用 JGSSecurityKeyboard 安全键盘 secureTextEntry = YES 时，输入框展示一串"•"掩码
/// textField.text = 一串"•"掩码
/// textField.jg_securityOriginText = 原始内容
@property (nullable, nonatomic, copy) NSString *jg_securityOriginText;

/// 对于使用 JGSSecurityKeyboard 安全键盘的输入框，是否开启非数字键盘随机顺序，默认关闭
@property (nonatomic, assign) BOOL jg_randomPad;

/// 对于使用 JGSSecurityKeyboard 安全键盘的输入框，是否开启数字键盘随机顺序，默认开启
@property (nonatomic, assign) BOOL jg_randomNumPad;

/// 对于使用 JGSSecurityKeyboard 安全键盘的输入框，是否开启全角，默认关闭，支持全角时将支持全半角字符输入
@property (nonatomic, assign) BOOL jg_enableFullAngle;

/// 键盘是否允许点击高亮，默认根据系统录屏状态判断，非录屏状态允许点击高亮，录屏状态不允许点击高亮
/// 从安全角度考虑，系统录屏状态强制禁止点击高亮，此时忽略用户设置
/// 非录屏状态下，外部设置优先
@property (nonatomic, assign) BOOL jg_enableHighlightedWhenTap;

// 右侧clear点击清空输入文本，不执行replace操作，需要检查记录的输入文本与文本框文本长度是否一致
- (void)jg_checkClearInputChangeText;

@end

NS_ASSUME_NONNULL_END
