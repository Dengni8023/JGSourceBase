//
//  NSArray+JGSBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/7/22.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (JGSBase)

// String
- (nullable NSString *)jg_stringAtIndex:(NSUInteger)index;

// Number
- (nullable NSNumber *)jg_numberAtIndex:(NSUInteger)index;

// Short
- (short)jg_shortAtIndex:(NSUInteger)index;
- (short)jg_shortAtIndex:(NSUInteger)index defaultValue:(short)defaultValue;
- (unsigned short)jg_unsignedShortAtIndex:(NSUInteger)index;
- (unsigned short)jg_unsignedShortAtIndex:(NSUInteger)index defaultValue:(unsigned short)defaultValue;

// Int
- (int)jg_intAtIndex:(NSUInteger)index;
- (int)jg_intAtIndex:(NSUInteger)index defaultValue:(int)defaultValue;
- (unsigned int)jg_unsignedIntAtIndex:(NSUInteger)index;
- (unsigned int)jg_unsignedIntAtIndex:(NSUInteger)index defaultValue:(unsigned int)defaultValue;

// Long
- (long)jg_longAtIndex:(NSUInteger)index;
- (long)jg_longAtIndex:(NSUInteger)index defaultValue:(long)defaultValue;
- (unsigned long)jg_unsignedLongAtIndex:(NSUInteger)index;
- (unsigned long)jg_unsignedLongAtIndex:(NSUInteger)index defaultValue:(unsigned long)defaultValue;
- (long long)jg_longLongAtIndex:(NSUInteger)index;
- (long long)jg_longLongAtIndex:(NSUInteger)index defaultValue:(long long)defaultValue;
- (unsigned long long)jg_unsignedLongLongAtIndex:(NSUInteger)index;
- (unsigned long long)jg_unsignedLongLongAtIndex:(NSUInteger)index defaultValue:(unsigned long long)defaultValue;

// Float
- (float)jg_floatAtIndex:(NSUInteger)index;
- (float)jg_floatAtIndex:(NSUInteger)index defaultValue:(float)defaultValue;
- (double)jg_doubleAtIndex:(NSUInteger)index;
- (double)jg_doubleAtIndex:(NSUInteger)index defaultValue:(double)defaultValue;

/// 获取BOOL，如存在非空、非NSNull对象，则返回YES
- (BOOL)jg_boolAtIndex:(NSUInteger)index;
/// 获取BOOL，如存在非空、非NSNull对象，则返回YES
- (BOOL)jg_boolAtIndex:(NSUInteger)index defaultValue:(BOOL)defaultValue;

// CGFloat
- (CGFloat)jg_CGFloatAtIndex:(NSUInteger)index;
- (CGFloat)jg_CGFloatAtIndex:(NSUInteger)index defaultValue:(CGFloat)defaultValue;

// NSInteger
- (NSInteger)jg_integerAtIndex:(NSUInteger)index;
- (NSInteger)jg_integerAtIndex:(NSUInteger)index defaultValue:(NSInteger)defaultValue;
- (NSUInteger)jg_unsignedIntegerAtIndex:(NSUInteger)index;
- (NSUInteger)jg_unsignedIntegerAtIndex:(NSUInteger)index defaultValue:(NSUInteger)defaultValue;

// Object
- (nullable ObjectType)jg_objectAtIndex:(NSUInteger)index;
- (nullable ObjectType)jg_objectAtIndex:(NSUInteger)index withClass:(__unsafe_unretained Class)cls;

// Dict
- (nullable NSDictionary *)jg_dictionaryAtIndex:(NSUInteger)index;

// Array
- (nullable NSArray *)jg_arrayAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
