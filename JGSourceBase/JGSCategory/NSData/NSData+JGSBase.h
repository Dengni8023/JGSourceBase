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

/// UTF8字符串
@property (nonatomic, copy, readonly, nullable) NSString *jg_utf8String;

#pragma mark - Base64
/// Base64编码，单行
@property (nonatomic, copy, readonly) NSData *jg_base64EncodeData;

/// Base64编码
/// - Parameter options: 编码选项
- (NSData *)jg_base64EncodeData:(NSDataBase64EncodingOptions)options;

/// Base64编码，单行
@property (nonatomic, copy, readonly) NSString *jg_base64EncodeString;

/// Base64编码
/// - Parameter options: 编码选项
- (NSString *)jg_base64EncodeString:(NSDataBase64EncodingOptions)options;

/// Base64解码后Data数据，NSDataBase64DecodingIgnoreUnknownCharacters
@property (nonatomic, copy, readonly, nullable) NSData *jg_base64DecodeData;

/// Base64解码后Data数据
/// - Parameter options: 解码选项
- (nullable NSData *)jg_base64DecodeData:(NSDataBase64DecodingOptions)options;

/// Base64解码后UTF8字符串
@property (nonatomic, copy, readonly, nullable) NSString *jg_base64DecodeString;

/// Base64解码后Data数据
/// - Parameter options: 解码选项
- (nullable NSString *)jg_base64DecodeString:(NSDataBase64DecodingOptions)options;

#pragma mark - MD5
/// 获取MD5散列字符串，小写
@property (nonatomic, copy, readonly) NSString *jg_md5String DEPRECATED_MSG_ATTRIBUTE("Use -jg_md5 instead");
/// 获取MD5散列字符串
/// @param style 字符串大小写风格
- (NSString *)jg_md5String:(JGSStringCaseStyle)style DEPRECATED_MSG_ATTRIBUTE("Use -jg_md5: instead");;

/// 获取MD5散列字符串，小写
@property (nonatomic, copy, readonly) NSString *jg_md5;

/// 获取MD5散列字符串
/// @param style 字符串大小写风格
- (NSString *)jg_md5:(JGSStringCaseStyle)style;

#pragma mark - SHA128
/// 获取SHA128散列字符串，小写
@property (nonatomic, copy, readonly) NSString *jg_sha128String DEPRECATED_MSG_ATTRIBUTE("Use -jg_sha128 instead");

/// 获取SHA128散列字符串
/// @param style 字符串大小写风格
- (NSString *)jg_sha128String:(JGSStringCaseStyle)style DEPRECATED_MSG_ATTRIBUTE("Use -jg_sha128: instead");

/// 获取SHA128散列字符串，小写
@property (nonatomic, copy, readonly) NSString *jg_sha128;

/// 获取SHA128散列字符串
/// @param style 字符串大小写风格
- (NSString *)jg_sha128:(JGSStringCaseStyle)style;

#pragma mark - SHA256
/// 获取SHA256散列字符串，小写
@property (nonatomic, copy, readonly, nullable) NSString *jg_sha256String DEPRECATED_MSG_ATTRIBUTE("Use -jg_sha256 instead");

/// 获取SHA256散列字符串
/// @param style 字符串大小写风格
- (nullable NSString *)jg_sha256String:(JGSStringCaseStyle)style DEPRECATED_MSG_ATTRIBUTE("Use -jg_sha256: instead");

/// 获取SHA128散列字符串，小写
@property (nonatomic, copy, readonly) NSString *jg_sha256;

/// 获取SHA128散列字符串
/// @param style 字符串大小写风格
- (NSString *)jg_sha256:(JGSStringCaseStyle)style;

#pragma mark - SHA384
/// 获取SHA384散列字符串，小写
@property (nonatomic, copy, readonly, nullable) NSString *jg_sha384String DEPRECATED_MSG_ATTRIBUTE("Use -jg_sha384 instead");

/// 获取SHA384散列字符串
/// @param style 字符串大小写风格
- (nullable NSString *)jg_sha384String:(JGSStringCaseStyle)style DEPRECATED_MSG_ATTRIBUTE("Use -jg_sha384: instead");

/// 获取SHA128散列字符串，小写
@property (nonatomic, copy, readonly) NSString *jg_sha384;

/// 获取SHA128散列字符串
/// @param style 字符串大小写风格
- (NSString *)jg_sha384:(JGSStringCaseStyle)style;

#pragma mark - SHA512
/// 获取SHA512散列字符串，小写
@property (nonatomic, copy, readonly, nullable) NSString *jg_sha512String DEPRECATED_MSG_ATTRIBUTE("Use -jg_sha512 instead");

/// 获取SHA512散列字符串
/// @param style 字符串大小写风格
- (nullable NSString *)jg_sha512String:(JGSStringCaseStyle)style DEPRECATED_MSG_ATTRIBUTE("Use -jg_sha512: instead");

/// 获取SHA128散列字符串，小写
@property (nonatomic, copy, readonly) NSString *jg_sha512;

/// 获取SHA128散列字符串
/// @param style 字符串大小写风格
- (NSString *)jg_sha512:(JGSStringCaseStyle)style;

#pragma mark - Hex
/// Data转16进制字符串，小写
@property (nonatomic, copy, readonly, nullable) NSString *jg_hexString DEPRECATED_MSG_ATTRIBUTE("Use -jg_hex instead");

/// Data转16进制字符串
/// @param style 字符串大小写风格
- (nullable NSString *)jg_hexString:(JGSStringCaseStyle)style DEPRECATED_MSG_ATTRIBUTE("Use -jg_hex: instead");

/// Data转16进制字符串，小写
@property (nonatomic, copy, readonly) NSString *jg_hex;

/// Data转16进制字符串
/// @param style 字符串大小写风格
- (NSString *)jg_hex:(JGSStringCaseStyle)style;

@end

NS_ASSUME_NONNULL_END
