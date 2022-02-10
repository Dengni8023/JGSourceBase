//
//  JGSBaseKeyboard.h
//  JGSSecurityKeyboard
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGSKeyboardToolbar.h"

NS_ASSUME_NONNULL_BEGIN

@interface JGSKeyboardKey : UILabel

@property (nonatomic, assign, readonly) JGSKeyboardKeyType type;
@property (nonatomic, assign) BOOL enableHighlighted; // 点击高亮，默认允许点击高亮
@property (nonatomic, assign) JGSKeyboardShiftKeyStatus shiftStatus;
@property (nonatomic, copy) void (^action)(JGSKeyboardKey *key, JGSKeyboardKeyEvents event);

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithType:(JGSKeyboardKeyType)type text:(nullable NSString *)text frame:(CGRect)frame;

@end

@interface JGSBaseKeyboard : UIView

@property (nonatomic, assign, readonly) JGSKeyboardType type;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, assign, setter=enableHighlightedWhenTap:) BOOL enableHighlightedWhenTap; // 点击高亮，默认允许点击高亮
@property (nonatomic, copy, readonly) NSString *returnKeyTitle;
@property (nonatomic, copy, readonly) void (^keyInput)(JGSBaseKeyboard *kyboard, JGSKeyboardKey *key, JGSKeyboardKeyEvents keyEvent);

@property (nonatomic, strong) JGSKeyboardToolbarItem *toolbarItem;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame type:(JGSKeyboardType)type returnKeyType:(JGSKeyboardReturnType)returnKeyType keyInput:(void (^)(JGSBaseKeyboard *kyboard, JGSKeyboardKey *key, JGSKeyboardKeyEvents keyEvent))keyInput;

- (void)enableHighlightedWhenTap:(BOOL)enable NS_REQUIRES_SUPER;

/**
 回调通过调用super在父类中处理
 子类键盘重写，处理不同键盘的内部切换展示逻辑

 @param key 按键
 @param event 按键事件
 @return 是否处理改按键事件，子类根据返回值判断是否进行后续处理
 */
- (BOOL)keyboardKeyAction:(JGSKeyboardKey *)key event:(JGSKeyboardKeyEvents)event NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
