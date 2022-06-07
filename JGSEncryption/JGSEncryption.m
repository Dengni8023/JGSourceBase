//
//  JGSEncryption.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/5/30.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSEncryption.h"
#import "NSData+JGSBase.h"
#import "NSString+JGSBase.h"
#import "NSData+JGSAES.h"

@implementation JGSEncryption

#pragma mark - Base64
+ (NSData *)base64EncodedDataWithData:(NSData *)data {
	return data.length == 0 ? nil : [data jg_base64EncodeData];
}

+ (NSData *)base64EncodedDataWithString:(NSString *)string {
	return string.length == 0 ? nil : [string jg_base64EncodeData];
}

+ (NSString *)base64EncodedStringWithData:(NSData *)data {
	return data.length == 0 ? nil : [data jg_base64EncodeString];
}

+ (NSString *)base64EncodedStringWithString:(NSString *)string {
	return string.length == 0 ? nil : [string jg_base64EncodeString];
}

+ (NSData *)dataWithBase64EncodedData:(NSData *)data {
	return data.length == 0 ? nil : [data jg_base64DecodeData];
}

+ (NSData *)dataWithBase64EncodedString:(NSString *)string {
	return string.length == 0 ? nil : [string jg_base64DecodeData];
}

+ (NSString *)stringWithBase64EncodedData:(NSData *)data {
	return data.length == 0 ? nil : [data jg_base64DecodeString];
}

+ (NSString *)stringWithBase64EncodedString:(NSString *)string {
	return string.length == 0 ? nil : [string jg_base64DecodeString];
}

#pragma mark - File
+ (NSString *)md5WithFile:(NSString *)filePath {
	
	BOOL isDir = NO;
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] || isDir) {
		return nil;
	}
	
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	return [data jg_md5String];
}

+ (NSString *)sha128WithFile:(NSString *)filePath {
	
	BOOL isDir = NO;
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] || isDir) {
		return nil;
	}
	
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	return [data jg_sha128String];
}

+ (NSString *)sha256WithFile:(NSString *)filePath {
	
	BOOL isDir = NO;
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] || isDir) {
		return nil;
	}
	
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	return [data jg_sha256String];
}

+ (NSData *)aes128EncryptDataWithFile:(NSString *)filePath key:(NSString *)key iv:(NSString *)iv {
	
	BOOL isDir = NO;
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] || isDir) {
		return nil;
	}
	
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	return [data jg_AES128EncryptWithKey:key iv:iv];
}

+ (NSData *)aes128DecryptDataWithFile:(NSString *)filePath key:(NSString *)key iv:(NSString *)iv {
	
	BOOL isDir = NO;
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] || isDir) {
		return nil;
	}
	
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	return [data jg_AES128DecryptWithKey:key iv:iv];
}

+ (NSData *)aes256EncryptDataWithFile:(NSString *)filePath key:(NSString *)key iv:(NSString *)iv {
	
	BOOL isDir = NO;
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] || isDir) {
		return nil;
	}
	
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	return [data jg_AES256EncryptWithKey:key iv:iv];
}

+ (NSData *)aes256DecryptDataWithFile:(NSString *)filePath key:(NSString *)key iv:(NSString *)iv {
	
	BOOL isDir = NO;
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] || isDir) {
		return nil;
	}
	
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	return [data jg_AES256DecryptWithKey:key iv:iv];
}

@end
