//
//  NSURL+JGSCURLQuery.h
//  JGSourceBase
//
//  Created by 梅继高 on 2018/6/22.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Query参数转字典重名key处理方式 */
typedef NS_ENUM(NSInteger, JGSCURLQueryPolicy) {
    JGSCURLQueryPolicyFirst, // 重名时使用第一个Query参数
    JGSCURLQueryPolicyFirstUnempty, // // 重名时使用第一个非空Query参数
    JGSCURLQueryPolicyLast, // 重名时使用最后一个Query参数
};

@interface NSURL (JGSCURLQuery)

@property (nonatomic, strong, readonly, nullable) NSArray<NSURLQueryItem *> *jg_queryItems;

/**
 参数字典，Query重名使用第一个Query参数
 @see jg_queryParams:

 @return NSDictionary
 */
- (NSDictionary<NSString *, NSString *> *)jg_queryParams;

/**
 编码的中文字符串自动解码为中文，特殊字符则进行URL解码
 无参数返回空字典，空参数返回空字符串

 @param policy Query参数转字典重名key处理方式
 @return NSDictionary
 */
- (NSDictionary<NSString *, NSString *> *)jg_queryParams:(JGSCURLQueryPolicy)policy;

/** 是否存在key参数，即存在 key=，key对应参数值可能为空 */
- (BOOL)jg_existQueryKey:(NSString *)key;

/**
 参数查询，，Query重名使用第一个Query参数
 
 @param key 参数对应Key
 @return NSString
 */
- (nullable NSString *)jg_queryValueWithKey:(NSString *)key;

/**
 参数查询
 编码的中文字符串自动解码为中文，特殊字符则进行URL解码
 未查询到Key则返回nil，key对应参数值为空则返回空字符串

 @param key 参数对应Key
 @param policy Query参数转字典重名key处理方式
 @return NSString
 */
- (nullable NSString *)jg_queryValueWithKey:(NSString *)key policy:(JGSCURLQueryPolicy)policy;

@end

NS_ASSUME_NONNULL_END
