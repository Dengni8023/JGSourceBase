//
//  JGSCommonEncryption.h
//  JGSEncryption
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JGSBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface JGSCommonEncryption : NSObject

@end

@interface NSData (JGSCommonEncryption)

#pragma mark - Base64
@property (nonatomic, copy, readonly, nullable) NSData *jg_base64EncodeData;
@property (nonatomic, copy, readonly, nullable) NSString *jg_base64EncodeString;

@property (nonatomic, copy, readonly, nullable) NSData *jg_base64DecodeData;
@property (nonatomic, copy, readonly, nullable) NSString *jg_base64DecodeString;

#pragma mark - HASH
@property (nonatomic, copy, readonly, nullable) NSString *jg_md5String;
@property (nonatomic, copy, readonly, nullable) NSString *jg_sha128String;
@property (nonatomic, copy, readonly, nullable) NSString *jg_sha256String;

- (nullable NSString *)jg_md5String:(JGSStringUpperLowerStyle)style;
- (nullable NSString *)jg_sha128String:(JGSStringUpperLowerStyle)style;
- (nullable NSString *)jg_sha256String:(JGSStringUpperLowerStyle)style;

@end

@interface NSString (JGSCommonEncryption)

#pragma mark - Base64
@property (nonatomic, copy, readonly, nullable) NSData *jg_base64EncodeData;
@property (nonatomic, copy, readonly, nullable) NSString *jg_base64EncodeString;

@property (nonatomic, copy, readonly, nullable) NSData *jg_base64DecodeData;
@property (nonatomic, copy, readonly, nullable) NSString *jg_base64DecodeString;

#pragma mark - HASH
@property (nonatomic, copy, readonly, nullable) NSString *jg_md5String;
@property (nonatomic, copy, readonly, nullable) NSString *jg_sha128String;
@property (nonatomic, copy, readonly, nullable) NSString *jg_sha256String;

- (nullable NSString *)jg_md5String:(JGSStringUpperLowerStyle)style;
- (nullable NSString *)jg_sha128String:(JGSStringUpperLowerStyle)style;
- (nullable NSString *)jg_sha256String:(JGSStringUpperLowerStyle)style;

@end

NS_ASSUME_NONNULL_END
