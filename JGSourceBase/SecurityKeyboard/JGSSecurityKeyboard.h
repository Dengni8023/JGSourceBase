//
//  JGSSecurityKeyboard.h
//  
//
//  Created by 梅继高 on 2019/5/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGSSecurityKeyboard : UIView

@property (nonatomic, copy, nullable, readonly) NSString *title;
@property (nonatomic, weak, readonly) UITextField *textField; // 输入框

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/**
 自定义安全键盘

 @param textField 键盘对应的输入框
 @param title 键盘顶部toolbar时的标题，传空字符串或nil，则显示textField.placeholder，若title和textField.placeholder均为空或nil，则不显示标题
 @return instancetype
 */
+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title;

/**
 自定义安全键盘
 
 @param textField 键盘对应的输入框
 @param title 键盘顶部toolbar时的标题，传空字符串或nil，则显示textField.placeholder，若title和textField.placeholder均为空，则不显示标题
 @param enable 是否开启数字键盘随机顺序，默认开启
 @return instancetype
 */
+ (instancetype)keyboardWithTextField:(UITextField *)textField title:(nullable NSString *)title randomNumPad:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
