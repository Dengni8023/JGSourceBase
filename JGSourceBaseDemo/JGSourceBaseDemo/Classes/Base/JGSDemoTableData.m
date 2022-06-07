//
//  JGSDemoTableData.m
//  JGSourceBaseDemo
//
//  Created by Mei Jigao on 2018/3/16.
//  Copyright © 2018年 MeiJiGao. All rights reserved.
//

#import "JGSDemoTableData.h"

JGSDemoTableRowData *JGSDemoTableRowMake(NSString *title, id _Nullable target, SEL _Nullable selector) {
    return [[JGSDemoTableRowData alloc] initWithTitle:title target:target selector:selector];
}

JGSDemoTableSectionData *JGSDemoTableSectionMake(NSString *title, NSArray<JGSDemoTableRowData *> *rows) {
    return [[JGSDemoTableSectionData alloc] initWithTitle:title rows:rows];
}

@implementation JGSDemoTableRowData

#pragma mark - init & dealloc
- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

- (instancetype)initWithTitle:(NSString *)title target:(id)target selector:(SEL)selector {
    
    self = [super init];
    if (self) {
        _title = title;
        _target = target;
        _selector = selector;
    }
    return self;
}

#pragma mark - End

@end

@implementation JGSDemoTableSectionData

#pragma mark - init & dealloc
- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

- (instancetype)initWithTitle:(NSString *)title rows:(NSArray<JGSDemoTableRowData *> *)rows {
    
    self = [super init];
    if (self) {
        _title = title;
        _rows = rows;
    }
    return self;
}

#pragma mark - End

@end

@implementation JGSDemoTableData

- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - End

@end
