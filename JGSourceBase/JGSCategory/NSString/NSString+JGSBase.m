//
//  NSString+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/3/10.
//  Copyright © 2021 MeiJiGao. All rights reserved.
//

#import "NSString+JGSBase.h"
#import "JGSCategory+NSData.h"
#import "JGSBase+Private.h"

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
    return [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (NSString *)jg_base64DecodeString {
    
    NSData *data = [self jg_base64DecodeData];
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

#pragma mark - Hex
- (NSString *)jg_hexString {
    return [self jg_hexString:JGSStringCaseDefault];
}

- (NSString *)jg_hexString:(JGSStringUpperLowerStyle)style {
    
    NSData *hexData = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (hexData.length == 0) {
        return nil;
    }
    
    return [hexData jg_hexString:style];
}

- (NSString *)jg_hexToString {
    NSData *hexData = [self jg_hexToData];
    return [[NSString alloc] initWithData:hexData encoding:NSUTF8StringEncoding];
}

- (NSData *)jg_hexToData {
    
    if (self.length == 0) {
        return nil;
    }
    
    // 移除0x头
    NSString *lowerCase = self.lowercaseString;
    if ([lowerCase hasPrefix:@"0x"]) {
        lowerCase = [lowerCase substringFromIndex:2];
    }
    
    size_t byteLen = ceil(lowerCase.length / 2.0);
    Byte *bytes = malloc(byteLen + 1);
    bzero(bytes, byteLen + 1);
    
    NSRange range = NSMakeRange(0, lowerCase.length % 2 == 0 ? 2 : 1);
    for (NSInteger i = range.location; i < lowerCase.length; i += 2) {
        
        unsigned int anInt;
        NSString *hexChar = [lowerCase substringWithRange:range];
        NSScanner *scanner = [NSScanner scannerWithString:hexChar];
        [scanner scanHexInt:&anInt];
        bytes[i / 2] = anInt;
        
        range.location += range.length;
        range.length = 2;
    }
    
    NSData *hexData = [NSData dataWithBytes:bytes length:byteLen];
    free(bytes);
    
    return hexData;
}

#pragma mark - End

@end
