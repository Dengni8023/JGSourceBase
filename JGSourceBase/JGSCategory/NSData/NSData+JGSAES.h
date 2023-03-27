//
//  NSData+JGSAES.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/5/26.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (JGSAES)

#pragma mark - Encrypt
/// AES128加密后NSData，CBC / PKCS7Padding，加密入参为原始NSData
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @return NSData 加密后NSData，不可转换为UTF8字符串，可转换为base64字符串
- (nullable NSData *)jg_AES128EncryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

/// AES128加密后NSData，CBC / PKCS7Padding，加密入参为原始NSData
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @return NSString 加密后NSData，转换为base64字符串
- (nullable NSString *)jg_AES128EncryptStringWithKey:(NSString *)key iv:(nullable NSString *)iv;

/// AES256加密后NSData，CBC / PKCS7Padding，加密入参为原始NSData
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @return NSData 加密后NSData，不可转换为UTF8字符串，可转换为base64字符串
- (nullable NSData *)jg_AES256EncryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

/// AES256加密后NSData，CBC / PKCS7Padding，加密入参为原始NSData
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @return NSString 加密后NSData转换为base64字符串
- (nullable NSString *)jg_AES256EncryptStringWithKey:(NSString *)key iv:(nullable NSString *)iv;

#pragma mark - Decrypt
/// AES128解密，CBC / PKCS7Padding，解密入参为原始NSData
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @return NSData 解密获取的原始NSData
- (nullable NSData *)jg_AES128DecryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

/// AES128解密，CBC / PKCS7Padding，解密入参为原始NSData
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @return NSString 解密获取的原始NSData转换为UTF8字符串
- (nullable NSString *)jg_AES128DecryptStringWithKey:(NSString *)key iv:(nullable NSString *)iv;

/// AES256解密，CBC / PKCS7Padding，解密入参为原始NSData
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @return NSData 解密获取的原始NSData
- (nullable NSData *)jg_AES256DecryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

/// AES256解密，CBC / PKCS7Padding，解密入参为原始NSData
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @return NSString 解密获取的原始NSData转换为UTF8字符串
- (nullable NSString *)jg_AES256DecryptStringWithKey:(NSString *)key iv:(nullable NSString *)iv;

#pragma mark - Operation
/// AES加解密，iOS只有CBC和ECB模式，加密入参为原始NSData，解密入参为加密后NSData
/// @param operation kCCEncrypt - 加密，kCCDecrypt - 解密
/// @param keyLength  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param key 加解密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @param options 加密模式以及填充模式，默认加密模式为CBC-需要IV，可选ECB-不需要IV，填充模式PKCS7
/// @return NSData 加密结果为NSData，不可转换为UTF8字符串，可转换为base64字符串；解密结果为原始NSData
- (nullable NSData *)jg_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(nullable NSString *)iv options:(CCOptions)options;

/// AES加解密，iOS只有CBC和ECB模式，加密入参为原始NSData，解密入参为加密后NSData
/// @param operation kCCEncrypt - 加密，kCCDecrypt - 解密
/// @param keyLength  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param key 加解密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @param options 加密模式以及填充模式，默认加密模式为CBC-需要IV，可选ECB-不需要IV，填充模式PKCS7
/// @return NSString 加密结果为NSData转换为base64字符串；解密结果为原始NSData转换为UTF8字符串
- (nullable NSString *)jg_AESStringWithOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(nullable NSString *)iv options:(CCOptions)options;

/// AES加解密，CBC / PKCS7Padding，加密入参为原始NSData，解密入参为加密后NSData
/// @param operation kCCEncrypt - 加密，kCCDecrypt - 解密
/// @param keyLength  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param key 加解密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @return NSData 加密结果为NSData，不可转换为UTF8字符串，可转换为base64字符串；解密结果为原始NSData
- (nullable NSData *)jg_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(nullable NSString *)iv;

/// AES加解密，CBC / PKCS7Padding，加密入参为原始NSData，解密入参为加密后NSData
/// @param operation kCCEncrypt - 加密，kCCDecrypt - 解密
/// @param keyLength  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param key 加解密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @return NSString 加密结果为NSData转换为base64字符串；解密结果为原始NSData转换为UTF8字符串
- (nullable NSString *)jg_AESStringWithOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(nullable NSString *)iv;

@end

NS_ASSUME_NONNULL_END
