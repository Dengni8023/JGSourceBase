//
//  JGSDemoTableData.h
//  JGSourceBaseDemo
//
//  Created by Mei Jigao on 2018/3/16.
//  Copyright © 2018年 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGSDemoTableRowData : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign, readonly, nullable) id target;
@property (nonatomic, assign, readonly, nullable) SEL selector;

- (instancetype)init NS_UNAVAILABLE;

/// JGSDemo 列表 cell 数据
/// @param title cell 左侧标题，不可为空
/// @param target cell 点击响应方法所属 target，可为空，为空时则默认使用生成数据的当前对象
/// @param selector cell 点击响应方法
- (instancetype)initWithTitle:(NSString *)title target:(nullable id)target selector:(SEL)selector;

@end

@interface JGSDemoTableSectionData : NSObject

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy) NSArray<JGSDemoTableRowData *> *rows;

- (instancetype)init NS_UNAVAILABLE;

/// JGSDemo 列表 section 数据
/// @param title section 标题，可为空
/// @param rows section 所有cell 数据清单
- (instancetype)initWithTitle:(nullable NSString *)title rows:(NSArray<JGSDemoTableRowData *> *)rows;

@end

@interface JGSDemoTableData : NSObject

@end

/// 生成 JGSDemo 列表 cell 数据
/// @param title cell 左侧标题，不可为空
/// @param target cell 点击响应方法所属 target，可为空，为空时则默认使用生成数据的当前对象
/// 形如：- (void)action:(NSIndexPath *)indexPath;
/// @param selector cell 点击响应方法
FOUNDATION_EXTERN JGSDemoTableRowData *JGSDemoTableRowMake(NSString *title, id _Nullable target, SEL _Nullable selector);

/// 生成 JGSDemo 列表 section 数据
/// @param title section 标题，可为空
/// @param rows section 所有cell 数据清单
FOUNDATION_EXTERN JGSDemoTableSectionData *JGSDemoTableSectionMake(NSString * _Nullable title, NSArray<JGSDemoTableRowData *> *rows);

NS_ASSUME_NONNULL_END
