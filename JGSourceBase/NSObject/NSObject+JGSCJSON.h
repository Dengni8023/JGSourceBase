//
//  NSObject+JGSCJSON.h
//  JGSourceBase
//
//  Created by 梅继高 on 2018/6/22.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (JGSCJSON)

#pragma mark - Parser
/**
 JSON解析NSString、NSData获取合法的JSON对象（NSArray、NSDictionary）
 NSData必须为UTF8编码的JSON，若已是合法JSON对象则原样返回
 
 @param error 解析错误
 @return 合法的JSON对象（NSArray、NSDictionary）
 */
- (nullable id)jg_JSONObject:(NSError **)error;
- (nullable id)jg_JSONObject;

/**
 JSON解析NSString、NSData，获取JSON对象可能不合法（NSNumber, NSArray, NSDictionary, or NSNull）
 NSData必须为UTF8编码的JSON，若已是合法JSON对象则原样返回
 
 @param error 解析错误
 @return JSON对象（NSNumber, NSArray, NSDictionary, or NSNull）
 */
- (nullable id)jg_JSONObjectAllowFragments:(NSError **)error;
- (nullable id)jg_JSONObjectAllowFragments;

/**
 JSON解析NSString、NSData获取合法的JSON对象（NSArray、NSDictionary），叶子结点为可变类型（字符串为NSMutableString）
 NSData必须为UTF8编码的JSON，若已是合法JSON对象则处理叶子结点为可变类型
 
 #param error 解析错误信息
 @return 合法的JSON对象（NSArray、NSDictionary）
 */
- (nullable id)jg_JSONObjectWithMutableLeaf:(NSError **)error;
- (nullable id)jg_JSONObjectWithMutableLeaf;

/**
 JSON解析NSString、NSData获取合法的JSON对象（NSArray、NSDictionary），容器为可变类型（NSMutableDictionary、NSMutableArray，嵌套时每层均可变）
 NSData必须为UTF8编码的JSON，若已是合法JSON对象则处理容器为可变类型
 
 #param error 解析错误信息
 @return 合法的JSON对象（NSMutableDictionary、NSMutableArray）
 */
- (nullable id)jg_JSONObjectWithMutableContainer:(NSError **)error;
- (nullable id)jg_JSONObjectWithMutableContainer;

/**
 JSON解析NSString、NSData获取可变的JSON对象（NSArray、NSDictionary）
 容器为可变类型（NSMutableDictionary、NSMutableArray，嵌套时每层均可变）
 叶子结点为可变类型（字符串为NSMutableString）
 NSData必须为UTF8编码的JSON，若已是合法JSON对象则处理容器、叶子结点为可变类型
 
 #param error 解析错误信息
 @return 合法的JSON对象（NSMutableDictionary、NSMutableArray）
 */
- (nullable id)jg_JSONObjectWithMutableContainerLeaf:(NSError **)error;
- (nullable id)jg_JSONObjectWithMutableContainerLeaf;

/**
 JSON解析NSString、NSData
 NSData必须为UTF8编码的JSON，若已是合法JSON对象则根据options判断是否处理容器、叶子结点为可变类型
 
 @param options 解析配置Options
 @param error 解析错误信息
 @return JSON解析结果
 */
- (nullable id)jg_JSONObjectWithOptions:(NSJSONReadingOptions)options error:(NSError **)error;

#pragma mark - Encode
/**
 JSON构建NSData，NSData直接返回，合法JSON对象则返回根据options构建的JSON对应的NSData，其他则返回nil
 
 @param options 构建配置Options
 @param error 构建错误信息
 @return 构建NSData结果
 */
- (nullable NSData *)jg_JSONDataWithOptions:(NSJSONWritingOptions)options error:(NSError **)error;
- (nullable NSData *)jg_JSONData:(NSError **)error;
- (nullable NSData *)jg_JSONData;

/**
 JSON构建NSString，NSString直接返回，其他则获取JSON对应的NSData后使用UTF8编码为NSString
 
 @param options 构建配置Options
 @param error 构建错误信息
 @return 构建NSString结果
 */
- (nullable NSString *)jg_JSONStringWithOptions:(NSJSONWritingOptions)options error:(NSError **)error;
- (nullable NSString *)jg_JSONString:(NSError **)error;
- (nullable NSString *)jg_JSONString;

#pragma mark - NSNull
/**
 移除Array中的NSNull元素，移除Dictionary中值为NSNull对应的Key
 
 @return 移除后的结果
 */
- (nullable instancetype)jg_removeAllNullValues;

@end

NS_ASSUME_NONNULL_END
