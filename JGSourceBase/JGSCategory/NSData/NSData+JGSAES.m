//
//  NSData+JGSAES.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/5/26.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "NSData+JGSAES.h"

@implementation NSData (JGSAES)

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
