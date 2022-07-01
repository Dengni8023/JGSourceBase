//
//  NSString+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/3/10.
//  Copyright © 2021 MeiJiGao. All rights reserved.
//

#import "NSString+JGSBase.h"
#import "JGSCategory+NSData.h"
#import "JGSBase+JGSPrivate.h"

@implementation NSString (JGSBase)

#pragma mark - Base64
- (NSData *)jg_base64EncodeData {
	
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	return [data jg_base64EncodeData];
}

- (NSString *)jg_base64EncodeString {
	
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	return [data jg_base64EncodeString];
}

- (NSData *)jg_base64DecodeData {
	
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	return data ? [[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters] : nil;
}

- (NSString *)jg_base64DecodeString {
	
	NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
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

- (NSString *)jg_sha384String {
    return [self jg_sha384String:JGSStringCaseDefault];
}

- (NSString *)jg_sha384String:(JGSStringUpperLowerStyle)style {
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data jg_sha384String:style];
}

- (NSString *)jg_sha512String {
    return [self jg_sha512String:JGSStringCaseDefault];
}

- (NSString *)jg_sha512String:(JGSStringUpperLowerStyle)style {
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data jg_sha512String:style];
}

#pragma mark - End

@end
