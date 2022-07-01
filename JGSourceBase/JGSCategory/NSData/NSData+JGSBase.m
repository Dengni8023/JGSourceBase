//
//  NSData+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/5/26.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "NSData+JGSBase.h"
#import <CommonCrypto/CommonCrypto.h>
#import "JGSBase+JGSPrivate.h"

@implementation NSData (JGSBase)

#pragma mark - Base64
- (NSData *)jg_base64EncodeData {
	
	// 选择NSDataBase64EncodingEndLineWithLineFeed保持Android、ios、后台统一
	return [self base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (NSString *)jg_base64EncodeString {
	
	// 选择NSDataBase64EncodingEndLineWithLineFeed保持Android、ios、后台统一
	return [self base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (NSData *)jg_base64DecodeData {
	
	return [[NSData alloc] initWithBase64EncodedData:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (NSString *)jg_base64DecodeString {
	
	NSData *data = [[NSData alloc] initWithBase64EncodedData:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
	return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

#pragma mark - HASH
- (NSString *)jg_md5String {
	return [self jg_md5String:JGSStringCaseDefault];
}

- (NSString *)jg_md5String:(JGSStringUpperLowerStyle)style {
	
	int secLen = CC_MD5_DIGEST_LENGTH;
	const char *cStr = [self bytes];
	unsigned char digest[secLen];
    
    // FIX: NSData获取byte之后bytes长度可能比data长度长，因此此处不能使用strlen(cStr)
	CC_MD5(cStr, (CC_LONG)self.length, digest);
	
	NSMutableString *result = [NSMutableString stringWithCapacity:secLen * 2];
	for (int i = 0; i < secLen; i++) {
		[result appendFormat:(arc4random() % 2 == 0) ? @"%02X" : @"%02x", digest[i]];
	}
	
	style = MIN(JGSStringLowercase, MAX(JGSStringRandomCase, style));
	switch (style) {
		case JGSStringLowercase:
			return result.lowercaseString;
			break;
			
		case JGSStringUppercase:
			return result.uppercaseString;
			break;
			
		case JGSStringRandomCase:
			return result;
			break;
	}
}

- (NSString *)jg_sha128String {
	return [self jg_sha128String:JGSStringCaseDefault];
}

- (NSString *)jg_sha128String:(JGSStringUpperLowerStyle)style {
	
	int secLen = CC_SHA1_DIGEST_LENGTH;
	const char *cStr = [self bytes];
	unsigned char digest[secLen];
    
    // FIX: NSData获取byte之后bytes长度可能比data长度长，因此此处不能使用strlen(cStr)
	CC_SHA1(cStr, (CC_LONG)self.length, digest);
	
	NSMutableString *result = [NSMutableString stringWithCapacity:secLen * 2];
	for (int i = 0; i < secLen; i++) {
		[result appendFormat:(arc4random() % 2 == 0) ? @"%02X" : @"%02x", digest[i]];
	}
	
	style = MIN(JGSStringLowercase, MAX(JGSStringRandomCase, style));
	switch (style) {
		case JGSStringLowercase:
			return result.lowercaseString;
			break;
			
		case JGSStringUppercase:
			return result.uppercaseString;
			break;
			
		case JGSStringRandomCase:
			return result;
			break;
	}
}

- (NSString *)jg_sha256String {
	return [self jg_sha256String:JGSStringCaseDefault];
}

- (NSString *)jg_sha256String:(JGSStringUpperLowerStyle)style {
	
	int secLen = CC_SHA256_DIGEST_LENGTH;
	const char *cStr = [self bytes];
	unsigned char digest[secLen];
    
    // FIX: NSData获取byte之后bytes长度可能比data长度长，因此此处不能使用strlen(cStr)
	CC_SHA256(cStr, (CC_LONG)self.length, digest);
	
	NSMutableString *result = [NSMutableString stringWithCapacity:secLen * 2];
	for (int i = 0; i < secLen; i++) {
		[result appendFormat:(arc4random() % 2 == 0) ? @"%02X" : @"%02x", digest[i]];
	}
	
	style = MIN(JGSStringLowercase, MAX(JGSStringRandomCase, style));
	switch (style) {
		case JGSStringLowercase:
			return result.lowercaseString;
			break;
			
		case JGSStringUppercase:
			return result.uppercaseString;
			break;
			
		case JGSStringRandomCase:
			return result;
			break;
	}
}

- (NSString *)jg_sha384String {
    return [self jg_sha384String:JGSStringCaseDefault];
}

- (NSString *)jg_sha384String:(JGSStringUpperLowerStyle)style {
    
    int secLen = CC_SHA384_DIGEST_LENGTH;
    const char *cStr = [self bytes];
    unsigned char digest[secLen];
    
    // FIX: NSData获取byte之后bytes长度可能比data长度长，因此此处不能使用strlen(cStr)
    CC_SHA384(cStr, (CC_LONG)self.length, digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:secLen * 2];
    for (int i = 0; i < secLen; i++) {
        [result appendFormat:(arc4random() % 2 == 0) ? @"%02X" : @"%02x", digest[i]];
    }
    
    style = MIN(JGSStringLowercase, MAX(JGSStringRandomCase, style));
    switch (style) {
        case JGSStringLowercase:
            return result.lowercaseString;
            break;
            
        case JGSStringUppercase:
            return result.uppercaseString;
            break;
            
        case JGSStringRandomCase:
            return result;
            break;
    }
}

- (NSString *)jg_sha512String {
    return [self jg_sha512String:JGSStringCaseDefault];
}

- (NSString *)jg_sha512String:(JGSStringUpperLowerStyle)style {
    
    int secLen = CC_SHA512_DIGEST_LENGTH;
    const char *cStr = [self bytes];
    unsigned char digest[secLen];
    
    // FIX: NSData获取byte之后bytes长度可能比data长度长，因此此处不能使用strlen(cStr)
    CC_SHA512(cStr, (CC_LONG)self.length, digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:secLen * 2];
    for (int i = 0; i < secLen; i++) {
        [result appendFormat:(arc4random() % 2 == 0) ? @"%02X" : @"%02x", digest[i]];
    }
    
    style = MIN(JGSStringLowercase, MAX(JGSStringRandomCase, style));
    switch (style) {
        case JGSStringLowercase:
            return result.lowercaseString;
            break;
            
        case JGSStringUppercase:
            return result.uppercaseString;
            break;
            
        case JGSStringRandomCase:
            return result;
            break;
    }
}

#pragma mark - End

@end
