//
//  JGSDemoTableData.m
//  JGSourceBaseDemo
//
//  Created by Mei Jigao on 2018/3/16.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "JGSDemoTableData.h"

JGsDemoTableRowData *JGSDemoTableRowMakeSelector(NSString *title, SEL selector) {
    return [[JGsDemoTableRowData alloc] initWithTitle:title selector:selector];
}

JGSDemoTableSectionData *JGSDemoTableSectionMake(NSString *title, NSArray<JGsDemoTableRowData *> *rows) {
    return [[JGSDemoTableSectionData alloc] initWithTitle:title rows:rows];
}

@implementation JGsDemoTableRowData

#pragma mark - init & dealloc
- (instancetype)initWithTitle:(NSString *)title selector:(SEL)selector {
    
    self = [super init];
    if (self) {
        _title = title;
        _selector = selector;
    }
    return self;
}

- (void)dealloc {
    
    JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - End

@end

@implementation JGSDemoTableSectionData

#pragma mark - init & dealloc
- (instancetype)initWithTitle:(NSString *)title rows:(NSArray<JGsDemoTableRowData *> *)rows {
    
    self = [super init];
    if (self) {
        _title = title;
        _rows = rows;
    }
    return self;
}

- (void)dealloc {
    
    JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - End

@end

@implementation JGSDemoTableData

@end
