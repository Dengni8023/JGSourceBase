//
//  JGDemoTableData.h
//  JGSourceBaseDemo
//
//  Created by Mei Jigao on 2018/3/16.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGDemoTableRowData : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign, nullable) SEL selector;
@property (nonatomic, copy, nullable) void (^selectBlock)(JGDemoTableRowData *rowData);

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTitle:(NSString *)title selector:(SEL)selector;
- (instancetype)initWithTitle:(NSString *)title selectBlock:(void (^)(JGDemoTableRowData *rowData))block;

@end

@interface JGDemoTableSectionData : NSObject

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, strong) NSArray<JGDemoTableRowData *> *rows;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTitle:(nullable NSString *)title rows:(NSArray<JGDemoTableRowData *> *)rows;

@end

@interface JGDemoTableData : NSObject

@end

FOUNDATION_EXTERN JGDemoTableRowData *JGDemoTableRowMakeSelector(NSString *title, SEL selector);
FOUNDATION_EXTERN JGDemoTableRowData *JGDemoTableRowMakeBlock(NSString *title, void (^selectBlock)(JGDemoTableRowData *rowData));
FOUNDATION_EXTERN JGDemoTableSectionData *JGDemoTableSectionMake(NSString *title, NSArray<JGDemoTableRowData *> *rows);

NS_ASSUME_NONNULL_END
