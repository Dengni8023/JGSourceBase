//
//  JGSDemoTableData.m
//  JGSourceBaseDemo
//
//  Created by Mei Jigao on 2018/3/16.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "JGSDemoTableData.h"

JGsDemoTableRowData *JGSDemoTableRowMakeWithSelector(NSString *title, SEL _Nullable selector) {
    return [[JGsDemoTableRowData alloc] initWithTitle:title selector:selector];
}

JGsDemoTableRowData *JGSDemoTableRowMakeWithObjectSelector(NSString *title, id _Nullable object, SEL _Nullable selector) {
    return [[JGsDemoTableRowData alloc] initWithTitle:title object:object selector:selector];
}

JGSDemoTableSectionData *JGSDemoTableSectionMake(NSString *title, NSArray<JGsDemoTableRowData *> *rows) {
    return [[JGSDemoTableSectionData alloc] initWithTitle:title rows:rows];
}

@implementation JGsDemoTableRowData

#pragma mark - init & dealloc
- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

- (instancetype)initWithTitle:(NSString *)title selector:(SEL)selector {
    
    self = [super init];
    if (self) {
        _title = title;
        _selector = selector;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title object:(nullable id)object selector:(nonnull SEL)selector {
    
    self = [super init];
    if (self) {
        _title = title;
        _object = object;
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

- (instancetype)initWithTitle:(NSString *)title rows:(NSArray<JGsDemoTableRowData *> *)rows {
    
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

@end
