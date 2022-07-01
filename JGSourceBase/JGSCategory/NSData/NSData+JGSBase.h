//
//  NSData+JGSBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/5/26.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<JGSourceBase/JGSBase.h>)
#import <JGSourceBase/JGSBase.h>
#else
#import "JGSBase.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSData (JGSBase)

#pragma mark - Base64
/// Base64编码后Data数据
@property (nonatomic, copy, readonly, nullable) NSData *jg_base64EncodeData;

/// Base64编码后字符串
@property (nonatomic, copy, readonly, nullable) NSString *jg_base64EncodeString;

/// Base64解码后Data数据
@property (nonatomic, copy, readonly, nullable) NSData *jg_base64DecodeData;

/// Base64解码后UTF8字符串
@property (nonatomic, copy, readonly, nullable) NSString *jg_base64DecodeString;

#pragma mark - HASH
/// 获取MD5散列字符串，小写
@property (nonatomic, copy, readonly, nullable) NSString *jg_md5String;

/// 获取SHA128散列字符串，小写
@property (nonatomic, copy, readonly, nullable) NSString *jg_sha128String;

/// 获取SHA256散列字符串，小写
@property (nonatomic, copy, readonly, nullable) NSString *jg_sha256String;

/// 获取SHA384散列字符串，小写
@property (nonatomic, copy, readonly, nullable) NSString *jg_sha384String;

/// 获取SHA512散列字符串，小写
@property (nonatomic, copy, readonly, nullable) NSString *jg_sha512String;

/// 获取MD5散列字符串
/// @param style 字符串大小写风格
- (nullable NSString *)jg_md5String:(JGSStringUpperLowerStyle)style;

/// 获取SHA128散列字符串
/// @param style 字符串大小写风格
- (nullable NSString *)jg_sha128String:(JGSStringUpperLowerStyle)style;

/// 获取SHA256散列字符串
/// @param style 字符串大小写风格
- (nullable NSString *)jg_sha256String:(JGSStringUpperLowerStyle)style;

/// 获取SHA384散列字符串
/// @param style 字符串大小写风格
- (nullable NSString *)jg_sha384String:(JGSStringUpperLowerStyle)style;

/// 获取SHA512散列字符串
/// @param style 字符串大小写风格
- (nullable NSString *)jg_sha512String:(JGSStringUpperLowerStyle)style;

@end

NS_ASSUME_NONNULL_END
