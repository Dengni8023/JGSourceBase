//
//  JGSAESEncryption.h
//  JGSourceBase
//
//  Created by 梅继高 on 2021/9/27.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGSAESEncryption : NSObject

#pragma mark - Encrypt
/// AES128加密后Base64字符串，CBC / PKCS7Padding
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致： kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSString *)jg_AES128EncryptString:(nullable NSString *)string key:(NSString *)key iv:(nullable NSString *)iv;
- (nullable NSData *)jg_AES128EncryptData:(nullable NSData *)data key:(NSString *)key iv:(nullable NSString *)iv;

/// AES256加密后Base64字符串，CBC / PKCS7Padding
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSString *)jg_AES256EncryptString:(nullable NSString *)string key:(NSString *)key iv:(nullable NSString *)iv;
- (nullable NSData *)jg_AES256EncryptData:(nullable NSData *)data key:(NSString *)key iv:(nullable NSString *)iv;

#pragma mark - Decrypt
/// AES256解密，CBC / PKCS7Padding
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSString *)jg_AES128DecryptString:(nullable NSString *)string key:(NSString *)key iv:(nullable NSString *)iv;
- (nullable NSString *)jg_AES128DecryptData:(nullable NSData *)data key:(NSString *)key iv:(nullable NSString *)iv;

/// AES256解密，CBC / PKCS7Padding
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致： kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSString *)jg_AES256DecryptString:(nullable NSString *)string key:(NSString *)key iv:(nullable NSString *)iv;
- (nullable NSData *)jg_AES256DecryptData:(nullable NSData *)data key:(NSString *)key iv:(nullable NSString *)iv;

#pragma mark - Operation
/// AES加解密，iOS只有CBC和ECB模式
/// @param operation kCCEncrypt - 加密，kCCDecrypt - 解密
/// @param keyLength  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param key 加解密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致： kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @param options 加密模式以及填充模式，默认加密模式为CBC，可选ECB，填充模式PKCS7
- (nullable NSString *)jg_AESOperation:(CCOperation)operation string:(nullable NSString *)string keyLength:(size_t)keyLength key:(NSString *)key iv:(nullable NSString *)iv options:(CCOptions)options;
- (nullable NSData *)jg_AESOperation:(CCOperation)operation data:(nullable NSData *)data keyLength:(size_t)keyLength key:(NSString *)key iv:(nullable NSString *)iv options:(CCOptions)options;

/// AES加解密，CBC / PKCS7Padding
/// @param operation kCCEncrypt - 加密，kCCDecrypt - 解密
/// @param keyLength  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param key 加解密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致： kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSString *)jg_AESOperation:(CCOperation)operation string:(nullable NSString *)string keyLength:(size_t)keyLength key:(NSString *)key iv:(nullable NSString *)iv;
- (nullable NSData *)jg_AESOperation:(CCOperation)operation data:(nullable NSData *)data keyLength:(size_t)keyLength key:(NSString *)key iv:(nullable NSString *)iv;

@end

@interface NSData (JGSAESEncryption)

#pragma mark - Encrypt
/// AES128加密，CBC / PKCS7Padding
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致： kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSData *)jg_AES128EncryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

/// AES256加密，CBC / PKCS7Padding
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSData *)jg_AES256EncryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

#pragma mark - Decrypt
/// AES256解密，CBC / PKCS7Padding
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSData *)jg_AES128DecryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

/// AES256解密，CBC / PKCS7Padding
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致： kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSData *)jg_AES256DecryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

#pragma mark - Operation
/// AES加解密，iOS只有CBC和ECB模式
/// @param operation kCCEncrypt - 加密，kCCDecrypt - 解密
/// @param keyLength  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param key 加解密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致： kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @param options 加密模式以及填充模式，默认加密模式为CBC，可选ECB，填充模式PKCS7
- (nullable NSData *)jg_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(nullable NSString *)iv options:(CCOptions)options;

/// AES加解密，CBC / PKCS7Padding
/// @param operation kCCEncrypt - 加密，kCCDecrypt - 解密
/// @param keyLength  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param key 加解密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致： kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSData *)jg_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(nullable NSString *)iv;

@end

@interface NSString (JGSAESEncryption)

#pragma mark - Encrypt
/// AES128加密后Base64字符串，CBC / PKCS7Padding
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致： kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSString *)jg_AES128EncryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

/// AES256加密后Base64字符串，CBC / PKCS7Padding
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSString *)jg_AES256EncryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

#pragma mark - Decrypt
/// AES256解密，CBC / PKCS7Padding
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSString *)jg_AES128DecryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

/// AES256解密，CBC / PKCS7Padding
/// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致： kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSString *)jg_AES256DecryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

#pragma mark - Operation
/// AES加解密，iOS只有CBC和ECB模式
/// @param operation kCCEncrypt - 加密，kCCDecrypt - 解密
/// @param keyLength  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param key 加解密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致： kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
/// @param options 加密模式以及填充模式，默认加密模式为CBC，可选ECB，填充模式PKCS7
- (nullable NSString *)jg_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(nullable NSString *)iv options:(CCOptions)options;

/// AES加解密，CBC / PKCS7Padding
/// @param operation kCCEncrypt - 加密，kCCDecrypt - 解密
/// @param keyLength  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param key 加解密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致： kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
/// @param iv 偏移向量，可为空
- (nullable NSString *)jg_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(nullable NSString *)iv;

@end

NS_ASSUME_NONNULL_END
