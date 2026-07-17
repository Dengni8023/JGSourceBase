//
//  JGSDConfig+Defines.m
//  JGSourceBaseDemo
//
//  Created by Mei JiGao on 2026/6/18.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import "JGSDConfig+Defines.h"

@interface JGSDTableCellData ()

/// cell 展示标题
@property (nonatomic, copy) NSString *title;

/// cell 点击的 target-selector 响应
/// - target: 响应接收者
/// - selector: 接收者的具体响应方法，接受一个 NSIndexPath 参数，对应 cell 的 indexPath
@property (nonatomic, assign, nullable) id target;
@property (nonatomic, assign, nullable) SEL selector;

/// cell 点击的 block 响应，接受一个 IndexPath 参数，对应 cell 的 indexPath
@property (nonatomic, copy, nullable) void (^action)(NSIndexPath *indexPath);

@end

@implementation JGSDTableCellData

+ (instancetype)dataWithTitle:(NSString *)title {
    return  [[self alloc] initWithTitle:title];
}

+ (instancetype)dataWithTitle:(NSString *)title target:(id)target selector:(SEL)selector {
    return  [[self alloc] initWithTitle:title target:target selector:selector];
}

+ (instancetype)dataWithTitle:(NSString *)title action:(void (^)(NSIndexPath * _Nonnull))action {
    return  [[self alloc] initWithTitle:title action:action];
}

+ (instancetype)dataWithTitle:(NSString *)title target:(id)target selector:(SEL)selector action:(void (^)(NSIndexPath * _Nonnull))action {
    return  [[self alloc] initWithTitle:title target:target selector:selector action:action];
}

- (instancetype)initWithTitle:(NSString *)title {
    return [self initWithTitle:title target:nil selector:nil action:nil];
}

- (instancetype)initWithTitle:(NSString *)title target:(id)target selector:(SEL)selector {
    return [self initWithTitle:title target:target selector:selector action:nil];
}

- (instancetype)initWithTitle:(NSString *)title action:(void (^)(NSIndexPath * _Nonnull))action {
    return [self initWithTitle:title target:nil selector:nil action:action];
}

- (instancetype)initWithTitle:(NSString *)title target:(id)target selector:(SEL)selector action:(void (^)(NSIndexPath * _Nonnull))action {
    if (self = [super init]) {
        self.title = title;
        self.target = target;
        self.selector = selector;
        self.action = action;
    }
    return self;
}

@end

@interface JGSDTableSectionData ()

/// section 展示标题
@property (nonatomic, copy) NSString *title;

/// section 内 cell 数据
@property (nonatomic, copy) NSArray<JGSDTableCellData *> *rows;

@end

@implementation JGSDTableSectionData

+ (instancetype)sectionWithTitle:(NSString *)title rows:(NSArray<JGSDTableCellData *> *)rows {
    return  [[self alloc] initWithTitle:title rows:rows];
}

- (instancetype)initWithTitle:(NSString *)title rows:(NSArray<JGSDTableCellData *> *)rows {
    if (self = [super init]) {
        
        self.title = title;
        self.rows = rows;
    }
    return self;
}

@end
