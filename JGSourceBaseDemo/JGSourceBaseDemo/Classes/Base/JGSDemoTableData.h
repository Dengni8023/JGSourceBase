//
//  JGSDemoTableData.h
//  JGSourceBaseDemo
//
//  Created by Mei Jigao on 2018/3/16.
//  Copyright © 2018年 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGsDemoTableRowData : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign, readonly, nullable) id object;
@property (nonatomic, assign, readonly, nullable) SEL selector;

- (instancetype)init NS_UNAVAILABLE;

/// 列表 Demo 页 cell 展示标题及点击响应
/// @param title cell 展示标题
/// @param selector 点击响应，该 selector 必须在 Demo 页独立实现，即调用方式为 [self selector...]
- (instancetype)initWithTitle:(NSString *)title selector:(SEL)selector;

/// 列表Demo页cell展示标题及点击响应
/// @param title cell展示标题
/// @param selector 点击响应，该 selector 无须在 Demo 页独立实现，调用方式为 [object selector...]
/// object 为 nil 时同 initWithTitle: selector:
- (instancetype)initWithTitle:(NSString *)title object:(nullable id)object selector:(SEL)selector;

@end

@interface JGSDemoTableSectionData : NSObject

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy) NSArray<JGsDemoTableRowData *> *rows;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTitle:(nullable NSString *)title rows:(NSArray<JGsDemoTableRowData *> *)rows;

@end

@interface JGSDemoTableData : NSObject

@end

FOUNDATION_EXTERN JGsDemoTableRowData *JGSDemoTableRowMakeWithSelector(NSString *title, SEL _Nullable selector);
FOUNDATION_EXTERN JGsDemoTableRowData *JGSDemoTableRowMakeWithObjectSelector(NSString *title, id _Nullable object, SEL _Nullable selector);
FOUNDATION_EXTERN JGSDemoTableSectionData *JGSDemoTableSectionMake(NSString * _Nullable title, NSArray<JGsDemoTableRowData *> *rows);

NS_ASSUME_NONNULL_END
