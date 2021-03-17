//
//  NSDictionary+JGSBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<KeyType, ObjectType> (JGSBase)

// String
- (nullable NSString *)jg_stringForKey:(const KeyType)key;
- (nullable NSString *)jg_stringForKey:(const KeyType)key defaultValue:(nullable NSString *)defaultValue;

// Number
- (nullable NSNumber *)jg_numberForKey:(const KeyType)key;
- (nullable NSNumber *)jg_numberForKey:(const KeyType)key defaultValue:(nullable NSNumber *)defaultValue;

// Short
- (short)jg_shortForKey:(const KeyType)key;
- (short)jg_shortForKey:(const KeyType)key defaultValue:(short)defaultValue;
- (unsigned short)jg_unsignedShortForKey:(const KeyType)key;
- (unsigned short)jg_unsignedShortForKey:(const KeyType)key defaultValue:(unsigned short)defaultValue;

// Int
- (int)jg_intForKey:(const KeyType)key;
- (int)jg_intForKey:(const KeyType)key defaultValue:(int)defaultValue;
- (unsigned int)jg_unsignedIntForKey:(const KeyType)key;
- (unsigned int)jg_unsignedIntForKey:(const KeyType)key defaultValue:(unsigned int)defaultValue;

// Long
- (long)jg_longForKey:(const KeyType)key;
- (long)jg_longForKey:(const KeyType)key defaultValue:(long)defaultValue;
- (unsigned long)jg_unsignedLongForKey:(const KeyType)key;
- (unsigned long)jg_unsignedLongForKey:(const KeyType)key defaultValue:(unsigned long)defaultValue;
- (long long)jg_longLongForKey:(const KeyType)key;
- (long long)jg_longLongForKey:(const KeyType)key defaultValue:(long long)defaultValue;
- (unsigned long long)jg_unsignedLongLongForKey:(const KeyType)key;
- (unsigned long long)jg_unsignedLongLongForKey:(const KeyType)key defaultValue:(unsigned long long)defaultValue;

// Float
- (float)jg_floatForKey:(const KeyType)key;
- (float)jg_floatForKey:(const KeyType)key defaultValue:(float)defaultValue;
- (double)jg_doubleForKey:(const KeyType)key;
- (double)jg_doubleForKey:(const KeyType)key defaultValue:(double)defaultValue;

// BOOL
- (BOOL)jg_boolForKey:(const KeyType)key;
- (BOOL)jg_boolForKey:(const KeyType)key defaultValue:(BOOL)defaultValue;

// CGFloat
- (CGFloat)jg_CGFloatForKey:(const KeyType)key;
- (CGFloat)jg_CGFloatForKey:(const KeyType)key defaultValue:(CGFloat)defaultValue;

// NSInteger
- (NSInteger)jg_integerForKey:(const KeyType)key;
- (NSInteger)jg_integerForKey:(const KeyType)key defaultValue:(NSInteger)defaultValue;
- (NSUInteger)jg_unsignedIntegerForKey:(const KeyType)key;
- (NSUInteger)jg_unsignedIntegerForKey:(const KeyType)key defaultValue:(NSUInteger)defaultValue;

// Object
- (nullable ObjectType)jg_objectForKey:(const KeyType)key;
- (nullable ObjectType)jg_objectForKey:(const KeyType)key defaultValue:(nullable ObjectType)defaultValue;
- (nullable ObjectType)jg_objectForKey:(const KeyType)key withClass:(__unsafe_unretained Class)cls;
- (nullable ObjectType)jg_objectForKey:(const KeyType)key withClass:(__unsafe_unretained Class)cls defaultValue:(nullable ObjectType)defaultValue;

// Dict
- (nullable NSDictionary *)jg_dictionaryForKey:(const KeyType)key;
- (nullable NSDictionary *)jg_dictionaryForKey:(const KeyType)key defaultValue:(nullable NSDictionary *)defaultValue;

// Array
- (nullable NSArray *)jg_arrayForKey:(const KeyType)key;
- (nullable NSArray *)jg_arrayForKey:(const KeyType)key defaultValue:(nullable NSArray *)defaultValue;

@end

NS_ASSUME_NONNULL_END
