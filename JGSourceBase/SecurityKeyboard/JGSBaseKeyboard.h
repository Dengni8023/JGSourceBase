//
//  JGSBaseKeyboard.h
//  
//
//  Created by 梅继高 on 2019/5/31.
//

#import <UIKit/UIKit.h>
#if __has_include(<JGSourceBase/JGSBaseKeyboard.h>)
#import <JGSourceBase/JGSBase.h>
#else
#import "JGSBase.h"
#endif

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarColor(void);
FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarTitleColor(void);
FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarItemTitleColor(void);
FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarItemSelectedTitleColor(void);

FOUNDATION_EXTERN UIColor * const JGSKeyboardBackgroundColor(void);
FOUNDATION_EXTERN UIColor * const JGSKeyboardKeyInputColor(void);
FOUNDATION_EXTERN UIColor * const JGSKeyboardKeyFuncColor(void);
FOUNDATION_EXTERN UIColor * const JGSKeyboardKeyTitleColor(void);
FOUNDATION_EXTERN UIColor * const JGSKeyboardKeyHighlightedTitleColor(void);

FOUNDATION_EXTERN UIFont * const JGSKeyboardToolBarTitleFont(void);
FOUNDATION_EXTERN UIFont * const JGSKeyboardToolBarItemTitleFont(void);
FOUNDATION_EXTERN UIFont * const JGSKeyboardKeyInputTitleFont(void);
FOUNDATION_EXTERN UIFont * const JGSKeyboardKeyFuncTitleFont(void);

FOUNDATION_EXTERN CGFloat const JGSKeyboardHighlightedColorAlpha; // 按钮高亮颜色alpha
FOUNDATION_EXTERN CGFloat const JGSKeyboardToolbarHeight; // 键盘顶部工具条高度
FOUNDATION_EXTERN NSInteger const JGSKeyboardLinesNumber; // 键盘按键行数
FOUNDATION_EXTERN NSInteger const JGSKeyboardMaxItemsInLine; // 键盘单行最多按键
FOUNDATION_EXTERN NSInteger const JGSKeyboardNumberItemsInLine; // 数字键盘单行按键数
FOUNDATION_EXTERN CGFloat const JGSKeyboardInteritemSpacing; // 键盘输入按钮水平间距
FOUNDATION_EXTERN CGFloat const JGSKeyboardKeyLineSpacing; // 键盘输入按钮行间距
FOUNDATION_EXTERN CGFloat const JGSKeyboardKeyWidthHeightRatio; // 键盘按键宽高比

typedef NS_ENUM(NSInteger, JGSKeyboardToolbarItemType) {
    JGSKeyboardToolbarItemTypeSwitch = 0, // 切换输入法
    JGSKeyboardToolbarItemTypeTitle, // 标题
    JGSKeyboardToolbarItemTypeDone, // 完成
};

@interface JGSKeyboardToolbarItem : UIBarButtonItem

@property (nonatomic, strong) UIButton *customView;
@property (nonatomic, copy, readonly) void (^barItemAction)(JGSKeyboardToolbarItem *toolbarItem);

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
//- (instancetype)initWithCustomView:(UIView *)customView NS_UNAVAILABLE;
- (instancetype)initWithImage:(nullable UIImage *)image style:(UIBarButtonItemStyle)style target:(nullable id)target action:(nullable SEL)action NS_UNAVAILABLE;
- (instancetype)initWithImage:(nullable UIImage *)image landscapeImagePhone:(nullable UIImage *)landscapeImagePhone style:(UIBarButtonItemStyle)style target:(nullable id)target action:(nullable SEL)action NS_UNAVAILABLE;
- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(nullable id)target action:(nullable SEL)action NS_UNAVAILABLE;
- (instancetype)initWithTitle:(nullable NSString *)title style:(UIBarButtonItemStyle)style target:(nullable id)target action:(nullable SEL)action NS_UNAVAILABLE;
- (instancetype)initWithTitle:(NSString *)title type:(JGSKeyboardToolbarItemType)type action:(nullable void(^)(JGSKeyboardToolbarItem *toolbarItem))action;

@end

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

@interface JGSKeyboardKey : UILabel

@property (nonatomic, assign, readonly) JGSKeyboardKeyType type;
@property (nonatomic, assign) JGSKeyboardShiftKeyStatus shiftStatus;
@property (nonatomic, copy) void (^action)(JGSKeyboardKey *key, JGSKeyboardKeyEvents event);

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithType:(JGSKeyboardKeyType)type text:(nullable NSString *)text frame:(CGRect)frame;

@end

typedef NS_ENUM(NSInteger, JGSKeyboardType) {
    JGSKeyboardTypeLetter = 0, // 英文字母键盘
    JGSKeyboardTypeSymbol, // 符号键盘
    JGSKeyboardTypeNumber, // 数字键盘
};
FOUNDATION_EXTERN NSString * const JGSKeyboardTitleLetters;
FOUNDATION_EXTERN NSString * const JGSKeyboardTitleSymbolWithNumber;
FOUNDATION_EXTERN NSString * const JGSKeyboardTitleSymbols;
FOUNDATION_EXTERN NSString * const JGSKeyboardTitleNumbers;
FOUNDATION_EXTERN NSString * const JGSKeyboardTitleFullAngle;
FOUNDATION_EXTERN NSString * const JGSKeyboardTitleHalfAngle;
FOUNDATION_EXTERN NSString * const JGSKeyboardTitleForType(JGSKeyboardType type);

typedef NS_ENUM(NSInteger, JGSKeyboardReturnType) {
    JGSKeyboardReturnTypeDone = 0, // 完成
    JGSKeyboardReturnTypeNext, // 下一项
};
FOUNDATION_EXTERN NSString * const JGSKeyboardReturnTitleForType(JGSKeyboardReturnType type);

@interface JGSBaseKeyboard : UIView

@property (nonatomic, assign, readonly) JGSKeyboardType type;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *returnKeyTitle;
@property (nonatomic, copy, readonly) void (^keyInput)(JGSBaseKeyboard *kyboard, JGSKeyboardKey *key, JGSKeyboardKeyEvents keyEvent);
@property (nonatomic, weak) JGSKeyboardToolbarItem *toolbarItem;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame type:(JGSKeyboardType)type returnKeyType:(JGSKeyboardReturnType)returnKeyType keyInput:(void (^)(JGSBaseKeyboard *kyboard, JGSKeyboardKey *key, JGSKeyboardKeyEvents keyEvent))keyInput;

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
