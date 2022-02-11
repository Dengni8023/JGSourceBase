//
//  JGSCommonEncryption.m
//  JGSEncryption
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSCommonEncryption.h"
#import <CommonCrypto/CommonCrypto.h>
#import "JGSBase.h"

@implementation JGSCommonEncryption

@end

@implementation NSData (JGSCommonEncryption)

#pragma mark - Base64
- (NSData *)jg_base64EncodeData {
    
    // 选择NSDataBase64EncodingEndLineWithLineFeed保持Android、ios、后台统一
    return [(NSData *)self base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (NSString *)jg_base64EncodeString {
    
    // 选择NSDataBase64EncodingEndLineWithLineFeed保持Android、ios、后台统一
    return [(NSData *)self base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (NSData *)jg_base64DecodeData {
    
    return [[NSData alloc] initWithBase64EncodedData:(NSData *)self options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (NSString *)jg_base64DecodeString {
    
    NSData *data = [[NSData alloc] initWithBase64EncodedData:(NSData *)self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

#pragma mark - HASH
- (NSString *)jg_md5String {
    return [self jg_md5String:JGSStringRandom];
}

- (NSString *)jg_md5String:(JGSStringUpperLowerStyle)style {
    
    int secLen = CC_MD5_DIGEST_LENGTH;
    const char *cStr = [self bytes];
    unsigned char digest[secLen];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:secLen * 2];
    for (int i = 0; i < secLen; i++) {
        [result appendFormat:(arc4random() % 2 == 0) ? @"%02X" : @"%02x", digest[i]];
    }
    
    style = MIN(JGSStringUppercase, MAX(JGSStringRandom, style));
    switch (style) {
        case JGSStringLowercase:
            return result.lowercaseString;
            break;
            
        case JGSStringUppercase:
            return result.uppercaseString;
            break;
            
        case JGSStringRandom:
            return result;
            break;
    }
}

- (NSString *)jg_sha128String {
    return [self jg_sha128String:YES];
}

- (NSString *)jg_sha128String:(JGSStringUpperLowerStyle)style {
    
    int secLen = CC_SHA1_DIGEST_LENGTH;
    const char *cStr = [self bytes];
    unsigned char digest[secLen];
    CC_SHA1(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:secLen * 2];
    for (int i = 0; i < secLen; i++) {
        [result appendFormat:(arc4random() % 2 == 0) ? @"%02X" : @"%02x", digest[i]];
    }
    
    style = MIN(JGSStringUppercase, MAX(JGSStringRandom, style));
    switch (style) {
        case JGSStringLowercase:
            return result.lowercaseString;
            break;
            
        case JGSStringUppercase:
            return result.uppercaseString;
            break;
            
        case JGSStringRandom:
            return result;
            break;
    }
}

- (NSString *)jg_sha256String {
    return [self jg_sha256String:YES];
}

- (NSString *)jg_sha256String:(JGSStringUpperLowerStyle)style {
    
    int secLen = CC_SHA256_DIGEST_LENGTH;
    const char *cStr = [self bytes];
    unsigned char digest[secLen];
    CC_SHA256(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:secLen * 2];
    for (int i = 0; i < secLen; i++) {
        [result appendFormat:(arc4random() % 2 == 0) ? @"%02X" : @"%02x", digest[i]];
    }
    
    style = MIN(JGSStringUppercase, MAX(JGSStringRandom, style));
    switch (style) {
        case JGSStringLowercase:
            return result.lowercaseString;
            break;
            
        case JGSStringUppercase:
            return result.uppercaseString;
            break;
            
        case JGSStringRandom:
            return result;
            break;
    }
}

#pragma mark - End

@end


@implementation NSString (JGSCommonEncryption)

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
    return [self jg_md5String:JGSStringRandom];
}

- (NSString *)jg_md5String:(JGSStringUpperLowerStyle)style {
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data jg_md5String:style];
}

- (NSString *)jg_sha128String {
    return [self jg_sha128String:YES];
}

- (NSString *)jg_sha128String:(JGSStringUpperLowerStyle)style {
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data jg_sha128String:style];
}

- (NSString *)jg_sha256String {
    return [self jg_sha256String:YES];
}

- (NSString *)jg_sha256String:(JGSStringUpperLowerStyle)style {
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data jg_sha256String:style];
}

#pragma mark - End

@end
