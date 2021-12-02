//
//  JGSAESEncryption.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/9/27.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import "JGSAESEncryption.h"

@implementation JGSAESEncryption

#pragma mark - Encrypt
- (NSString *)jg_AES128EncryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv {
    return [string jg_AES128EncryptWithKey:key iv:iv];
}

- (NSData *)jg_AES128EncryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    return [data jg_AES128EncryptWithKey:key iv:iv];
}

- (NSString *)jg_AES256EncryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv {
    return [string jg_AES256EncryptWithKey:key iv:iv];
}

- (NSData *)jg_AES256EncryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    return [data jg_AES256EncryptWithKey:key iv:iv];
}

#pragma mark - Decrypt
- (NSString *)jg_AES128DecryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv {
    return [string jg_AES128DecryptWithKey:key iv:iv];
}

- (NSData *)jg_AES128DecryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    return [data jg_AES128DecryptWithKey:key iv:iv];
}

- (NSString *)jg_AES256DecryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv {
    return [string jg_AES256DecryptWithKey:key iv:iv];
}

- (NSData *)jg_AES256DecryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    return [data jg_AES256DecryptWithKey:key iv:iv];
}

#pragma mark - Operation
- (NSString *)jg_AESOperation:(CCOperation)operation string:(NSString *)string keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options {
    return [string jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:options];
}

- (NSData *)jg_AESOperation:(CCOperation)operation data:(NSData *)data keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options {
    return [data jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:options];
}

- (NSString *)jg_AESOperation:(CCOperation)operation string:(NSString *)string keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv {
    return [string jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:(kCCOptionPKCS7Padding)];
}

- (NSData *)jg_AESOperation:(CCOperation)operation data:(NSData *)data keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv  {
    return [data jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:(kCCOptionPKCS7Padding)];
}

#pragma mark - End

@end

@implementation NSData (JGSAESEncryption)

#pragma mark - Encrypt
- (NSData *)jg_AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCEncrypt keyLength:kCCKeySizeAES128 key:key iv:iv];
}

- (NSData *)jg_AES256EncryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCEncrypt keyLength:kCCKeySizeAES256 key:key iv:iv];
}

#pragma mark - Decrypt
- (NSData *)jg_AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCDecrypt keyLength:kCCKeySizeAES128 key:key iv:iv];
}

- (NSData *)jg_AES256DecryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCDecrypt keyLength:kCCKeySizeAES256 key:key iv:iv];
}

#pragma mark - Operation
- (NSData *)jg_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options {
    
    if (self == nil) {
        return nil;
    }
    
    NSCAssert(keyLength == kCCKeySizeAES128 || keyLength == kCCKeySizeAES192 || keyLength == kCCKeySizeAES256, @"The keyLength of AES must be (%@、%@、%@)", @(kCCKeySizeAES128), @(kCCKeySizeAES192), @(kCCKeySizeAES256));
    NSCAssert(operation == kCCEncrypt || operation == kCCDecrypt, @"The operation of AES must be (%@、%@)", @(kCCEncrypt), @(kCCDecrypt));
    NSCAssert(key.length == keyLength, @"The key length of AES-%@ must be %@", @(keyLength * 8), @(keyLength));
    
    NSUInteger dataLength = self.length;
    void const *contentBytes = self.bytes;
    void const *keyBytes = [key dataUsingEncoding:NSUTF8StringEncoding].bytes;
    
    // 初始偏移向量，默认全置零，避免iv长度不符合规范情况导致无法解析
    // 便宜向量长度为块大小 BlockSize
    char ivBytes[kCCBlockSizeAES128 + 1];
    memset(ivBytes, 0, sizeof(ivBytes));
    [iv getCString:ivBytes maxLength:sizeof(ivBytes) encoding:NSUTF8StringEncoding];
    
    size_t operationSize = dataLength + kCCBlockSizeAES128; // 密文长度 <= 明文长度 + BlockSize
    void *operationBytes = malloc(operationSize);
    if (operationBytes == NULL) {
        return nil;
    }
    
    size_t actualOutSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation, kCCAlgorithmAES, options, keyBytes, keyLength, ivBytes, contentBytes, dataLength, operationBytes, operationSize, &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        // operationBytes 自动释放
        return [NSData dataWithBytesNoCopy:operationBytes length:actualOutSize];
    }
    
    free(operationBytes); operationBytes = NULL;
    
    return nil;
}

- (NSData *)jg_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:(kCCOptionPKCS7Padding)];
}

#pragma mark - End

@end

@implementation NSString (JGSAESEncryption)

#pragma mark - Encrypt
- (NSString *)jg_AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCEncrypt keyLength:kCCKeySizeAES128 key:key iv:iv];
}

- (NSString *)jg_AES256EncryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCEncrypt keyLength:kCCKeySizeAES256 key:key iv:iv];
}

#pragma mark - Decrypt
- (NSString *)jg_AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCDecrypt keyLength:kCCKeySizeAES128 key:key iv:iv];
}

- (NSString *)jg_AES256DecryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCDecrypt keyLength:kCCKeySizeAES256 key:key iv:iv];
}

#pragma mark - Operation
- (NSString *)jg_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options {
    
    if (self == nil) {
        return nil;
    }
    
    if (operation == kCCEncrypt) {
        
        NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
        NSData *encryptData = [data jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:options];
        
        // 加密Data不能直接转UTF8字符串，需使用base64编码
        // 选择NSDataBase64EncodingEndLineWithLineFeed保持Android、ios、后台统一
        NSString *string = encryptData ? [encryptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed] : nil;
        
        return string;
    }
    else if (operation == kCCDecrypt) {
        
        // 解密Data不能直接转UTF8字符串，需使用base64解码
        NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSData *decryptData = [data jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:options];
        NSString *string = decryptData ? [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding] : nil;
        
        return string;
    }
    
    return nil;
}

- (NSString *)jg_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:(kCCOptionPKCS7Padding)];
}

#pragma mark - End

@end
