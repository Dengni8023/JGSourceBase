//
//  JGSKeyboardToolbar.m
//  JGSSecurityKeyboard
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSKeyboardToolbar.h"
#import "JGSKeyboardConstants.h"
//#import "JGSourceBase.h"

@implementation JGSKeyboardToolbarItem

- (instancetype)initWithTitle:(NSString *)title type:(JGSKeyboardToolbarItemType)type target:(id)target action:(SEL)action {
    
    self = [super initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
    if (self) {
        
        NSMutableDictionary *normalAttributes = [self titleTextAttributesForState:UIControlStateNormal].mutableCopy ?: @{}.mutableCopy;
        switch (type) {
            case JGSKeyboardToolbarItemTypeSwitch: {
                
                normalAttributes[NSFontAttributeName] = JGSKeyboardToolBarItemTitleFont();
                normalAttributes[NSForegroundColorAttributeName] = JGSKeyboardToolBarItemTitleColor();
            }
                break;
                
            case JGSKeyboardToolbarItemTypeTitle: {
                
                normalAttributes[NSFontAttributeName] = JGSKeyboardToolBarTitleFont();
                normalAttributes[NSForegroundColorAttributeName] = JGSKeyboardToolBarTitleColor();
            }
                break;
                
            case JGSKeyboardToolbarItemTypeDone: {
                
                normalAttributes[NSFontAttributeName] = JGSKeyboardToolBarItemTitleFont();
                normalAttributes[NSForegroundColorAttributeName] = JGSKeyboardToolBarItemSelectedTitleColor();
            }
                break;
                
            default:
                break;
        }
        
        NSMutableDictionary *highlightedAttributes = normalAttributes.mutableCopy;
        UIColor *highlightedColor = [normalAttributes[NSForegroundColorAttributeName] colorWithAlphaComponent:JGSKeyboardHighlightedColorAlpha];
        highlightedAttributes[NSForegroundColorAttributeName] = highlightedColor;
        [self setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
        [self setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    }
    return self;
}

- (void)setTarget:(id)target action:(SEL)action {
    
    self.target = target;
    self.action = action;
}

@end

@interface JGSKeyboardTitleToolbarItem ()

@property (nonatomic, strong, nullable) UILabel *titleLabel;
@property (nonatomic, strong, nullable) UIButton *titleButton;

@end

@implementation JGSKeyboardTitleToolbarItem

- (instancetype)initWithTitle:(NSString *)title {
    
    self = [super initWithTitle:title type:JGSKeyboardToolbarItemTypeTitle target:nil action:nil];
    if (self) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = JGSKeyboardToolBarTitleColor();
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = JGSKeyboardToolBarTitleFont();
        _titleLabel.numberOfLines = 1;
        _titleLabel.text = title;
        
        // 标题居中显示
        if (@available(iOS 11.0, *)) {
            
            CGFloat layoutDefaultLowPriority = UILayoutPriorityDefaultLow - 1;
            CGFloat layoutDefaultHighPriority = UILayoutPriorityDefaultHigh - 1;

            _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [_titleLabel setContentHuggingPriority:layoutDefaultLowPriority forAxis:UILayoutConstraintAxisVertical];
            [_titleLabel setContentHuggingPriority:layoutDefaultLowPriority forAxis:UILayoutConstraintAxisHorizontal];
            [_titleLabel setContentCompressionResistancePriority:layoutDefaultHighPriority forAxis:UILayoutConstraintAxisVertical];
            [_titleLabel setContentCompressionResistancePriority:layoutDefaultHighPriority forAxis:UILayoutConstraintAxisHorizontal];
        }
        else {
            _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
        
        self.customView = _titleLabel;
    }
    return self;
}

@end

@interface JGSKeyboardToolbar ()

@property (nonatomic, copy) NSString *title;

@end

@implementation JGSKeyboardToolbar

#pragma mark - Life Cycle
- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

- (instancetype)initWithTitle:(NSString *)title {
    
    // 初始化传入frame，避免自动布局警告
    self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), JGSKeyboardToolbarHeight)];
    if (self) {
        
        self.title = title;
        self.barTintColor = JGSKeyboardToolBarColor();
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:JGSKeyboardToolbarHeight];
        [self addConstraints:@[height]];
    }
    return self;
}

- (JGSKeyboardToolbarItem *)fixedSpaceItem {
    
    if (_fixedSpaceItem == nil) {
        
        _fixedSpaceItem = [[JGSKeyboardToolbarItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        if (@available(iOS 10.0, *)) {
            _fixedSpaceItem.width = 6;
        } else {
            _fixedSpaceItem.width = 20;
        }
    }
    
    return _fixedSpaceItem;
}

- (JGSKeyboardToolbarItem *)flexibleSpaceItem {
    
    if (_flexibleSpaceItem == nil) {
        _flexibleSpaceItem = [[JGSKeyboardToolbarItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    }
    return _flexibleSpaceItem;
}

- (JGSKeyboardTitleToolbarItem *)titleToolbarItem {
    
    if (_titleToolbarItem == nil) {
        _titleToolbarItem = [[JGSKeyboardTitleToolbarItem alloc] initWithTitle:self.title];
    }
    
    return _titleToolbarItem;
}

- (JGSKeyboardToolbarItem *)doneToolbarItem {
    
    if (_doneToolbarItem == nil) {
        _doneToolbarItem = [[JGSKeyboardToolbarItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:nil];
    }
    
    return _doneToolbarItem;
}

- (void)setLeftToolbarItems:(NSArray<JGSKeyboardToolbarItem *> *)leftToolbarItems {
    _leftToolbarItems = leftToolbarItems;
    
    NSMutableArray<UIBarButtonItem *> *items = @[].mutableCopy;
    [leftToolbarItems enumerateObjectsUsingBlock:^(JGSKeyboardToolbarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 0) {
            [items addObject:self.fixedSpaceItem];
        }
        [items addObject:obj];
    }];
    
    [items addObject:self.flexibleSpaceItem];
    [items addObject:self.titleToolbarItem];
    [items addObject:self.flexibleSpaceItem];
    [items addObject:self.doneToolbarItem];
    
    self.items = items;
}

#pragma mark - End

@end
