//
//  NSData+JGSAES.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/5/26.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "NSData+JGSAES.h"
#import "NSData+JGSBase.h"

@implementation NSData (JGSAES)

#pragma mark - Encrypt
- (NSData *)jg_AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCEncrypt keyLength:kCCKeySizeAES128 key:key iv:iv];
}

- (NSString *)jg_AES128EncryptStringWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESStringWithOperation:kCCEncrypt keyLength:kCCKeySizeAES128 key:key iv:iv];
}

- (NSData *)jg_AES256EncryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCEncrypt keyLength:kCCKeySizeAES256 key:key iv:iv];
}

- (NSString *)jg_AES256EncryptStringWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESStringWithOperation:kCCEncrypt keyLength:kCCKeySizeAES256 key:key iv:iv];
}

#pragma mark - Decrypt
- (NSData *)jg_AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCDecrypt keyLength:kCCKeySizeAES128 key:key iv:iv];
}

- (NSString *)jg_AES128DecryptStringWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESStringWithOperation:kCCDecrypt keyLength:kCCKeySizeAES128 key:key iv:iv];
}

- (NSData *)jg_AES256DecryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCDecrypt keyLength:kCCKeySizeAES256 key:key iv:iv];
}

- (NSString *)jg_AES256DecryptStringWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESStringWithOperation:kCCDecrypt keyLength:kCCKeySizeAES256 key:key iv:iv];
}

#pragma mark - Operation
- (NSData *)jg_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options {
    if (self == nil) {
        return nil;
    }

    if (options == kNilOptions) {
        options = kCCOptionPKCS7Padding;
    }

    NSCAssert(keyLength == kCCKeySizeAES128 || keyLength == kCCKeySizeAES192 || keyLength == kCCKeySizeAES256, @"The keyLength of AES must be (%@、%@、%@)", @(kCCKeySizeAES128), @(kCCKeySizeAES192), @(kCCKeySizeAES256));
    NSCAssert(operation == kCCEncrypt || operation == kCCDecrypt, @"The operation of AES must be (%@、%@)", @(kCCEncrypt), @(kCCDecrypt));
    NSCAssert(key.length == keyLength, @"The key length of AES-%@ must be %@", @(keyLength * 8), @(keyLength));

    if (options & kCCOptionECBMode) {
        // 屏蔽ECB校验IV，系统能够正常加解密
        //NSCAssert(iv.length != 0, @"The AES-CBC mode must have iv params");
    }

    NSUInteger dataLength = self.length;
    void const *contentBytes = self.bytes;
    void const *keyBytes = [key dataUsingEncoding:NSUTF8StringEncoding].bytes;

    // 初始偏移向量，默认全置零，避免iv长度不符合规范情况导致无法解析
    // 便宜向量长度为块大小 BlockSize
    char ivBytes[kCCBlockSizeAES128 + 1];
    memset(ivBytes, 0, sizeof(ivBytes));

    if (iv.length > 0) {
        [iv getCString:ivBytes maxLength:sizeof(ivBytes) encoding:NSUTF8StringEncoding];
    }

    size_t operationSize = dataLength + kCCBlockSizeAES128;     // 密文长度 <= 明文长度 + BlockSize
    void *operationBytes = malloc(operationSize);

    if (operationBytes == NULL) {
        return nil;
    }

    size_t actualOutSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation, kCCAlgorithmAES, options, keyBytes, keyLength, ivBytes, contentBytes, dataLength, operationBytes, operationSize, &actualOutSize);

    if (cryptStatus == kCCSuccess) {
        // operationBytes 自动释放
        NSData *cryptData = [NSData dataWithBytesNoCopy:operationBytes length:actualOutSize];
        return cryptData;
    }

    free(operationBytes); operationBytes = NULL;

    return nil;
}

- (NSString *)jg_AESStringWithOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options {
    if (self.length == 0) {
        return nil;
    }

    if (operation == kCCEncrypt) {
        NSData *encryptData = [self jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:options];
        // 加密Data不能直接转UTF8字符串，需使用base64编码
        NSString *string = encryptData ? [encryptData jg_base64EncodeString] : nil;

        return string;
    } else if (operation == kCCDecrypt) {
        // 解密Data不能直接转UTF8字符串，需使用base64解码
        NSData *decryptData = [self jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:options];
        NSString *string = decryptData ? [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding] : nil;

        return string;
    }

    return nil;
}

- (NSData *)jg_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:kNilOptions];
}

- (NSString *)jg_AESStringWithOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESStringWithOperation:operation keyLength:keyLength key:key iv:iv options:kNilOptions];
}

#pragma mark - End

@end
