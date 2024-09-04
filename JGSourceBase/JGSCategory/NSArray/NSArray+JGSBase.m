//
//  NSArray+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/7/22.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "NSArray+JGSBase.h"
//#import "NSDictionary+JGSBase.h"
#import "NSObject+JGSBase.h"

@implementation NSArray (JGSBase)

#pragma mark - String
- (NSString *)jg_stringAtIndex:(NSUInteger)index {
    
    id obj = [self jg_objectAtIndex:index];
    if (obj == nil) {
        return nil;
    }
    
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj stringValue];
    } else if ([NSJSONSerialization isValidJSONObject:obj]) {
        return [obj jg_JSONString];
    }
    
    return nil;
}

#pragma mark - Number
- (NSNumber *)jg_numberAtIndex:(NSUInteger)index {
    
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        
        // 小数点后存在多位小数 NSNumberFormatterDecimalStyle 转换失败
        //NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        //[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        //NSNumber *number = [numberFormatter numberFromString:(NSString *)obj];
        //return number ?: defaultValue;
        NSString *numStr = (NSString *)obj;
        NSInteger dotFrom = [numStr rangeOfString:@"."].location;
        NSInteger dotLen = dotFrom != NSNotFound ? numStr.length - dotFrom - 1 : 0;
        
        NSDecimalNumber *decimalNum = [NSDecimalNumber decimalNumberWithString:numStr];
        if ([decimalNum isEqual:[NSDecimalNumber notANumber]]) {
            return nil;
        }
        
        NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:dotLen raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        NSDecimalNumber *number = [decimalNum decimalNumberByRoundingAccordingToBehavior:handler];
        if ([number isEqual:[NSDecimalNumber notANumber]]) {
            return nil;
        }
        
        return number;
    }
    return nil;
}

#pragma mark - Short
- (short)jg_shortAtIndex:(NSUInteger)index {
    return [self jg_shortAtIndex:index defaultValue:0];
}

- (short)jg_shortAtIndex:(NSUInteger)index defaultValue:(short)defaultValue {
    NSNumber *obj = [self jg_numberAtIndex:index];
    return obj ? obj.shortValue : defaultValue;
}

- (unsigned short)jg_unsignedShortAtIndex:(NSUInteger)index {
    return [self jg_unsignedShortAtIndex:index defaultValue:0];
}

- (unsigned short)jg_unsignedShortAtIndex:(NSUInteger)index defaultValue:(unsigned short)defaultValue {
    NSNumber *obj = [self jg_numberAtIndex:index];
    return obj ? obj.unsignedShortValue : defaultValue;
}

#pragma mark - Int
- (int)jg_intAtIndex:(NSUInteger)index {
    return [self jg_intAtIndex:index defaultValue:0];
}

- (int)jg_intAtIndex:(NSUInteger)index defaultValue:(int)defaultValue {
    NSNumber *obj = [self jg_numberAtIndex:index];
    return obj ? obj.intValue : defaultValue;
}

- (unsigned int)jg_unsignedIntAtIndex:(NSUInteger)index {
    return [self jg_unsignedIntAtIndex:index defaultValue:0];
}

- (unsigned int)jg_unsignedIntAtIndex:(NSUInteger)index defaultValue:(unsigned int)defaultValue {
    NSNumber *obj = [self jg_numberAtIndex:index];
    return obj ? obj.unsignedIntValue : defaultValue;
}

#pragma mark - Long
- (long)jg_longAtIndex:(NSUInteger)index {
    return [self jg_longAtIndex:index defaultValue:0];
}

- (long)jg_longAtIndex:(NSUInteger)index defaultValue:(long)defaultValue {
    NSNumber *obj = [self jg_numberAtIndex:index];
    return obj ? obj.longValue : defaultValue;
}

- (unsigned long)jg_unsignedLongAtIndex:(NSUInteger)index {
    return [self jg_unsignedLongAtIndex:index defaultValue:0];
}

- (unsigned long)jg_unsignedLongAtIndex:(NSUInteger)index defaultValue:(unsigned long)defaultValue {
    NSNumber *obj = [self jg_numberAtIndex:index];
    return obj ? obj.unsignedLongValue : defaultValue;
}

- (long long)jg_longLongAtIndex:(NSUInteger)index {
    return [self jg_longLongAtIndex:index defaultValue:0];
}

- (long long)jg_longLongAtIndex:(NSUInteger)index defaultValue:(long long)defaultValue {
    NSNumber *obj = [self jg_numberAtIndex:index];
    return obj ? obj.longLongValue : defaultValue;
}

- (unsigned long long)jg_unsignedLongLongAtIndex:(NSUInteger)index {
    return [self jg_unsignedLongLongAtIndex:index defaultValue:0];
}

- (unsigned long long)jg_unsignedLongLongAtIndex:(NSUInteger)index defaultValue:(unsigned long long)defaultValue {
    NSNumber *obj = [self jg_numberAtIndex:index];
    return obj ? obj.unsignedLongLongValue : defaultValue;
}

#pragma mark - Float
- (float)jg_floatAtIndex:(NSUInteger)index {
    return [self jg_floatAtIndex:index defaultValue:0.f];
}

- (float)jg_floatAtIndex:(NSUInteger)index defaultValue:(float)defaultValue {
    
    NSNumber *obj = [self jg_numberAtIndex:index];
    return obj ? obj.floatValue : defaultValue;
}

- (double)jg_doubleAtIndex:(NSUInteger)index {
    return [self jg_doubleAtIndex:index defaultValue:0];
}

- (double)jg_doubleAtIndex:(NSUInteger)index defaultValue:(double)defaultValue {
    
    NSNumber *obj = [self jg_numberAtIndex:index];
    return obj ? obj.doubleValue : defaultValue;
}

#pragma mark - BOOL
- (BOOL)jg_boolAtIndex:(NSUInteger)index {
    return [self jg_boolAtIndex:index defaultValue:NO];
}

- (BOOL)jg_boolAtIndex:(NSUInteger)index defaultValue:(BOOL)defaultValue {
    
    id obj = [self jg_objectAtIndex:index];
    if (obj == nil) {
        return defaultValue;
    }
    
    if ([obj respondsToSelector:@selector(boolValue)]) {
        return [obj boolValue];
    }
    
    // 与OC语法保持一致，非空对象判断 bool 为 YES
    return YES;
}

#pragma mark - CGFloat
- (CGFloat)jg_CGFloatAtIndex:(NSUInteger)index {
    return [self jg_CGFloatAtIndex:index defaultValue:0.f];
}

- (CGFloat)jg_CGFloatAtIndex:(NSUInteger)index defaultValue:(CGFloat)defaultValue {
    
    NSNumber *obj = [self jg_numberAtIndex:index];
#if defined(__LP64__) && __LP64__
    return obj ? obj.doubleValue : defaultValue;
#else
    return obj ? obj.floatValue : defaultValue;
#endif
}

#pragma mark - NSInteger
- (NSInteger)jg_integerAtIndex:(NSUInteger)index {
    return [self jg_integerAtIndex:index defaultValue:0];
}

- (NSInteger)jg_integerAtIndex:(NSUInteger)index defaultValue:(NSInteger)defaultValue {
    
    NSNumber *obj = [self jg_numberAtIndex:index];
    return obj ? obj.integerValue : defaultValue;
}

- (NSUInteger)jg_unsignedIntegerAtIndex:(NSUInteger)index {
    return [self jg_integerAtIndex:index defaultValue:0];
}

- (NSUInteger)jg_unsignedIntegerAtIndex:(NSUInteger)index defaultValue:(NSUInteger)defaultValue {
    
    NSNumber *obj = [self jg_numberAtIndex:index];
    return obj ? obj.unsignedIntegerValue : defaultValue;
}

#pragma mark - Object
- (id)jg_objectAtIndex:(NSUInteger)index {
    if (index < 0 || index > self.count) {
        return nil;
    }
    
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return obj;
}

- (id)jg_objectAtIndex:(NSUInteger)index withClass:(__unsafe_unretained Class)cls {
    if (index < 0 || index > self.count) {
        return nil;
    }
    
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:[NSNull class]]) {
        return obj;
    }
    return nil;
}

#pragma mark - Dict
- (NSDictionary *)jg_dictionaryAtIndex:(NSUInteger)index {
    
    id obj = [[self jg_objectAtIndex:index] jg_JSONObject];
    if ([obj isKindOfClass:NSDictionary.class]) {
        return (NSDictionary *)obj;
    }
    return nil;
}

#pragma mark - Array
- (NSArray *)jg_arrayAtIndex:(NSUInteger)index {
    
    id obj = [[self jg_objectAtIndex:index] jg_JSONObject];
    if ([obj isKindOfClass:NSArray.class]) {
        return (NSArray *)obj;
    }
    return nil;
}

@end
