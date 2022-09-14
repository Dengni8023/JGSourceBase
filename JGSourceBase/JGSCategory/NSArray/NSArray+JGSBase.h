//
//  NSArray+JGSBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/7/22.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (JGSBase)

- (BOOL)jg_boolAtIndex:(NSUInteger)index;
- (BOOL)jg_boolAtIndex:(NSUInteger)index defaultValue:(BOOL)defaultValue;

- (int)jg_intAtIndex:(NSUInteger)index;
- (int)jg_intAtIndex:(NSUInteger)index defaultValue:(int)defaultValue;

- (NSInteger)jg_integerAtIndex:(NSUInteger)index;
- (NSInteger)jg_integerAtIndex:(NSUInteger)index defaultValue:(NSInteger)defaultValue;

- (CGFloat)jg_floatAtIndex:(NSUInteger)index;
- (CGFloat)jg_floatAtIndex:(NSUInteger)index defaultValue:(CGFloat)defaultValue;

- (nullable NSString *)jg_stringAtIndex:(NSUInteger)index;
- (nullable NSString *)jg_stringAtIndex:(NSUInteger)index defaultValue:(nullable NSString *)defaultValue;

- (nullable NSDictionary *)jg_dictionaryAtIndex:(NSUInteger)index;
- (nullable NSDictionary *)jg_dictionaryAtIndex:(NSUInteger)index defaultValue:(nullable NSDictionary *)defaultValue;

- (nullable NSArray *)jg_arrayAtIndex:(NSUInteger)index;
- (nullable NSArray *)jg_arrayAtIndex:(NSUInteger)index defaultValue:(nullable NSArray *)defaultValue;

@end

NS_ASSUME_NONNULL_END
