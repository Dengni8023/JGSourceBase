//
//  UIAlertController+JGSBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2021/9/14.
//  Copyright © 2021 MeiJiGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JGSAlertControllerAction)(UIAlertController * __nonnull alert, NSInteger idx);
@interface UIAlertController (JGSBase)

@property (nonatomic, assign, readonly) NSInteger jg_cancelIdx; // 0
@property (nonatomic, assign, readonly) NSInteger jg_destructiveIdx; // 1
@property (nonatomic, assign, readonly) NSInteger jg_firstOtherIdx; // 2

#pragma mark - Alert
/**
 Alert 单个按钮，无点击响应
 
 @param title 标题，默认nil
 @param message 提示内容，默认nil
 @return instancetype
 */
+ (nullable instancetype)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;

/**
 Alert 单个按钮，无点击响应
 
 @param title 标题，默认nil
 @param message 提示内容
 @param cancel 取消按钮标题
 @return instancetype
 */
+ (nullable instancetype)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel;

/**
 Alert 单个按钮，有点击响应
 
 @param title 标题，默认nil
 @param message 提示内容
 @param cancel 取消按钮标题
 @param action 点击响应block
 @return instancetype
 */
+ (nullable instancetype)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel action:(nullable JGSAlertControllerAction)action;

/**
 * Alert 双按钮
 
 @param title 标题，默认nil
 @param message 提示内容
 @param cancel 取消按钮标题
 @param other 确定按钮标题
 @param action 点击响应block
 @return instancetype
 */
+ (nullable instancetype)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel other:(nullable NSString *)other action:(nullable JGSAlertControllerAction)action;

/**
 * Alert 双按钮，红色警告destructive按钮
 
 @param title 标题，默认nil
 @param message 提示内容
 @param cancel 取消按钮标题
 @param destructive 警告按钮标题
 @param action 点击响应block
 @return instancetype
 */
+ (nullable instancetype)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel destructive:(nullable NSString *)destructive action:(nullable JGSAlertControllerAction)action;

/**
 Alert 多按钮
 
 @param title 标题，默认nil
 @param message 提示内容
 @param cancel 取消按钮标题
 @param others 目前仅支持不多于20个，多余不显示
 @param action 点击响应block
 @return instancetype
 */
+ (nullable instancetype)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

/**
 Alert 多按钮，红色警告destructive按钮
 
 @param title 标题，默认nil
 @param message 提示内容
 @param cancel 取消按钮标题
 @param destructive 警告按钮标题
 @param others 目前仅支持不多于20个，多余不显示
 @param action 点击响应block
 @return instancetype
 */
+ (nullable instancetype)jg_alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel destructive:(nullable NSString *)destructive others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

#pragma mark - ActionSheet
/**
 Actionsheet
 
 @param title 标题，默认nil
 @param cancel 取消按钮标题
 @param others 目前仅支持不多于20个，多余不显示
 @param action 点击响应block
 @return UIActionSheet / UIAlertController
 */
+ (nullable instancetype)jg_actionSheetWithTitle:(nullable NSString *)title cancel:(nullable NSString *)cancel others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;
/**
 Actionsheet
 
 @param title 标题，默认nil
 @param message 提示内容
 @param others 目前仅支持不多于20个，多余不显示
 @param action 点击响应block
 @return UIActionSheet / UIAlertController
 */
+ (nullable instancetype)jg_actionSheetWithTitle:(nullable NSString *)title message:(nullable NSString *)message others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

/**
 Actionsheet
 
 @param title 标题，默认nil
 @param message 提示内容
 @param cancel 取消按钮标题
 @param others 目前仅支持不多于20个，多余不显示
 @param action 点击响应block
 @return UIActionSheet / UIAlertController
 */
+ (nullable instancetype)jg_actionSheetWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

/**
 Actionsheet，红色警告destructive按钮
 
 @param title 标题，默认nil
 @param message 提示内容
 @param cancel 取消按钮标题
 @param destructive 警告按钮标题
 @param others 目前仅支持不多于20个，多余不显示
 @param action 点击响应block
 @return UIActionSheet / UIAlertController
 */
+ (nullable instancetype)jg_actionSheetWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel destructive:(nullable NSString *)destructive others:(nullable NSArray<NSString *> *)others action:(nullable JGSAlertControllerAction)action;

#pragma mark - Alert & ActionSheet
+ (nullable instancetype)jg_showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message style:(UIAlertControllerStyle)style cancel:(nullable NSString *)cancel destructive:(nullable NSString *)destructive others:(nullable NSArray<NSString *> *)others action:(JGSAlertControllerAction)action;

#pragma mark - Hide
/**
 隐藏弹出的Alert
 
 @return 是否需要隐藏
 */
+ (BOOL)jg_hideAllAlert:(BOOL)animated;

/**
 隐藏弹出的当前Alert
 
 @return 是否需要隐藏
 */
+ (BOOL)jg_hideCurrentAlert:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
