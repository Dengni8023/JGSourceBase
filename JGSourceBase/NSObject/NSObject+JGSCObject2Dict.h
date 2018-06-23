//
//  NSObject+JGSCObject2Dict.h
//  JGSourceBase
//
//  Created by 梅继高 on 2018/6/23.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (JGSCObject2Dict)

/**
 通过属性遍历方式将对象转JSON字典
 
 @return NSDictionary
 */
- (NSDictionary *)jg_Object2Dictionary;

/**
 属性名与JSON字典的key不一致，返回不一致的[{属性名1:key2},{属性名2:key2}]
 
 @return NSDictionary
 */
- (nullable NSDictionary<NSString *, NSString *> *)jg_2DictionaryPropertyKeyReflect;

/**
 不参与构建JSON字典的属性字段
 建议通过方法NSStringFromSelector(@selector(property))获取属性名，便于属性名修改时替换更新
 
 @return NSArray
 */
- (nullable NSArray<NSString *> *)jg_2DictionaryExcludePropertyNames;

@end

NS_ASSUME_NONNULL_END
