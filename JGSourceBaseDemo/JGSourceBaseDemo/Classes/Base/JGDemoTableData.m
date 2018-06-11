//
//  JGDemoTableData.m
//  JGSourceBaseDemo
//
//  Created by Mei Jigao on 2018/3/16.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "JGDemoTableData.h"
#import <JGSourceBase/JGSourceBase.h>

JGDemoTableRowData *JGDemoTableRowMakeSelector(NSString *title, SEL selector) {
    return [[JGDemoTableRowData alloc] initWithTitle:title selector:selector];
}

JGDemoTableRowData *JGDemoTableRowMakeBlock(NSString *title, void (^selectBlock)(JGDemoTableRowData *rowData)) {
    return [[JGDemoTableRowData alloc] initWithTitle:title selectBlock:selectBlock];
}

JGDemoTableSectionData *JGDemoTableSectionMake(NSString *title, NSArray<JGDemoTableRowData *> *rows) {
    return [[JGDemoTableSectionData alloc] initWithTitle:title rows:rows];
}

@implementation JGDemoTableRowData

#pragma mark - init & dealloc
- (instancetype)initWithTitle:(NSString *)title selector:(SEL)selector {
    
    self = [super init];
    if (self) {
        _title = title;
        _selector = selector;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title selectBlock:(void (^)(JGDemoTableRowData * _Nonnull))block {
    
    self = [super init];
    if (self) {
        _title = title;
        _selectBlock = block;
    }
    return self;
}

- (void)dealloc {
    
    JGSCLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - End

@end

@implementation JGDemoTableSectionData

#pragma mark - init & dealloc
- (instancetype)initWithTitle:(NSString *)title rows:(NSArray<JGDemoTableRowData *> *)rows {
    
    self = [super init];
    if (self) {
        _title = title;
        _rows = rows;
    }
    return self;
}

- (void)dealloc {
    
    JGSCLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - End

@end

@implementation JGDemoTableData

@end
