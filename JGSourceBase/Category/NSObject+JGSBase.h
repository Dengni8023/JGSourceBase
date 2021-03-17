//
//  NSObject+JGSBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (JGSBase)

#pragma mark - Parser
/**
 JSON解析，NSString、NSData获取合法的JSON对象（NSArray、NSDictionary）
 NSData必须为UTF8编码的JSON，若已是合法JSON对象则根据options判断是否处理容器、叶子结点为可变类型
 
 @param options 解析配置Options
 @param error 解析错误信息
 @return JSON解析结果
 */
- (nullable id)jg_JSONObjectWithOptions:(NSJSONReadingOptions)options error:(NSError **)error;
- (nullable id)jg_JSONObject:(NSError **)error;

@property (nonatomic, copy, readonly, nullable) id jg_JSONObject;

#pragma mark - Encode
/**
 JSON构建NSData，NSData直接返回，合法JSON对象则返回根据options构建的JSON对应的NSData，其他则返回nil
 
 @param options 构建配置Options
 @param error 构建错误信息
 @return 构建NSData结果
 */
- (nullable NSData *)jg_JSONDataWithOptions:(NSJSONWritingOptions)options error:(NSError **)error;
- (nullable NSData *)jg_JSONData:(NSError **)error;

@property (nonatomic, copy, readonly, nullable) NSData *jg_JSONData;

/**
 JSON构建NSString，NSString直接返回，其他则获取JSON对应的NSData后使用UTF8编码为NSString
 
 @param options 构建配置Options
 @param error 构建错误信息
 @return 构建NSString结果
 */
- (nullable NSString *)jg_JSONStringWithOptions:(NSJSONWritingOptions)options error:(NSError **)error;
- (nullable NSString *)jg_JSONString:(NSError **)error;

@property (nonatomic, copy, readonly, nullable) NSString *jg_JSONString;

#pragma mark - NSNull
/**
 移除Array中的NSNull元素，移除Dictionary中值为NSNull对应的Key
 
 @return 移除后的结果
 */
- (nullable instancetype)jg_removeAllNullValues;

#pragma mark - Base64
@property (nonatomic, copy, readonly, nullable) NSData *jg_base64EncodeData;
@property (nonatomic, copy, readonly, nullable) NSString *jg_base64EncodeString;

@property (nonatomic, copy, readonly, nullable) NSData *jg_base64DecodeData;
@property (nonatomic, copy, readonly, nullable) NSString *jg_base64DecodeString;

@end

NS_ASSUME_NONNULL_END
