//
//  NSString+JGSAES.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/5/26.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "NSString+JGSAES.h"
#import "JGSCategory+NSData.h"
#import "JGSCategory+NSData.h"

@implementation NSString (JGSAES)

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
		NSString *string = encryptData ? [encryptData jg_base64EncodeString] : nil;
		
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
