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

- (id)jg_objectAtIndex:(NSUInteger)index {
    if (index < 0 || index > self.count) {
        return nil;
    }
    return [self objectAtIndex:index];
}

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

- (int)jg_intAtIndex:(NSUInteger)index {
    return [self jg_intAtIndex:index defaultValue:0];
}

- (int)jg_intAtIndex:(NSUInteger)index defaultValue:(int)defaultValue {
    
    id obj = [self jg_objectAtIndex:index];
    if (obj == nil) {
        return defaultValue;
    }
    
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj intValue];
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *number = [numberFormatter numberFromString:(NSString *)obj];
        return number ? number.intValue : defaultValue;
    }
    return defaultValue;
}

- (NSInteger)jg_integerAtIndex:(NSUInteger)index {
    return [self jg_integerAtIndex:index defaultValue:0];
}

- (NSInteger)jg_integerAtIndex:(NSUInteger)index defaultValue:(NSInteger)defaultValue {
    
    id obj = [self jg_objectAtIndex:index];
    if (obj == nil) {
        return defaultValue;
    }
    
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj integerValue];
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *number = [numberFormatter numberFromString:(NSString *)obj];
        return number ? number.integerValue : defaultValue;
    }
    return defaultValue;
}

- (CGFloat)jg_floatAtIndex:(NSUInteger)index {
    return [self jg_floatAtIndex:index defaultValue:0.f];
}

- (CGFloat)jg_floatAtIndex:(NSUInteger)index defaultValue:(CGFloat)defaultValue {
    
    id obj = [self jg_objectAtIndex:index];
    if (obj == nil) {
        return defaultValue;
    }
    
    if ([obj isKindOfClass:[NSNumber class]]) {
#if defined(__LP64__) && __LP64__
        return [(NSNumber *)obj doubleValue];
#else
        return [(NSNumber *)obj floatValue];
#endif
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *number = [numberFormatter numberFromString:(NSString *)obj];
#if defined(__LP64__) && __LP64__
        return number ? number.doubleValue : defaultValue;
#else
        return number ? number.floatValue : defaultValue;
#endif
    }
    return defaultValue;
}

- (NSString *)jg_stringAtIndex:(NSUInteger)index {
    return [self jg_stringAtIndex:index defaultValue:nil];
}

- (NSString *)jg_stringAtIndex:(NSUInteger)index defaultValue:(NSString *)defaultValue {
    
    id obj = [self jg_objectAtIndex:index];
    if (obj == nil) {
        return defaultValue;
    }
    
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj stringValue];
    }
    
    return defaultValue;
}

- (NSDictionary *)jg_dictionaryAtIndex:(NSUInteger)index {
    return [self jg_dictionaryAtIndex:index defaultValue:nil];
}

- (NSDictionary *)jg_dictionaryAtIndex:(NSUInteger)index defaultValue:(NSDictionary *)defaultValue {
    
    id obj = [[self jg_objectAtIndex:index] jg_JSONObject];
    if (obj == nil) {
        return defaultValue;
    }
    
    if ([obj isKindOfClass:NSDictionary.class]) {
        return (NSDictionary *)obj;
    }
    
    NSData *data = nil;
    if ([obj isKindOfClass:NSData.class]) {
        data = (NSData *)data;
    } else if ([obj isKindOfClass:NSString.class]) {
        data = [(NSString *)obj dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if (data.length == 0) {
        return defaultValue;
    }
    
    obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if ([obj isKindOfClass:NSDictionary.class]) {
        return (NSDictionary *)obj;
    }
    
    return defaultValue;
}

- (NSArray *)jg_arrayAtIndex:(NSUInteger)index {
    return [self jg_arrayAtIndex:index defaultValue:nil];
}

- (NSArray *)jg_arrayAtIndex:(NSUInteger)index defaultValue:(NSArray *)defaultValue {
    
    id obj = [[self jg_objectAtIndex:index] jg_JSONObject];
    if (obj == nil) {
        return defaultValue;
    }
    
    if ([obj isKindOfClass:NSArray.class]) {
        return (NSArray *)obj;
    }
    
    NSData *data = nil;
    if ([obj isKindOfClass:NSData.class]) {
        data = (NSData *)data;
    } else if ([obj isKindOfClass:NSString.class]) {
        data = [(NSString *)obj dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if (data.length == 0) {
        return defaultValue;
    }
    
    obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if ([obj isKindOfClass:NSArray.class]) {
        return (NSArray *)obj;
    }
    
    return defaultValue;
}

@end
