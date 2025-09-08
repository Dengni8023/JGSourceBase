//
//  NSDictionary+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJiGao. All rights reserved.
//

#import "NSDictionary+JGSBase.h"
#import "NSObject+JGSBase.h"
#import "JGSBase+Private.h"

@implementation NSDictionary (JGSBase)

#pragma mark - Swizzing
+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"__NSPlaceholderDictionary");
        NSArray<NSString *> *originalArray = @[
            NSStringFromSelector(@selector(initWithObjects:forKeys:count:)),
        ];
        
        [originalArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            SEL originalSelector = NSSelectorFromString(obj);
            SEL swizzledSelector = NSSelectorFromString([@"JGSBase_" stringByAppendingString:obj]);
            JGSRuntimeSwizzledMethod(class, originalSelector, swizzledSelector);
        }];
    });
}

- (instancetype)JGSBase_initWithObjects:(id  _Nonnull const[])objects forKeys:(id<NSCopying>  _Nonnull const[])keys count:(NSUInteger)cnt {
    
    NSInteger index = 0;
    id newObjects[cnt];
    id<NSCopying> newKeys[cnt];
    
    for (int i = 0; i < cnt; i++) {
        id object = objects[i];
        id<NSCopying> key = keys[i];
        if (object) {
            newObjects[index] = object;
            newKeys[index] = key;
            index++;
        }
    }
    cnt = index;
    
    return [self JGSBase_initWithObjects:newObjects forKeys:newKeys count:cnt];
}

#pragma mark - String
- (NSString *)jg_stringForKey:(const id)key {
    
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj stringValue];
    }
    return nil;
}

#pragma mark - Number
- (NSNumber *)jg_numberForKey:(const id)key {
    
    id obj = [self objectForKey:key];
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
- (short)jg_shortForKey:(const id)key {
    return [self jg_shortForKey:key defaultValue:0];
}

- (short)jg_shortForKey:(const id)key defaultValue:(short)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key];
    return obj ? obj.shortValue : defaultValue;
}

- (unsigned short)jg_unsignedShortForKey:(const id)key {
    return [self jg_unsignedShortForKey:key defaultValue:0];
}

- (unsigned short)jg_unsignedShortForKey:(const id)key defaultValue:(unsigned short)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key];
    return obj ? obj.unsignedShortValue : defaultValue;
}

#pragma mark - Int
- (int)jg_intForKey:(const id)key {
    return [self jg_intForKey:key defaultValue:0];
}

- (int)jg_intForKey:(const id)key defaultValue:(int)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key];
    return obj ? obj.intValue : defaultValue;
}

- (unsigned int)jg_unsignedIntForKey:(const id)key {
    return [self jg_unsignedIntForKey:key defaultValue:0];
}

- (unsigned int)jg_unsignedIntForKey:(const id)key defaultValue:(unsigned int)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key];
    return obj ? obj.unsignedIntValue : defaultValue;
}

#pragma mark - Long
- (long)jg_longForKey:(const id)key {
    return [self jg_longForKey:key defaultValue:0];
}

- (long)jg_longForKey:(const id)key defaultValue:(long)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key];
    return obj ? obj.longValue : defaultValue;
}

- (unsigned long)jg_unsignedLongForKey:(const id)key {
    return [self jg_unsignedLongForKey:key defaultValue:0];
}

- (unsigned long)jg_unsignedLongForKey:(const id)key defaultValue:(unsigned long)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key];
    return obj ? obj.unsignedLongValue : defaultValue;
}

- (long long)jg_longLongForKey:(const id)key {
    return [self jg_longLongForKey:key defaultValue:0];
}

- (long long)jg_longLongForKey:(const id)key defaultValue:(long long)defaultValue {
    NSNumber *obj = [self jg_numberForKey:key];
    return obj ? obj.longLongValue : defaultValue;
}

- (unsigned long long)jg_unsignedLongLongForKey:(const id)key {
    return [self jg_unsignedLongLongForKey:key defaultValue:0];
}

- (unsigned long long)jg_unsignedLongLongForKey:(const id)key defaultValue:(unsigned long long)defaultValue {
    NSNumber *obj = [self jg_numberForKey:key];
    return obj ? obj.unsignedLongLongValue : defaultValue;
}

#pragma mark - Float
- (float)jg_floatForKey:(const id)key {
    return [self jg_floatForKey:key defaultValue:0];
}

- (float)jg_floatForKey:(const id)key defaultValue:(float)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key];
    return obj ? obj.floatValue : defaultValue;
}

- (double)jg_doubleForKey:(const id)key {
    return [self jg_doubleForKey:key defaultValue:0];
}

- (double)jg_doubleForKey:(const id)key defaultValue:(double)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key];
    return obj ? obj.doubleValue : defaultValue;
}

#pragma mark - BOOL
- (BOOL)jg_boolForKey:(const id)key {
    return [self jg_boolForKey:key defaultValue:NO];
}

- (BOOL)jg_boolForKey:(const id)key defaultValue:(BOOL)defaultValue {
    
    id obj = [self jg_objectForKey:key];
    if (obj == nil) {
        return defaultValue;
    }
    
    if ([obj respondsToSelector:@selector(boolValue)]) {
        return [obj boolValue];
    }
    
    // OC语法非空对象条件判断为 YES
    // 此处直接获取 BOOL，返回 YES
    return YES;
}

#pragma mark - CGFloat
- (CGFloat)jg_CGFloatForKey:(const id)key {
    return [self jg_CGFloatForKey:key defaultValue:0];
}

- (CGFloat)jg_CGFloatForKey:(const id)key defaultValue:(CGFloat)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key];
#if defined(__LP64__) && __LP64__
    return obj ? obj.doubleValue : defaultValue;
#else
    return obj ? obj.floatValue : defaultValue;
#endif
}

#pragma mark - NSInteger
- (NSInteger)jg_integerForKey:(const id)key {
    return [self jg_integerForKey:key defaultValue:0];
}

- (NSInteger)jg_integerForKey:(const id)key defaultValue:(NSInteger)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key];
    return obj ? obj.integerValue : defaultValue;
}

- (NSUInteger)jg_unsignedIntegerForKey:(const id)key {
    return [self jg_unsignedIntegerForKey:key defaultValue:0];
}

- (NSUInteger)jg_unsignedIntegerForKey:(const id)key defaultValue:(NSUInteger)defaultValue {
    
    NSNumber *obj = [self jg_numberForKey:key];
    return obj ? obj.unsignedIntegerValue : defaultValue;
}

#pragma mark - Object
- (id)jg_objectForKey:(const id)key {
    
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return obj;
}

- (id)jg_objectForKey:(const id)key withClass:(__unsafe_unretained Class)cls {
    
    id obj = [self jg_objectForKey:key];
    if ([obj isKindOfClass:cls]) {
        return obj;
    }
    return nil;
}

#pragma mark - Dict
- (NSDictionary *)jg_dictionaryForKey:(const id)key {
    
    id obj = [[self jg_objectForKey:key] jg_JSONObject];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)obj;
    }
    
    return nil;
}

#pragma mark - Array
- (NSArray *)jg_arrayForKey:(const id)key {
    
    id obj = [[self jg_objectForKey:key] jg_JSONObject];
    if ([obj isKindOfClass:[NSArray class]]) {
        return (NSArray *)obj;
    }
    
    return nil;
}

#pragma mark - End

@end

@implementation NSMutableDictionary (JGSBase)

#pragma mark - Swizzing
+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"__NSDictionaryM");
        NSArray<NSString *> *originalArray = @[
            NSStringFromSelector(@selector(setObject:forKey:)),
            NSStringFromSelector(@selector(setObject:forKeyedSubscript:)), // subscripting字面量方法
        ];
        [originalArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            SEL originalSelector = NSSelectorFromString(obj);
            SEL swizzledSelector = NSSelectorFromString([@"JGSBase_" stringByAppendingString:obj]);
            JGSRuntimeSwizzledMethod(class, originalSelector, swizzledSelector);
        }];
    });
}

- (void)JGSBase_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject == nil) {
        [self removeObjectForKey:aKey];
    } else {
        [self JGSBase_setObject:anObject forKey:aKey];
    }
}

- (void)JGSBase_setObject:(id)anObject forKeyedSubscript:(nonnull id<NSCopying>)key {
    [self setObject:anObject forKey:key];
}

#pragma mark - End

@end
