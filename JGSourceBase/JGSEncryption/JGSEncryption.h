//
//  JGSEncryption.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#ifndef JGSEncryption_h
#define JGSEncryption_h

#import <Foundation/Foundation.h>
#if __has_include(<JGSourceBase/JGSEncryption.h>)
#import <JGSourceBase/JGSAESEncryption.h>
#import <JGSourceBase/JGSRSAEncryption.h>
#else
#import "JGSAESEncryption.h"
#import "JGSRSAEncryption.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface JGSEncryption : NSObject

#pragma mark - Base64
+ (nullable NSData *)base64EncodedDataWithData:(NSData *)data;
+ (nullable NSData *)base64EncodedDataWithString:(NSString *)string;

+ (nullable NSString *)base64EncodedStringWithData:(NSData *)data;
+ (nullable NSString *)base64EncodedStringWithString:(NSString *)string;

+ (nullable NSData *)dataWithBase64EncodedData:(NSData *)data;
+ (nullable NSData *)dataWithBase64EncodedString:(NSString *)string;

+ (nullable NSString *)stringWithBase64EncodedData:(NSData *)data;
+ (nullable NSString *)stringWithBase64EncodedString:(NSString *)string;

#pragma mark - File
+ (nullable NSString *)md5WithFile:(NSString *)filePath;
+ (nullable NSString *)sha128WithFile:(NSString *)filePath;
+ (nullable NSString *)sha256WithFile:(NSString *)filePath;

+ (nullable NSData *)aes128EncryptDataWithFile:(NSString *)filePath key:(NSString *)key iv:(NSString *)iv;
+ (nullable NSData *)aes128DecryptDataWithFile:(NSString *)filePath key:(NSString *)key iv:(NSString *)iv;

+ (nullable NSData *)aes256EncryptDataWithFile:(NSString *)filePath key:(NSString *)key iv:(NSString *)iv;
+ (nullable NSData *)aes256DecryptDataWithFile:(NSString *)filePath key:(NSString *)key iv:(NSString *)iv;

@end

NS_ASSUME_NONNULL_END

#endif /* JGSEncryption_h */
