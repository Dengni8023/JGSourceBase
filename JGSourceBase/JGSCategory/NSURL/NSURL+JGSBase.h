//
//  NSURL+JGSBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2021/9/15.
//  Copyright © 2021 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Query参数转字典重名key处理方式
 URL重名参数一般处理为重名参数对应的值使用英文逗号拼接，因此该定义不再使用
 */
typedef NS_ENUM(NSInteger, JGSURLQueryPolicy) {
    JGSURLQueryPolicyFirst, // 重名时使用第一个Query参数
    JGSURLQueryPolicyFirstUnempty, // // 重名时使用第一个非空Query参数
    JGSURLQueryPolicyLast, // 重名时使用最后一个Query参数
} NS_UNAVAILABLE;

@interface NSURL (JGSBase)

/**
 获取 URL 参数信息，请注意#后的参数如需获取，请获取 fragment 之后，对 fragment 获取query
 */
@property (nonatomic, copy, nullable, readonly) NSArray<NSURLQueryItem *> *jg_queryItems;

/**
 获取 URL.fragment 参数信息，针对 vue 等参数 位于 # 之后的参数进行获取
 */
@property (nonatomic, copy, nullable, readonly) NSArray<NSURLQueryItem *> *jg_fragmentQueryItems;

/**
 参数字典
 无参数返回空字典，空参数返回空字符串，参数重名则重名参数对应的值使用英文逗号拼接
 @return NSDictionary
 */
@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, NSString *> *jg_queryParams;

/**
 URL.fragment 参数字典
 无参数返回空字典，空参数返回空字符串，参数重名则重名参数对应的值使用英文逗号拼接
 @return NSDictionary
 */
@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, NSString *> *jg_fragmentQueryParams;

/** URL重名参数一般处理为重名参数对应的值使用英文逗号拼接，因此该定义不再使用 */
- (nullable NSDictionary<NSString *, NSString *> *)jg_queryParams:(JGSURLQueryPolicy)policy NS_UNAVAILABLE;

/** 是否存在key参数，即存在 key=，key对应参数值可能为空 */
- (BOOL)jg_existQueryForKey:(NSString *)key;
- (BOOL)jg_existQueryKey:(NSString *)key DEPRECATED_MSG_ATTRIBUTE("Use -jg_existQueryForKey: instead");

/**
 参数查询
 编码的中文字符串自动解码为中文，特殊字符则进行 URL 解码
 未查询到 Key 则返回 nil ，key 对应参数值为空则返回空字符串，参数重名则重名参数对应的值使用英文逗号拼接
 
 @param key 参数对应Key
 @return NSString
 */
- (nullable NSString *)jg_queryForKey:(NSString *)key;
- (nullable NSString *)jg_queryValueWithKey:(NSString *)key DEPRECATED_MSG_ATTRIBUTE("Use -jg_queryForKey: instead");

/** URL 重名参数一般处理为重名参数对应的值使用英文逗号拼接，因此该定义不再使用 */
- (nullable NSString *)jg_queryValueWithKey:(NSString *)key policy:(JGSURLQueryPolicy)policy NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
