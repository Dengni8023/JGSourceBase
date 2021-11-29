//
//  JGSKeyboardToolbar.h
//  JGSourceBase
//
//  Created by 梅继高 on 2021/10/7.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGSKeyboardConstants.h"

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

- (instancetype)initWithFrame:(CGRect)frame title:(nullable NSString *)title;

@end

NS_ASSUME_NONNULL_END
