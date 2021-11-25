//
//  JGSDemoTableData.h
//  JGSourceBaseDemo
//
//  Created by Mei Jigao on 2018/3/16.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGsDemoTableRowData : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign, nullable) SEL selector;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTitle:(NSString *)title selector:(SEL)selector;

@end

@interface JGSDemoTableSectionData : NSObject

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy) NSArray<JGsDemoTableRowData *> *rows;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTitle:(nullable NSString *)title rows:(NSArray<JGsDemoTableRowData *> *)rows;

@end

@interface JGSDemoTableData : NSObject

@end

FOUNDATION_EXTERN JGsDemoTableRowData *JGSDemoTableRowMakeSelector(NSString *title, SEL selector);
FOUNDATION_EXTERN JGSDemoTableSectionData *JGSDemoTableSectionMake(NSString * _Nullable title, NSArray<JGsDemoTableRowData *> *rows);

NS_ASSUME_NONNULL_END
