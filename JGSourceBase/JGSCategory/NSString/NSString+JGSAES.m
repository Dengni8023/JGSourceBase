//
//  NSString+JGSAES.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/5/26.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "NSString+JGSAES.h"
#import "JGSCategory+NSData.h"
#import "NSString+JGSBase.h"

@implementation NSString (JGSAES)

#pragma mark - Encrypt
- (NSString *)jg_AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCEncrypt keyLength:kCCKeySizeAES128 key:key iv:iv];
}

- (NSData *)jg_AES128EncryptDataWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESDataWithOperation:kCCEncrypt keyLength:kCCKeySizeAES128 key:key iv:iv];
}

- (NSString *)jg_AES256EncryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCEncrypt keyLength:kCCKeySizeAES256 key:key iv:iv];
}

- (NSData *)jg_AES256EncryptDataWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESDataWithOperation:kCCEncrypt keyLength:kCCKeySizeAES256 key:key iv:iv];
}

#pragma mark - Decrypt
- (NSString *)jg_AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCDecrypt keyLength:kCCKeySizeAES128 key:key iv:iv];
}

- (NSData *)jg_AES128DecryptDataWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESDataWithOperation:kCCDecrypt keyLength:kCCKeySizeAES128 key:key iv:iv];
}

- (NSString *)jg_AES256DecryptWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:kCCDecrypt keyLength:kCCKeySizeAES256 key:key iv:iv];
}

- (NSData *)jg_AES256DecryptDataWithKey:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESDataWithOperation:kCCDecrypt keyLength:kCCKeySizeAES256 key:key iv:iv];
}

#pragma mark - Operation
- (NSString *)jg_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options {
    if (self.length == 0) {
        return nil;
    }

    NSData *operationData = [self jg_AESDataWithOperation:operation keyLength:keyLength key:key iv:iv options:options];

    if (operation == kCCEncrypt) {
        // 加密Data不能直接转UTF8字符串，需使用base64编码
        NSString *string = operationData ? [operationData jg_base64EncodeString] : nil;
        return string;
    } else if (operation == kCCDecrypt) {
        NSString *string = operationData ? [[NSString alloc] initWithData:operationData encoding:NSUTF8StringEncoding] : nil;

        return string;
    }

    return nil;
}

- (NSData *)jg_AESDataWithOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options {
    if (self.length == 0) {
        return nil;
    }

    if (operation == kCCEncrypt) {
        NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
        NSData *encryptData = [data jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:options];
        return encryptData;
    } else if (operation == kCCDecrypt) {
        // 解密Data不能直接转UTF8字符串，需使用base64解码
        NSData *data = [self jg_base64DecodeData];
        NSData *decryptData = [data jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:options];
        return decryptData;
    }

    return nil;
}

- (NSString *)jg_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:kNilOptions];
}

- (NSData *)jg_AESDataWithOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv {
    return [self jg_AESDataWithOperation:operation keyLength:keyLength key:key iv:iv options:kNilOptions];
}

#pragma mark - End

@end
