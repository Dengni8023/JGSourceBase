//
//  JGSStringURLUtils.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSStringURLUtils.h"

@implementation JGSStringURLUtils

@end

@implementation NSString (JGSStringURLUtils)

/** does not include "?" or "/" due to RFC 3986 - Section 3.4 */
static NSString * const kJGSURL_AFCharactersGeneralDelimitersToEncode = @":#[]@";
static NSString * const kJGSURL_AFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";

- (instancetype)jg_URLEncodeString {
    
    NSMutableCharacterSet *allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kJGSURL_AFCharactersGeneralDelimitersToEncode stringByAppendingString:kJGSURL_AFCharactersSubDelimitersToEncode]];
    
    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    static NSUInteger const batchSize = 50;
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < self.length) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"
        NSUInteger length = MIN(self.length - index, batchSize);
#pragma GCC diagnostic pop
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [self rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [self substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}

- (instancetype)jg_URLString {
    
    NSString *URLString = self.copy;
    
    // Query格式不符合规范处理（缺少?而只有&）
    // 此处要求作为URL的各部分包含特殊字符“&”与”?“的内容必须已进行url编码处理
    if ([URLString rangeOfString:@"&"].length > 0 && [URLString rangeOfString:@"?"].length <= 0) {
        
        NSRange firstParamRange = [URLString rangeOfString:@"&"];
        URLString = [URLString stringByReplacingCharactersInRange:firstParamRange withString:@"?"];
    }
    
    NSMutableCharacterSet *mutSet = [NSCharacterSet URLHostAllowedCharacterSet].mutableCopy;
    [mutSet formUnionWithCharacterSet:[NSCharacterSet URLPathAllowedCharacterSet]];
    [mutSet formUnionWithCharacterSet:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [mutSet formUnionWithCharacterSet:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    [mutSet formUnionWithCharacterSet:[NSCharacterSet URLUserAllowedCharacterSet]];
    [mutSet formUnionWithCharacterSet:[NSCharacterSet URLPasswordAllowedCharacterSet]];
    NSCharacterSet *urlCharSet = mutSet.copy;
    
    // 中文字符正则表达式
    // 中文字 。 ； ， ： “ ”（ ） 、 ？ 《 》
    NSError *error = nil;
    NSString *regTags = @"[[\u4e00-\u9fa5][\u3002\uff1b\uff0c\uff1a\u201c\u201d\uff08\uff09\u3001\uff1f\u300a\u300b]]+";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags options:NSRegularExpressionCaseInsensitive error:&error];
    
    // 1、正则表达式匹配查找中文字符串
    // 2、中文字符串匹配编码
    // 3、中文字符串替换为编码字符串
    NSArray *matches = [regex matchesInString:URLString options:0 range:NSMakeRange(0, URLString.length)];
    while (matches.count > 0) {
        
        NSTextCheckingResult *match = [matches firstObject];
        NSString *zhStr = [URLString substringWithRange:match.range];
        NSString *zhURLStr = [zhStr stringByAddingPercentEncodingWithAllowedCharacters:urlCharSet];
        
        // 替换
        URLString = [URLString stringByReplacingCharactersInRange:match.range withString:zhURLStr];
        
        // 每次替换一段字符串，替换后需在新字符串中查找下一串
        matches = [regex matchesInString:URLString options:0 range:NSMakeRange(0, URLString.length)];
    }
    
    // 不可见字符正则表达式
    error = nil;
    regTags = @"\\s+";
    regex = [NSRegularExpression regularExpressionWithPattern:regTags options:NSRegularExpressionCaseInsensitive error:&error];
    
    // 1、正则表达式匹配查找特殊字符串
    // 2、特殊字符串匹配编码
    // 3、特殊字符串替换为编码字符串
    matches = [regex matchesInString:URLString options:0 range:NSMakeRange(0, URLString.length)];
    while (matches.count > 0) {
        
        NSTextCheckingResult *match = [matches firstObject];
        NSString *zhStr = [URLString substringWithRange:match.range];
        NSString *zhURLStr = [zhStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        // 替换
        URLString = [URLString stringByReplacingCharactersInRange:match.range withString:zhURLStr];
        
        // 每次替换一段字符串，替换后需在新字符串中查找下一串
        matches = [regex matchesInString:URLString options:0 range:NSMakeRange(0, URLString.length)];
    }
    
    return URLString;
}

- (NSURL *)jg_URL {
    return [NSURL URLWithString:self.jg_URLString];
}

@end

@implementation NSURL (JGSStringURLUtils)

- (NSArray<NSURLQueryItem *> *)jg_queryItems {
    
    // iOS 8以后不需要使用正则表达式，系统提供方法获取query
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    return components.queryItems;
}

- (NSDictionary<NSString *,NSString *> *)jg_queryParams {
    
    return [self jg_queryParams:JGSURLQueryPolicyFirst];
}

- (NSDictionary<NSString *,NSString *> *)jg_queryParams:(JGSURLQueryPolicy)policy {
    
    // iOS 8以后不需要使用正则表达式，系统提供方法获取query
    NSMutableDictionary<NSString *, NSString *> *params = @{}.mutableCopy;
    for (NSURLQueryItem *queryItem in self.jg_queryItems) {
        
        if ([params.allKeys containsObject:queryItem.name]) {
            
            switch (policy) {
                case JGSURLQueryPolicyFirst:
                    continue;
                    break;
                    
                case JGSURLQueryPolicyFirstUnempty: {
                    if (params[queryItem.name].length > 0) {
                        continue;
                    }
                }
                    break;
                    
                case JGSURLQueryPolicyLast:
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
    
    return [self jg_queryValueWithKey:key policy:JGSURLQueryPolicyFirst];
}

- (NSString *)jg_queryValueWithKey:(NSString *)key policy:(JGSURLQueryPolicy)policy {
    
    NSAssert(key.length > 0, @"Please use a certain key");
    
    NSDictionary *queryParams = [self jg_queryParams:policy];
    if ([queryParams.allKeys containsObject:key]) {
        
        return queryParams[key];
    }
    return nil;
}

@end
