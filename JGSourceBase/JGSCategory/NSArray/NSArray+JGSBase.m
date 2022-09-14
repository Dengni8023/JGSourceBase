//
//  NSArray+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/7/22.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "NSArray+JGSBase.h"
#import "NSDictionary+JGSBase.h"
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
    
    id ret = [self jg_objectAtIndex:index];
    if (ret == nil) {
        return defaultValue;
    }
    
    return [@{@"JGSObjectKey": ret} jg_boolForKey:@"JGSObjectKey" defaultValue:defaultValue];
}

- (int)jg_intAtIndex:(NSUInteger)index {
    return [self jg_intAtIndex:index defaultValue:0];
}

- (int)jg_intAtIndex:(NSUInteger)index defaultValue:(int)defaultValue {
    
    id ret = [self jg_objectAtIndex:index];
    if (ret == nil) {
        return defaultValue;
    }
    
    return [@{@"JGSObjectKey": ret} jg_intForKey:@"JGSObjectKey" defaultValue:defaultValue];
}

- (NSInteger)jg_integerAtIndex:(NSUInteger)index {
    return [self jg_integerAtIndex:index defaultValue:0];
}

- (NSInteger)jg_integerAtIndex:(NSUInteger)index defaultValue:(NSInteger)defaultValue {
    
    id ret = [self jg_objectAtIndex:index];
    if (ret == nil) {
        return defaultValue;
    }
    
    return [@{@"JGSObjectKey": ret} jg_integerForKey:@"JGSObjectKey" defaultValue:defaultValue];
}

- (CGFloat)jg_floatAtIndex:(NSUInteger)index {
    return [self jg_floatAtIndex:index defaultValue:0.f];
}

- (CGFloat)jg_floatAtIndex:(NSUInteger)index defaultValue:(CGFloat)defaultValue {
    
    id ret = [self jg_objectAtIndex:index];
    if (ret == nil) {
        return defaultValue;
    }
    
    return [@{@"JGSObjectKey": ret} jg_CGFloatForKey:@"JGSObjectKey" defaultValue:defaultValue];
}

- (NSString *)jg_stringAtIndex:(NSUInteger)index {
    return [self jg_stringAtIndex:index defaultValue:nil];
}

- (NSString *)jg_stringAtIndex:(NSUInteger)index defaultValue:(NSString *)defaultValue {
    
    id ret = [self jg_objectAtIndex:index];
    if (ret == nil) {
        return defaultValue;
    }
    
    return [@{@"JGSObjectKey": ret} jg_stringForKey:@"JGSObjectKey" defaultValue:defaultValue];
}

- (NSDictionary *)jg_dictionaryAtIndex:(NSUInteger)index {
    return [self jg_dictionaryAtIndex:index defaultValue:nil];
}

- (NSDictionary *)jg_dictionaryAtIndex:(NSUInteger)index defaultValue:(NSDictionary *)defaultValue {
    
    id ret = [[self jg_objectAtIndex:index] jg_JSONObject];
    if (ret == nil) {
        return defaultValue;
    }
    
    return [@{@"JGSObjectKey": ret} jg_dictionaryForKey:@"JGSObjectKey" defaultValue:defaultValue];
}

- (NSArray *)jg_arrayAtIndex:(NSUInteger)index {
    return [self jg_arrayAtIndex:index defaultValue:nil];
}

- (NSArray *)jg_arrayAtIndex:(NSUInteger)index defaultValue:(NSArray *)defaultValue {
    
    id ret = [[self jg_objectAtIndex:index] jg_JSONObject];
    if (ret == nil) {
        return defaultValue;
    }
    
    return [@{@"JGSObjectKey": ret} jg_arrayForKey:@"JGSObjectKey" defaultValue:defaultValue];
}

@end
