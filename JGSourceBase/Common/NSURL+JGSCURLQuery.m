//
//  NSURL+JGSCURLQuery.m
//  JGSourceBase
//
//  Created by 梅继高 on 2018/6/22.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "NSURL+JGSCURLQuery.h"

@implementation NSURL (JGSCURLQuery)

- (NSArray<NSURLQueryItem *> *)jg_queryItems {
    
    // iOS 8以后不需要使用正则表达式，系统提供方法获取query
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    return components.queryItems;
}

- (NSDictionary *)jg_queryParams {
    
    return [self jg_queryParams:JGSCURLQueryPolicyFirst];
}

- (NSDictionary *)jg_queryParams:(JGSCURLQueryPolicy)policy {
    
    // iOS 8以后不需要使用正则表达式，系统提供方法获取query
    NSMutableDictionary<NSString *, NSString *> *params = @{}.mutableCopy;
    for (NSURLQueryItem *queryItem in self.jg_queryItems) {
        
        if ([params.allKeys containsObject:queryItem.name]) {
            
            switch (policy) {
                case JGSCURLQueryPolicyFirst:
                    continue;
                    break;
                    
                case JGSCURLQueryPolicyFirstUnempty: {
                    if (params[queryItem.name].length > 0) {
                        continue;
                    }
                }
                    break;
                    
                case JGSCURLQueryPolicyLast:
                    break;
            }
        }
        [params setObject:queryItem.value ?: @"" forKey:queryItem.name];
    }
    
    return params.copy;
}

- (BOOL)jg_existQueryKey:(NSString *)key {
    
    NSAssert(key.length > 0, @"Please use a certain key");
    
    NSDictionary *queryParams = [self jg_queryParams];
    
    return [queryParams.allKeys containsObject:key];
}

- (NSString *)jg_queryValueWithKey:(NSString *)key {
    
    return [self jg_queryValueWithKey:key policy:JGSCURLQueryPolicyFirst];
}

- (NSString *)jg_queryValueWithKey:(NSString *)key policy:(JGSCURLQueryPolicy)policy {
    
    NSAssert(key.length > 0, @"Please use a certain key");
    
    NSDictionary *queryParams = [self jg_queryParams:policy];
    if ([queryParams.allKeys containsObject:key]) {
        
        return queryParams[key];
    }
    return nil;
}

@end
