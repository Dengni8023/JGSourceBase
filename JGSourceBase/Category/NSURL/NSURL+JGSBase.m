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
    
    // 标准 URL 系统API能够正确返回 query 参数
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    return components.queryItems;
}

- (NSArray<NSURLQueryItem *> *)jg_fragmentQueryItems {
    
    // 标准 URL 系统API能够正确返回 query 参数
    // Vue 等带 # 符号的链接，如：https://m.baidu.com/index.html#/serves/ascheduleForDetails&thirdMarkCode=10&isNav=false&isNav=false&empty=&=&redirect=https://baike.baidu.com/item/Query/3789545?fr=aladdin
    // 识别参数应分别为：
    // thirdMarkCode=10
    // isNav=false
    // redirect=https://baike.baidu.com/item/Query/3789545?fr=aladdin
    // 但系统方法无法直接识别，需要对 fragment 获取参数
    NSString *fragment = self.fragment;
    if (fragment.length == 0 || [fragment rangeOfString:@"?"].location == NSNotFound) {
        return nil;
    }
    
    NSURL *fragmentURL = [NSURL URLWithString:fragment];
    return fragmentURL.jg_queryItems;
}

- (NSDictionary<NSString *,NSString *> *)jg_queryParams {
    
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

- (NSDictionary<NSString *,NSString *> *)jg_fragmentQueryParams {
    
    NSMutableDictionary<NSString *, NSString *> *params = @{}.mutableCopy;
    for (NSURLQueryItem *queryItem in self.jg_fragmentQueryItems) {
        
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
