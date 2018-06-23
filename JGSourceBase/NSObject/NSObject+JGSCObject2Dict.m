//
//  NSObject+JGSCObject2Dict.m
//  JGSourceBase
//
//  Created by 梅继高 on 2018/6/23.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "NSObject+JGSCObject2Dict.h"
#import <objc/runtime.h>

@implementation NSObject (JGSCObject2Dict)

- (NSDictionary *)jg_Object2Dictionary {
    
    NSMutableDictionary *jsonDic = @{}.mutableCopy;
    NSDictionary *prop2Key = self.jg_2DictionaryPropertyKeyReflect;
    NSArray *excludeProps = self.jg_2DictionaryExcludePropertyNames;
    
    u_int propsCount;
    Class cls = [self class];
    while (![cls isEqual:[NSObject class]]) {
        
        objc_property_t *properties = class_copyPropertyList(cls, &propsCount);
        for (NSInteger i = 0; i < propsCount; i++) {
            
            const char * propertyName = property_getName(properties[i]);
            NSString *propName = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
            if (![excludeProps containsObject:propName]) {
                
                id propValue = [self valueForKey:propName];
                if (propValue) {
                    
                    NSString *keyName = propName;
                    if ([prop2Key.allKeys containsObject:propName]) {
                        keyName = prop2Key[propName];
                    }
                    
                    [jsonDic setObject:[propValue jg_PropertyObject2Dictionary] forKey:keyName];
                }
            }
        }
        free(properties);
        
        //得到父类的信息
        cls = class_getSuperclass(cls);
    }
    
    return jsonDic.copy;
}

- (id)jg_PropertyObject2Dictionary {
    
    if ([self isKindOfClass:[NSString class]] ||
        [self isKindOfClass:[NSNumber class]] ||
        [self isKindOfClass:[NSNull class]]) {
        
        return self;
    }
    
    if ([self isKindOfClass:[NSArray class]]) {
        
        NSArray *objarr = (NSArray *)self;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0; i < objarr.count; i++) {
            
            [arr setObject:[objarr[i] jg_PropertyObject2Dictionary] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *objdic = (NSDictionary *)self;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys) {
            
            [dic setObject:[objdic[key] jg_PropertyObject2Dictionary] forKey:key];
        }
        return dic;
    }
    
    return [self jg_Object2Dictionary];
    
}
- (NSDictionary<NSString *,NSString *> *)jg_2DictionaryPropertyKeyReflect {
    return nil;
}

- (NSArray<NSString *> *)jg_2DictionaryExcludePropertyNames {
    return nil;
}

@end
