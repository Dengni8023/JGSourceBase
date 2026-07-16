//
//  UIAlertController+JGSBase.h
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/21.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JGSAlertControllerAction)(UIAlertController * __nonnull alert, NSInteger idx);
@interface UIAlertController (JGSBase)

// MARK: - Alert
/// 显示系统 Alert 弹窗（单个按钮，无点击响应）
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @return 创建的 UIAlertController 实例
+ (instancetype)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;

/// 显示系统 Alert 弹窗（单个按钮，无点击响应）
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @return 创建的 UIAlertController 实例
+ (instancetype)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel;

/// 显示系统 Alert 弹窗（单个按钮，有点击响应）
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
+ (instancetype)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel action:(nullable JGSAlertControllerAction)action;

/// 显示系统 Alert 弹窗（双按钮）
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param other 确定按钮标题，默认 nil（不传则不显示确定按钮）
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，2-其他按钮
/// @return 创建的 UIAlertController 实例
+ (instancetype)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel other:(nullable NSString *)other action:(nullable JGSAlertControllerAction)action;

/// 显示系统 Alert 弹窗（双按钮，红色警告 destructive 按钮）
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param destructive 红色警告按钮标题，默认 nil（不传则不显示警告按钮）
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮
/// @return 创建的 UIAlertController 实例
+ (instancetype)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel destructive:(nullable NSString *)destructive action:(nullable JGSAlertControllerAction)action;

/// 显示系统 Alert 弹窗（多按钮）
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param others 其他按钮标题数组，目前仅支持不多于20个，多余不显示
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
+ (instancetype)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

// MARK: - ActionSheet
/// 显示系统 ActionSheet 弹窗
/// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
/// @param title 弹窗标题，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param others 其他按钮标题数组，目前仅支持不多于20个，多余不显示
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
+ (instancetype)jg_actionSheetWithTitle:(nullable NSString *)title cancel:(nullable NSString *)cancel others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

/// 显示系统 ActionSheet 弹窗
/// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param others 其他按钮标题数组，目前仅支持不多于20个，多余不显示
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
+ (instancetype)jg_actionSheetWithTitle:(nullable NSString *)title message:(nullable NSString *)message others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

/// 显示系统 ActionSheet 弹窗
/// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param others 其他按钮标题数组，目前仅支持不多于20个，多余不显示
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
+ (instancetype)jg_actionSheetWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

// MARK: - Hide
/// 隐藏所有弹出的 Alert 弹窗
/// @param animated 是否执行消失动画
/// @return 是否有需要隐藏的弹窗（true 表示有弹窗被隐藏，false 表示当前没有展示的弹窗）
+ (BOOL)jg_hideAllAlert:(BOOL)animated DEPRECATED_MSG_ATTRIBUTE("Replaced by + [UIAlertController jg_hideAll:]");

/// 隐藏所有弹出的 Alert 弹窗，默认执行动画
/// @return 是否有需要隐藏的弹窗（true 表示有弹窗被隐藏，false 表示当前没有展示的弹窗）
+ (BOOL)jg_hideAll;

/// 隐藏当前弹出的 Alert 弹窗（最近展示的一个）
/// @param animated 是否执行消失动画
/// @return 是否有需要隐藏的弹窗（true 表示有弹窗被隐藏，false 表示当前没有展示的弹窗）
+ (BOOL)jg_hideCurrentAlert:(BOOL)animated DEPRECATED_MSG_ATTRIBUTE("Replaced by + [UIAlertController jg_hideCurrent:]");

/// 隐藏当前弹出的 Alert 弹窗（最近展示的一个），默认执行动画
/// @return 是否有需要隐藏的弹窗（true 表示有弹窗被隐藏，false 表示当前没有展示的弹窗）
+ (BOOL)jg_hideCurrent;

@end

@interface UIView (JGSAlertController)

// MARK: - Alert
/// 显示系统 Alert 弹窗（单个按钮，无点击响应），从当前视图所在的 window 进行展示
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;

/// 显示系统 Alert 弹窗（单个按钮，无点击响应），从当前视图所在的 window 进行展示
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel;

/// 显示系统 Alert 弹窗（单个按钮，有点击响应），从当前视图所在的 window 进行展示
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel action:(nullable JGSAlertControllerAction)action;

/// 显示系统 Alert 弹窗（双按钮，有点击响应），从当前视图所在的 window 进行展示
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param other 确定按钮标题，默认 nil（不传则不显示确定按钮）
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，2-其他按钮
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel other:(nullable NSString *)other action:(nullable JGSAlertControllerAction)action;

/// 显示系统 Alert 弹窗（双按钮，红色警告 destructive 按钮），从当前视图所在的 window 进行展示
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param destructive 红色警告按钮标题，默认 nil（不传则不显示警告按钮）
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel destructive:(nullable NSString *)destructive action:(nullable JGSAlertControllerAction)action;

/// 显示系统 Alert 弹窗（多按钮，有点击响应），从当前视图所在的 window 进行展示
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param others 其他按钮标题数组，目前仅支持不多于20个，多余不显示
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

// MARK: - ActionSheet
/// 显示系统 ActionSheet 弹窗，从当前视图所在的 window 进行展示
/// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
/// @param title 弹窗标题，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param others 其他按钮标题数组，目前仅支持不多于20个，多余不显示
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_actionSheetWithTitle:(nullable NSString *)title cancel:(nullable NSString *)cancel others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

/// 显示系统 ActionSheet 弹窗，从当前视图所在的 window 进行展示
/// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param others 其他按钮标题数组，目前仅支持不多于20个，多余不显示
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_actionSheetWithTitle:(nullable NSString *)title message:(nullable NSString *)message others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

/// 显示系统 ActionSheet 弹窗，从当前视图所在的 window 进行展示
/// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param others 其他按钮标题数组，目前仅支持不多于20个，多余不显示
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_actionSheetWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

// MARK: - Hide
/// 隐藏当前视图所在 window 上展示的所有 Alert 弹窗，默认执行动画
/// @return 是否有需要隐藏的弹窗（true 表示有弹窗被隐藏，false 表示当前没有展示的弹窗）
- (BOOL)jg_hideAllAlert;

/// 隐藏当前视图所在 window 上展示的最后一个 Alert 弹窗，默认执行动画
/// @return 是否有需要隐藏的弹窗（true 表示有弹窗被隐藏，false 表示当前没有展示的弹窗）
- (BOOL)jg_hideCurrentAlert;

@end

@interface UIViewController (JGSAlertController)

// MARK: - Alert
/// 显示系统 Alert 弹窗（单个按钮，无点击响应），从当前控制器视图所在的 window 进行展示
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;

/// 显示系统 Alert 弹窗（单个按钮，无点击响应），从当前控制器视图所在的 window 进行展示
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel;

/// 显示系统 Alert 弹窗（单个按钮，有点击响应），从当前控制器视图所在的 window 进行展示
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel action:(nullable JGSAlertControllerAction)action;

/// 显示系统 Alert 弹窗（双按钮，有点击响应），从当前控制器视图所在的 window 进行展示
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param other 确定按钮标题，默认 nil（不传则不显示确定按钮）
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，2-其他按钮
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel other:(nullable NSString *)other action:(nullable JGSAlertControllerAction)action;

/// 显示系统 Alert 弹窗（双按钮，红色警告 destructive 按钮），从当前控制器视图所在的 window 进行展示
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param destructive 红色警告按钮标题，默认 nil（不传则不显示警告按钮）
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel destructive:(nullable NSString *)destructive action:(nullable JGSAlertControllerAction)action;

/// 显示系统 Alert 弹窗（多按钮，有点击响应），从当前控制器视图所在的 window 进行展示
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param others 其他按钮标题数组，目前仅支持不多于20个，多余不显示
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

// MARK: - ActionSheet
/// 显示系统 ActionSheet 弹窗，从当前控制器视图所在的 window 进行展示
/// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
/// @param title 弹窗标题，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param others 其他按钮标题数组，目前仅支持不多于20个，多余不显示
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_actionSheetWithTitle:(nullable NSString *)title cancel:(nullable NSString *)cancel others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

/// 显示系统 ActionSheet 弹窗，从当前控制器视图所在的 window 进行展示
/// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param others 其他按钮标题数组，目前仅支持不多于20个，多余不显示
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_actionSheetWithTitle:(nullable NSString *)title message:(nullable NSString *)message others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

/// 显示系统 ActionSheet 弹窗，从当前控制器视图所在的 window 进行展示
/// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
/// @param title 弹窗标题，默认 nil
/// @param message 弹窗提示内容，默认 nil
/// @param cancel 取消按钮标题，默认 nil（不传则不显示取消按钮）
/// @param others 其他按钮标题数组，目前仅支持不多于20个，多余不显示
/// @param action 按钮点击回调，idx 参数对应按钮索引：0-取消按钮，1-警告按钮，2及以上-其他按钮
/// @return 创建的 UIAlertController 实例
- (UIAlertController *)jg_actionSheetWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

// MARK: - Hide

/// 隐藏当前控制器视图所在 window 上展示的所有 Alert 弹窗，默认执行动画
/// @return 是否有需要隐藏的弹窗（true 表示有弹窗被隐藏，false 表示当前没有展示的弹窗）
- (BOOL)jg_hideAllAlert;

/// 隐藏当前控制器视图所在 window 上展示的最后一个 Alert 弹窗，默认执行动画
/// @return 是否有需要隐藏的弹窗（true 表示有弹窗被隐藏，false 表示当前没有展示的弹窗）
- (BOOL)jg_hideCurrentAlert;

@end

NS_ASSUME_NONNULL_END
