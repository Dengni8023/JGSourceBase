//
//  NSData+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/5/26.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "NSData+JGSBase.h"
#import <CommonCrypto/CommonCrypto.h>
#import "JGSBase+Private.h"

@implementation NSData (JGSBase)

- (NSString *)jg_utf8String {
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

#pragma mark - Base64
- (NSData *)jg_base64EncodeData {
    return  [self jg_base64EncodeData:kNilOptions];
}

- (NSData *)jg_base64EncodeData:(NSDataBase64EncodingOptions)options {
    return [self base64EncodedDataWithOptions:options];
}

- (NSString *)jg_base64EncodeString {
    return [self jg_base64EncodeString:kNilOptions];
}

- (NSString *)jg_base64EncodeString:(NSDataBase64EncodingOptions)options {
    return [self base64EncodedStringWithOptions:options];
}

- (NSData *)jg_base64DecodeData {
    return [self jg_base64DecodeData:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (NSData *)jg_base64DecodeData:(NSDataBase64DecodingOptions)options {
    return [[NSData alloc] initWithBase64EncodedData:self options:options];
}

- (NSString *)jg_base64DecodeString {
    return [self jg_base64DecodeString:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (NSString *)jg_base64DecodeString:(NSDataBase64DecodingOptions)options {
    return [[self jg_base64DecodeData:options] jg_utf8String];
}

#pragma mark - MD5
- (NSString *)jg_md5String {
    return [self jg_md5];
}

- (NSString *)jg_md5String:(JGSStringCaseStyle)style {
    return [self jg_md5:style];
}

- (NSString *)jg_md5 {
    return [self jg_md5:JGSStringCaseDefault];
}

- (NSString *)jg_md5:(JGSStringCaseStyle)style {
    return [self jg_hash:JGSHASHStringMd5 style:style];
}

#pragma mark - SHA128
- (NSString *)jg_sha128String {
    return [self jg_sha128];
}

- (NSString *)jg_sha128String:(JGSStringCaseStyle)style {
    return [self jg_sha128:style];
}

- (NSString *)jg_sha128 {
    return [self jg_sha128:JGSStringCaseDefault];
}

- (NSString *)jg_sha128:(JGSStringCaseStyle)style {
    return [self jg_hash:JGSHASHStringSHA128 style:style];
}

#pragma mark - SHA256
- (NSString *)jg_sha256String {
    return [self jg_sha256];
}

- (NSString *)jg_sha256String:(JGSStringCaseStyle)style {
    return [self jg_sha256:style];
}

- (NSString *)jg_sha256 {
    return [self jg_sha256:JGSStringCaseDefault];
}

- (NSString *)jg_sha256:(JGSStringCaseStyle)style {
    return [self jg_hash:JGSHASHStringSHA256 style:style];
}

#pragma mark - SHA384
- (NSString *)jg_sha384String {
    return [self jg_sha384];
}

- (NSString *)jg_sha384String:(JGSStringCaseStyle)style {
    return [self jg_sha384:style];
}

- (NSString *)jg_sha384 {
    return [self jg_sha384:JGSStringCaseDefault];
}

- (NSString *)jg_sha384:(JGSStringCaseStyle)style {
    return [self jg_hash:JGSHASHStringSHA384 style:style];
}

#pragma mark - SHA512
- (NSString *)jg_sha512String {
    return [self jg_sha512];
}

- (NSString *)jg_sha512String:(JGSStringCaseStyle)style {
    return [self jg_sha512:style];
}

- (NSString *)jg_sha512 {
    return [self jg_sha512:JGSStringCaseDefault];
}

- (NSString *)jg_sha512:(JGSStringCaseStyle)style {
    return [self jg_hash:JGSHASHStringSHA512 style:style];
}

#pragma mark - HASH
- (NSString *)jg_hash:(JGSHASHStringType)type style:(JGSStringCaseStyle)style {
    int secLen = CC_SHA512_DIGEST_LENGTH;
    switch (type) {
        case JGSHASHStringMd5:
            secLen = CC_MD5_DIGEST_LENGTH;
            break;
            
        case JGSHASHStringSHA128:
            secLen = CC_SHA1_DIGEST_LENGTH;
            break;
            
        case JGSHASHStringSHA256:
            secLen = CC_SHA256_DIGEST_LENGTH;
            break;
            
        case JGSHASHStringSHA384:
            secLen = CC_SHA384_DIGEST_LENGTH;
            break;
            
        case JGSHASHStringSHA512:
            secLen = CC_SHA512_DIGEST_LENGTH;
            break;
    }
    const char *cStr = [self bytes];
    unsigned char digest[secLen];
    
    // FIX: NSData获取byte之后bytes长度可能比data长度长，因此此处不能使用strlen(cStr)
    switch (type) {
        case JGSHASHStringMd5:
            CC_MD5(cStr, (CC_LONG)self.length, digest);
            break;
            
        case JGSHASHStringSHA128:
            CC_SHA1(cStr, (CC_LONG)self.length, digest);
            break;
            
        case JGSHASHStringSHA256:
            CC_SHA256(cStr, (CC_LONG)self.length, digest);
            break;
            
        case JGSHASHStringSHA384:
            CC_SHA384(cStr, (CC_LONG)self.length, digest);
            break;
            
        case JGSHASHStringSHA512:
            CC_SHA512(cStr, (CC_LONG)self.length, digest);
            break;
    }
    NSMutableString *result = [NSMutableString stringWithCapacity:secLen * 2];
    for (int i = 0; i < secLen; i++) {
        [result appendFormat:arc4random_uniform(2) < 1 ? @"%02hhx" : @"%02hhX", digest[i]];
    }
    
    style = MIN(MAX(JGSStringLowercase, style), JGSStringRandomCase);
    switch (style) {
        case JGSStringLowercase:
            return result.lowercaseString;
            
        case JGSStringUppercase:
            return result.uppercaseString;
            
        case JGSStringRandomCase:
            return result;
    }
}

#pragma mark - Hex
- (NSString *)jg_hexString {
    return [self jg_hex];
}

- (NSString *)jg_hexString:(JGSStringCaseStyle)style {
    return [self jg_hex:style];
}

- (NSString *)jg_hex {
    return [self jg_hex:JGSStringCaseDefault];
}

- (NSString *)jg_hex:(JGSStringCaseStyle)style {
    if (self.length == 0) {
        return @"";
    }
    
    NSMutableString *hex = [NSMutableString stringWithCapacity:self.length * 2];
    const char *bytes = [self bytes];
    for (NSInteger i = 0; i < self.length; i++) {
        NSString *byteStr = [NSString stringWithFormat:arc4random_uniform(2) < 1 ? @"%02x" : @"%02X", bytes[i]]; // 16进制
        [hex appendString:byteStr];
    }
    
    style = MIN(MAX(JGSStringLowercase, style), JGSStringRandomCase);
    switch (style) {
        case JGSStringLowercase:
            return hex.lowercaseString;
            
        case JGSStringUppercase:
            return hex.uppercaseString;
            
        case JGSStringRandomCase:
            return hex;
    }
}

#pragma mark - End

@end
