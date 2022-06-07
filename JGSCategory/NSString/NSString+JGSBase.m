//
//  NSString+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/3/10.
//  Copyright © 2021 MeiJiGao. All rights reserved.
//

#import "NSString+JGSBase.h"
#import "NSData+JGSBase.h"
#import "JGSBase+JGSPrivate.h"

@implementation NSString (JGSBase)

#pragma mark - Base64
- (NSData *)jg_base64EncodeData {
	
	// 选择NSDataBase64EncodingEndLineWithLineFeed保持Android、ios、后台统一
	NSData *data = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
	return [data base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (NSString *)jg_base64EncodeString {
	
	// 选择NSDataBase64EncodingEndLineWithLineFeed保持Android、ios、后台统一
	NSData *data = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
	return [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (NSData *)jg_base64DecodeData {
	
	NSData *data = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
	return data ? [[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters] : nil;
}

- (NSString *)jg_base64DecodeString {
	
	NSData *data = [[NSData alloc] initWithBase64EncodedString:(NSString *)self options:NSDataBase64DecodingIgnoreUnknownCharacters];
	return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

#pragma mark - HASH
- (NSString *)jg_md5String {
	return [self jg_md5String:JGSStringCaseDefault];
}

- (NSString *)jg_md5String:(JGSStringUpperLowerStyle)style {
	
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	return [data jg_md5String:style];
}

- (NSString *)jg_sha128String {
	return [self jg_sha128String:JGSStringCaseDefault];
}

- (NSString *)jg_sha128String:(JGSStringUpperLowerStyle)style {
	
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	return [data jg_sha128String:style];
}

- (NSString *)jg_sha256String {
	return [self jg_sha256String:JGSStringCaseDefault];
}

- (NSString *)jg_sha256String:(JGSStringUpperLowerStyle)style {
	
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	return [data jg_sha256String:style];
}

#pragma mark - End

@end
