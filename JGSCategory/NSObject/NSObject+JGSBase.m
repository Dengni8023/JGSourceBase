//
//  NSObject+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJiGao. All rights reserved.
//

#import "NSObject+JGSBase.h"

@implementation NSObject (JGSBase)

#pragma mark - JSONParser
- (id)jg_JSONObject {
    return [self jg_JSONObject:NULL];
}

- (id)jg_JSONObject:(NSError * _Nullable __autoreleasing *)error {
    return [self jg_JSONObjectWithOptions:kNilOptions error:error];
}

- (id)jg_JSONObjectWithOptions:(NSJSONReadingOptions)options error:(NSError * _Nullable __autoreleasing *)error {
    
    if (([self isKindOfClass:[NSNumber class]] || [self isKindOfClass:[NSNull class]]) && (options & NSJSONReadingAllowFragments)) {
        return self;
    }
    
    NSData *encodeData = nil;
    if ([NSJSONSerialization isValidJSONObject:self]) {
        
        // 已经是合法的JSON对象，判断处理options
        if (options & (NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers | NSJSONReadingAllowFragments)) {
            
            encodeData = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:error];
            if (!encodeData || (error != NULL && *error)) {
                return nil;
            }
        } else {
            return self;
        }
    }
    
    // 非JSON对象转NSData
    if ([self isKindOfClass:[NSData class]]) {
        encodeData = (NSData *)self;
    }
    else if ([self isKindOfClass:[NSString class]]) {
        encodeData = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    // 无法转换为NSData处理
    if (!encodeData) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Can't parser object <%@>, a kind of class %@.", self, NSStringFromClass([self class])]}];
        }
        return nil;
    }
    
    // NSData对象解析处理
    return [NSJSONSerialization JSONObjectWithData:encodeData options:options error:error];
}

#pragma mark - JSONEncode
- (NSData *)jg_JSONData {
    return [self jg_JSONData:NULL];
}

- (NSData *)jg_JSONData:(NSError * _Nullable __autoreleasing *)error {
    return [self jg_JSONDataWithOptions:kNilOptions error:error];
}

- (NSData *)jg_JSONDataWithOptions:(NSJSONWritingOptions)options error:(NSError * _Nullable __autoreleasing *)error {
    
    // NSData直接返回
    if ([self isKindOfClass:[NSData class]]) {
        return (NSData *)self;
    }
    
    // 合法JSON对象
    if ([NSJSONSerialization isValidJSONObject:self]) {
        
        return [NSJSONSerialization dataWithJSONObject:self options:options error:error];
    }
    
    return nil;
}

- (NSString *)jg_JSONString {
    return [self jg_JSONString:NULL];
}

- (NSString *)jg_JSONString:(NSError * _Nullable __autoreleasing *)error {
    return [self jg_JSONStringWithOptions:kNilOptions error:error];
}

- (NSString *)jg_JSONStringWithOptions:(NSJSONWritingOptions)options error:(NSError * _Nullable __autoreleasing *)error {
    
    // NSString直接返回
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    }
    
    // 获取JSON对应的NSData
    NSData *jsonData = [self jg_JSONDataWithOptions:options error:error];
    if (!jsonData || (error != NULL && *error)) {
        return nil;
    }
    
    // NSData进行UTF8编码
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - NSNull
- (instancetype)jg_removeAllNullValues {
    
    // NSNull直接返回nil
    if ([self isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    // 容器对象处理
    if ([self isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *tmp = self.mutableCopy;
        [(NSArray *)self enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            id rmObj = [obj jg_removeAllNullValues];
            if (!rmObj/* || [rmObj isKindOfClass:[NSNull class]]*/) {
                [tmp removeObjectAtIndex:idx];
            }
        }];
        
        // 判断返回数据对象类型判断
        if ([self isKindOfClass:[NSMutableArray class]]) {
            return tmp.mutableCopy;
        }
        else if (tmp.count > 0) {
            return tmp.copy;
        }
        else {
            return nil;
        }
    }
    else if ([self isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *tmp = self.mutableCopy;
        [(NSDictionary *)self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            id rmObj = [obj jg_removeAllNullValues];
            if (!rmObj/* || [rmObj isKindOfClass:[NSNull class]]*/) {
                [tmp removeObjectForKey:key];
            }
        }];
        
        // 判断返回数据对象类型判断
        if ([self isKindOfClass:[NSMutableDictionary class]]) {
            return tmp.mutableCopy;
        }
        else if (tmp.count > 0) {
            return tmp.copy;
        }
        else {
            return nil;
        }
    }
    return self;
}

#pragma mark - Base64
- (NSData *)jg_base64EncodeData {
    
    // 选择NSDataBase64EncodingEndLineWithLineFeed保持Android、ios、后台统一
    if ([self isKindOfClass:[NSData class]]) {
        
        return [(NSData *)self base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        
    } else if ([self isKindOfClass:[NSString class]]) {
        
        NSData *data = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
        return [data base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    
    return nil;
}

- (NSString *)jg_base64EncodeString {
    
    // 选择NSDataBase64EncodingEndLineWithLineFeed保持Android、ios、后台统一
    if ([self isKindOfClass:[NSData class]]) {
        
        return [(NSData *)self base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        
    } else if ([self isKindOfClass:[NSString class]]) {
        
        NSData *data = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
        return [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    
    return nil;
}

- (NSData *)jg_base64DecodeData {
    
    if ([self isKindOfClass:[NSData class]]) {
        
        return [[NSData alloc] initWithBase64EncodedData:(NSData *)self options:NSDataBase64DecodingIgnoreUnknownCharacters];
        
    } else if ([self isKindOfClass:[NSString class]]) {
        
        NSData *data = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
        return [[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    
    return nil;
}

- (NSString *)jg_base64DecodeString {
    
    if ([self isKindOfClass:[NSData class]]) {
        
        NSData *data = [[NSData alloc] initWithBase64EncodedData:(NSData *)self options:NSDataBase64DecodingIgnoreUnknownCharacters];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
    } else if ([self isKindOfClass:[NSString class]]) {
        
        NSData *data = [[NSData alloc] initWithBase64EncodedString:(NSString *)self options:NSDataBase64DecodingIgnoreUnknownCharacters];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

#pragma mark - End

@end
