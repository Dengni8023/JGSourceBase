//
//  JGSKeyboardToolbar.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/10/7.
//  Copyright © 2021 MeiJigao. All rights reserved.
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

@property (nonatomic, strong, nullable) UIView *titleView;
@property (nonatomic, strong, nullable) UIButton *titleButton;

@end

@implementation JGSKeyboardTitleToolbarItem

- (instancetype)initWithTitle:(NSString *)title {
    
    self = [super initWithTitle:title type:JGSKeyboardToolbarItemTypeTitle target:nil action:nil];
    if (self) {
        
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = [UIColor clearColor];
        
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleButton.backgroundColor = [UIColor clearColor];
        _titleButton.enabled = NO;
        _titleButton.titleLabel.font = JGSKeyboardToolBarTitleFont();
        _titleButton.titleLabel.numberOfLines = 1;
        _titleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleButton setTitleColor:JGSKeyboardToolBarTitleColor() forState:UIControlStateNormal];
        [_titleButton setTitleColor:JGSKeyboardToolBarTitleColor() forState:UIControlStateDisabled];
        [_titleButton setTitle:title forState:UIControlStateNormal];
        [_titleView addSubview:_titleButton];
        
        // 标题居中显示
        if (@available(iOS 11.0, *)) {
            
            CGFloat layoutDefaultLowPriority = UILayoutPriorityDefaultLow-1;
            CGFloat layoutDefaultHighPriority = UILayoutPriorityDefaultHigh-1;

            _titleView.translatesAutoresizingMaskIntoConstraints = NO;
            [_titleView setContentHuggingPriority:layoutDefaultLowPriority forAxis:UILayoutConstraintAxisVertical];
            [_titleView setContentHuggingPriority:layoutDefaultLowPriority forAxis:UILayoutConstraintAxisHorizontal];
            [_titleView setContentCompressionResistancePriority:layoutDefaultHighPriority forAxis:UILayoutConstraintAxisVertical];
            [_titleView setContentCompressionResistancePriority:layoutDefaultHighPriority forAxis:UILayoutConstraintAxisHorizontal];
            
            _titleButton.translatesAutoresizingMaskIntoConstraints = NO;
            [_titleButton setContentHuggingPriority:layoutDefaultLowPriority forAxis:UILayoutConstraintAxisVertical];
            [_titleButton setContentHuggingPriority:layoutDefaultLowPriority forAxis:UILayoutConstraintAxisHorizontal];
            [_titleButton setContentCompressionResistancePriority:layoutDefaultHighPriority forAxis:UILayoutConstraintAxisVertical];
            [_titleButton setContentCompressionResistancePriority:layoutDefaultHighPriority forAxis:UILayoutConstraintAxisHorizontal];

            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
            NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
            NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
            [_titleView addConstraints:@[top, bottom, leading, trailing]];
        }
        else {
            _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _titleButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
        
        self.customView = _titleView;
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

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.title = title;
        self.barTintColor = JGSKeyboardToolBarColor();
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

@end
