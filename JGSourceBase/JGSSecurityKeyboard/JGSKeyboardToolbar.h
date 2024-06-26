//
//  JGSKeyboardToolbar.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#if __has_include(<JGSourceBase/JGSBaseKeyboard.h>)
#import <JGSourceBase/JGSKeyboardConstants.h>
#else
#import "JGSKeyboardConstants.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface JGSKeyboardToolbarItem : UIBarButtonItem

- (instancetype)initWithTitle:(NSString *)title type:(JGSKeyboardToolbarItemType)type target:(nullable id)target action:(nullable SEL)action;

- (void)setTarget:(nullable id)target action:(nullable SEL)action;

@end

@interface JGSKeyboardTitleToolbarItem : JGSKeyboardToolbarItem

- (instancetype)initWithTitle:(NSString *)title NS_DESIGNATED_INITIALIZER;

@end

@interface JGSKeyboardToolbar: UIToolbar

@property (nonatomic, copy) NSArray<JGSKeyboardToolbarItem *> *leftToolbarItems;
@property (nonatomic, strong) JGSKeyboardToolbarItem *fixedSpaceItem;
@property (nonatomic, strong) JGSKeyboardToolbarItem *flexibleSpaceItem;
@property (nonatomic, strong) JGSKeyboardTitleToolbarItem *titleToolbarItem;
@property (nonatomic, strong) JGSKeyboardToolbarItem *doneToolbarItem;

- (instancetype)initWithTitle:(nullable NSString *)title;

@end

NS_ASSUME_NONNULL_END
