//
//  NSURL+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/9/15.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import "NSURL+JGSBase.h"

@implementation NSURL (JGSBase)

- (NSArray<NSURLQueryItem *> *)jg_queryItems {
    
    // iOS 8以后不需要使用正则表达式，系统提供方法获取query
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    return components.queryItems;
}

- (NSDictionary<NSString *,NSString *> *)jg_queryParams {
    
    // iOS 8以后不需要使用正则表达式，系统提供方法获取query
    NSMutableDictionary<NSString *, NSString *> *params = @{}.mutableCopy;
    for (NSURLQueryItem *queryItem in self.jg_queryItems) {
        
        NSString *name = queryItem.name;
        NSString *value = queryItem.value ?: @"";
        if ([params.allKeys containsObject:name]) {
            value = [params[name] stringByAppendingFormat:@",%@", value];
        }
        [params setObject:value forKey:name];
    }
    
    return params.count > 0 ? params.copy : nil;
}

- (NSDictionary<NSString *,NSString *> *)jg_queryParams:(JGSURLQueryPolicy)policy {
    return self.jg_queryParams;
}

- (BOOL)jg_existQueryForKey:(NSString *)key {
    NSAssert(key.length > 0, @"Please use a certain key");
    return [self.jg_queryParams.allKeys containsObject:key];
}

- (BOOL)jg_existQueryKey:(NSString *)key {
    return [self jg_existQueryForKey:key];
}

- (NSString *)jg_queryForKey:(NSString *)key {
    
    NSAssert(key.length > 0, @"Please use a certain key");
    NSDictionary *queryParams = self.jg_queryParams;
    if ([queryParams.allKeys containsObject:key]) {
        return queryParams[key];
    }
    return nil;
}

- (NSString *)jg_queryValueWithKey:(NSString *)key {
    return [self jg_queryForKey:key];
}

- (NSString *)jg_queryValueWithKey:(NSString *)key policy:(JGSURLQueryPolicy)policy {
    return [self jg_queryForKey:key];
}

#pragma mark - End

@end
