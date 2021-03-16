//
//  NSDictionary+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "NSDictionary+JGSBase.h"

@implementation NSDictionary (JGSBase)

#pragma mark - String
- (NSString *)jg_stringForKey:(const id)key {
    return [self jg_stringForKey:key defaultValue:nil];
}

- (NSString *)jg_stringForKey:(const id)key defaultValue:(NSString *)defaultValue {
    
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj stringValue];
    }
    
    return defaultValue;
}

#pragma mark - Number
- (NSNumber *)jg_numberForKey:(const id)key {
    return [self jg_numberForKey:key defaultValue:nil];
}

- (NSNumber *)jg_numberForKey:(const id)key defaultValue:(NSNumber *)defaultValue {
    
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *number = [numberFormatter numberFromString:(NSString *)obj];
        return number ?: defaultValue;
    }
    return defaultValue;
}

#pragma mark - Short
- (short)jg_shortForKey:(const id)key {
    return [self jg_shortForKey:key defaultValue:0];
}

- (short)jg_shortForKey:(const id)key defaultValue:(short)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key defaultValue:@(defaultValue)];
    return obj.shortValue;
}

- (unsigned short)jg_unsignedShortForKey:(const id)key {
    return [self jg_unsignedShortForKey:key defaultValue:0];
}

- (unsigned short)jg_unsignedShortForKey:(const id)key defaultValue:(unsigned short)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key defaultValue:@(defaultValue)];
    return obj.unsignedShortValue;
}

#pragma mark - Int
- (int)jg_intForKey:(const id)key {
    return [self jg_intForKey:key defaultValue:0];
}

- (int)jg_intForKey:(const id)key defaultValue:(int)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key defaultValue:@(defaultValue)];
    return obj.intValue;
}

- (unsigned int)jg_unsignedIntForKey:(const id)key {
    return [self jg_unsignedIntForKey:key defaultValue:0];
}

- (unsigned int)jg_unsignedIntForKey:(const id)key defaultValue:(unsigned int)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key defaultValue:@(defaultValue)];
    return obj.unsignedIntValue;
}

#pragma mark - Long
- (long)jg_longForKey:(const id)key {
    return [self jg_longForKey:key defaultValue:0];
}

- (long)jg_longForKey:(const id)key defaultValue:(long)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key defaultValue:@(defaultValue)];
    return obj.longValue;
}

- (unsigned long)jg_unsignedLongForKey:(const id)key {
    return [self jg_unsignedLongForKey:key defaultValue:0];
}

- (unsigned long)jg_unsignedLongForKey:(const id)key defaultValue:(unsigned long)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key defaultValue:@(defaultValue)];
    return obj.unsignedLongValue;
}

- (long long)jg_longLongForKey:(const id)key {
    return [self jg_longLongForKey:key defaultValue:0];
}

- (long long)jg_longLongForKey:(const id)key defaultValue:(long long)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key defaultValue:@(defaultValue)];
    return obj.longLongValue;
}

- (unsigned long long)jg_unsignedLongLongForKey:(const id)key {
    return [self jg_unsignedLongLongForKey:key defaultValue:0];
}

- (unsigned long long)jg_unsignedLongLongForKey:(const id)key defaultValue:(unsigned long long)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key defaultValue:@(defaultValue)];
    return obj.unsignedLongLongValue;
}

#pragma mark - Float
- (float)jg_floatForKey:(const id)key {
    return [self jg_floatForKey:key defaultValue:0];
}

- (float)jg_floatForKey:(const id)key defaultValue:(float)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key defaultValue:@(defaultValue)];
    return obj.floatValue;
}

- (double)jg_doubleForKey:(const id)key {
    return [self jg_doubleForKey:key defaultValue:0];
}

- (double)jg_doubleForKey:(const id)key defaultValue:(double)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key defaultValue:@(defaultValue)];
    return obj.doubleValue;
}

#pragma mark - BOOL
- (BOOL)jg_boolForKey:(const id)key {
    return [self jg_boolForKey:key defaultValue:NO];
}

- (BOOL)jg_boolForKey:(const id)key defaultValue:(BOOL)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key defaultValue:@(defaultValue)];
    return obj.boolValue;
}

#pragma mark - CGFloat
- (CGFloat)jg_CGFloatForKey:(const id)key {
    return [self jg_CGFloatForKey:key defaultValue:0];
}

- (CGFloat)jg_CGFloatForKey:(const id)key defaultValue:(CGFloat)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key defaultValue:@(defaultValue)];
#if defined(__LP64__) && __LP64__
    return obj.doubleValue;
#else
    return obj.floatValue;
#endif
}

#pragma mark - NSInteger
- (NSInteger)jg_integerForKey:(const id)key {
    return [self jg_integerForKey:key defaultValue:0];
}

- (NSInteger)jg_integerForKey:(const id)key defaultValue:(NSInteger)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key defaultValue:@(defaultValue)];
    return obj.integerValue;
}

- (NSUInteger)jg_unsignedIntegerForKey:(const id)key {
    return [self jg_unsignedIntegerForKey:key defaultValue:0];
}

- (NSUInteger)jg_unsignedIntegerForKey:(const id)key defaultValue:(NSUInteger)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key defaultValue:@(defaultValue)];
    return obj.unsignedIntegerValue;
}

#pragma mark - Object
- (id)jg_objectForKey:(const id)key {
    return [self jg_objectForKey:key defaultValue:nil];
}

- (id)jg_objectForKey:(const id)key defaultValue:(id)defaultValue {
    
    id obj = [self objectForKey:key];
    return obj ?: defaultValue;
}

- (id)jg_objectForKey:(const id)key withClass:(__unsafe_unretained Class)cls {
    return [self jg_objectForKey:key withClass:cls defaultValue:nil];
}

- (id)jg_objectForKey:(const id)key withClass:(__unsafe_unretained Class)cls defaultValue:(id)defaultValue {
    
    id obj = [self jg_objectForKey:key defaultValue:defaultValue];
    if ([obj isKindOfClass:cls]) {
        return obj;
    }
    return defaultValue;
}

#pragma mark - Dict
- (NSDictionary *)jg_dictionaryForKey:(const id)key {
    return [self jg_dictionaryForKey:key defaultValue:nil];
}

- (NSDictionary *)jg_dictionaryForKey:(const id)key defaultValue:(NSDictionary *)defaultValue {
    
    id obj = [self jg_objectForKey:key withClass:[NSDictionary class] defaultValue:defaultValue];
    return obj;
}

#pragma mark - Array
- (NSArray *)jg_arrayForKey:(const id)key {
    return [self jg_arrayForKey:key defaultValue:nil];
}

- (NSArray *)jg_arrayForKey:(const id)key defaultValue:(NSArray *)defaultValue {
    
    id obj = [self jg_objectForKey:key withClass:[NSArray class] defaultValue:defaultValue];
    return obj;
}

#pragma mark - End

@end

@implementation NSMutableDictionary (JGSBase)

#pragma mark - Setter
- (void)jg_setObject:(id)object forKey:(const id)key {
    
    if (object) {
        [(NSMutableDictionary *)self setObject:object forKey:key];
        return;
    }
    
    [(NSMutableDictionary *)self removeObjectForKey:key];
}

@end
