//
//  JGSAESEncryption.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSAESEncryption.h"
#import "NSData+JGSAES.h"
#import "NSString+JGSAES.h"

@implementation JGSAESEncryption

#pragma mark - Encrypt
- (NSString *)jg_AES128EncryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv {
    return [self aes128EncryptString:string key:key iv:iv];
}

- (NSString *)aes128EncryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv {
    return [string jg_AES128EncryptWithKey:key iv:iv];
}

- (NSData *)jg_AES128EncryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    return [self aes128EncryptData:data key:key iv:iv];
}

- (NSData *)aes128EncryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    return [data jg_AES128EncryptWithKey:key iv:iv];
}

- (NSString *)jg_AES256EncryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv {
    return [self aes256EncryptString:string key:key iv:iv];
}

- (NSString *)aes256EncryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv {
    return [string jg_AES256EncryptWithKey:key iv:iv];
}

- (NSData *)jg_AES256EncryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    return [self aes256EncryptData:data key:key iv:iv];
}

- (NSData *)aes256EncryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    return [data jg_AES256EncryptWithKey:key iv:iv];
}

#pragma mark - Decrypt
- (NSString *)jg_AES128DecryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv {
    return [self aes128DecryptString:string key:key iv:iv];
}

- (NSString *)aes128DecryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv {
    return [string jg_AES128DecryptWithKey:key iv:iv];
}

- (NSData *)jg_AES128DecryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    return [self aes128DecryptData:data key:key iv:iv];
}

- (NSData *)aes128DecryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    return [data jg_AES128DecryptWithKey:key iv:iv];
}

- (NSString *)jg_AES256DecryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv {
    return [self aes256DecryptString:string key:key iv:iv];
}

- (NSString *)aes256DecryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv {
    return [string jg_AES256DecryptWithKey:key iv:iv];
}

- (NSData *)jg_AES256DecryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    return [self aes256DecryptData:data key:key iv:iv];
}

- (NSData *)aes256DecryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    return [data jg_AES256DecryptWithKey:key iv:iv];
}

#pragma mark - Operation
- (NSString *)jg_AESOperation:(CCOperation)operation string:(NSString *)string keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options {
    return [self aesOperation:operation string:string keyLength:keyLength key:key iv:iv options:options];
}

- (NSString *)aesOperation:(CCOperation)operation string:(NSString *)string keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options {
    return [string jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:options];
}

- (NSData *)jg_AESOperation:(CCOperation)operation data:(NSData *)data keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options {
    return [self aesOperation:operation data:data keyLength:keyLength key:key iv:iv options:options];
}

- (NSData *)aesOperation:(CCOperation)operation data:(NSData *)data keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options {
    return [data jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:options];
}

- (NSString *)jg_AESOperation:(CCOperation)operation string:(NSString *)string keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv {
    return [self aesOperation:operation string:string keyLength:keyLength key:key iv:iv];
}

- (NSString *)aesOperation:(CCOperation)operation string:(NSString *)string keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv {
    return [string jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:kNilOptions];
}

- (NSData *)jg_AESOperation:(CCOperation)operation data:(NSData *)data keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv  {
    return [self aesOperation:operation data:data keyLength:keyLength key:key iv:iv];
}

- (NSData *)aesOperation:(CCOperation)operation data:(NSData *)data keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv  {
    return [data jg_AESOperation:operation keyLength:keyLength key:key iv:iv options:kNilOptions];
}

#pragma mark - End

@end
