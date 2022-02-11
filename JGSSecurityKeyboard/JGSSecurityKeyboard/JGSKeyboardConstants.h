//
//  JGSKeyboardConstants.h
//  JGSSecurityKeyboard
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 系统键盘截图取色
FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarColor(void);
/// lightGrayColor
FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarTitleColor(void);
/// 系统键盘截图取色
FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarItemTitleColor(void);
/// 系统键盘截图取色
FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarItemSelectedTitleColor(void);
/// 系统键盘截图取色
FOUNDATION_EXTERN UIColor * const JGSKeyboardBackgroundColor(void);
/// 系统键盘截图取色
FOUNDATION_EXTERN UIColor * const JGSKeyboardKeyInputColor(void);
/// 系统键盘截图取色
FOUNDATION_EXTERN UIColor * const JGSKeyboardKeyFuncColor(void);
/// 系统键盘截图取色
FOUNDATION_EXTERN UIColor * const JGSKeyboardKeyTitleColor(void);

FOUNDATION_EXTERN UIFont * const JGSKeyboardToolBarTitleFont(void);
FOUNDATION_EXTERN UIFont * const JGSKeyboardToolBarItemTitleFont(void);

FOUNDATION_EXTERN UIFont * const JGSKeyboardKeyInputTitleFont(void);
FOUNDATION_EXTERN UIFont * const JGSKeyboardKeyFuncTitleFont(void);

FOUNDATION_EXTERN CGFloat const JGSKeyboardHighlightedColorAlpha; // 高亮透明度
FOUNDATION_EXTERN CGFloat const JGSKeyboardToolbarHeight; // 键盘顶部工具条高度
FOUNDATION_EXTERN NSInteger const JGSKeyboardLinesNumber; // 键盘按键行数
FOUNDATION_EXTERN NSInteger const JGSKeyboardMaxItemsInLine; // 键盘单行最多按键
FOUNDATION_EXTERN NSInteger const JGSKeyboardNumberItemsInLine; // 数字键盘单行按键数
//FOUNDATION_EXTERN NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *JGSKeyboardInterItemSpacing(void); // 不同设备、展示方向键盘输入按钮水平间距
//FOUNDATION_EXTERN NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *JGSKeyboardKeyWHRatio(void); // 不同设备、展示方向键盘按键宽高比
//FOUNDATION_EXTERN NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *JGSKeyboardLineSpacing(void); // 不同设备、展示方向键盘输入按钮行间距
FOUNDATION_EXTERN CGFloat const JGSKeyboardKeyInterSpacing(void); // 当前展示状态键盘输入按钮水平间距
FOUNDATION_EXTERN CGFloat const JGSKeyboardKeyLineSpacing(void); // 当前展示状态键盘输入按钮行间距
FOUNDATION_EXTERN CGFloat const JGSKeyboardKeyWidthHeightRatio(void); // 当前展示状态键盘按键宽高比
FOUNDATION_EXTERN NSDictionary *JGSKeyboardSizeInfo(void); // 键盘整体布局

typedef NS_ENUM(NSInteger, JGSKeyboardToolbarItemType) {
    JGSKeyboardToolbarItemTypeSwitch = 0, // 切换输入法
    JGSKeyboardToolbarItemTypeTitle, // 标题
    JGSKeyboardToolbarItemTypeDone, // 完成
};

typedef NS_ENUM(NSInteger, JGSKeyboardKeyType) {
    JGSKeyboardKeyTypeInput = 0, // 输入键
    JGSKeyboardKeyTypeShift, // 大小写切换键
    JGSKeyboardKeyTypeDelete, // 删除键
    JGSKeyboardKeyTypeSwitch2Letter, // 切换英文字母键盘
    JGSKeyboardKeyTypeSwitch2Symbol, // 切换符号键盘
    JGSKeyboardKeyTypeSwitch2Number, // 切换数字键盘
    JGSKeyboardKeyTypeSymbolSwitch2Numbers, // 符号键盘内部切换为带数字键盘
    JGSKeyboardKeyTypeSymbolSwitch2Symbols, // 符号键盘内部切换为全字符键盘
    JGSKeyboardKeyTypeSymbolSwitch2Half, // 符号键盘内部切换半角
    JGSKeyboardKeyTypeSymbolSwitch2Full, // 符号键盘内部切换全角
    JGSKeyboardKeyTypeEnter, // 回车键
};

typedef NS_ENUM(NSInteger, JGSKeyboardKeyEvents) {
    JGSKeyboardKeyEventTapDown = 0,
    JGSKeyboardKeyEventTapEnded,
    JGSKeyboardKeyEventDoubleTap,
    JGSKeyboardKeyEventLongPressBegin,
    JGSKeyboardKeyEventLongPressEnd,
};

typedef NS_ENUM(NSInteger, JGSKeyboardShiftKeyStatus) {
    JGSKeyboardShiftKeyDefault = 0,
    JGSKeyboardShiftKeySelected,
    JGSKeyboardShiftKeyLongSelected,
};

typedef NS_ENUM(NSInteger, JGSKeyboardOptions) {
    JGSKeyboardOptionLetter = 1 << 0, // 英文字母键盘
    JGSKeyboardOptionSymbol = 1 << 1, // 符号键盘
    JGSKeyboardOptionNumber = 1 << 2, // 数字键盘
    JGSKeyboardOptionIDCard = 1 << 3, // 身份证专用输入键盘
};

typedef NS_ENUM(NSInteger, JGSKeyboardType) {
    JGSKeyboardTypeLetter = 0, // 英文字母键盘
    JGSKeyboardTypeSymbol, // 符号键盘
    JGSKeyboardTypeNumber, // 数字键盘
    JGSKeyboardTypeIDCard, // 身份证专用输入键盘
};
FOUNDATION_EXTERN NSString * const JGSKeyboardTitleLetters;
FOUNDATION_EXTERN NSString * const JGSKeyboardTitleSymbolWithNumber;
FOUNDATION_EXTERN NSString * const JGSKeyboardTitleSymbols;
FOUNDATION_EXTERN NSString * const JGSKeyboardTitleNumbers;
FOUNDATION_EXTERN NSString * const JGSKeyboardTitleForType(JGSKeyboardType type);

typedef NS_ENUM(NSInteger, JGSKeyboardReturnType) {
    JGSKeyboardReturnTypeDone = 0, // 完成
    JGSKeyboardReturnTypeNext, // 下一项
};
FOUNDATION_EXTERN NSString * const JGSKeyboardReturnTitleForType(JGSKeyboardReturnType type);

@interface JGSKeyboardConstants : NSObject

@end

NS_ASSUME_NONNULL_END
