//
//  JGSRSAEncryption.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSRSAEncryption.h"
#import "JGSBase+Private.h"
#import <Security/Security.h>
#import "NSData+JGSBase.h"
#import "NSString+JGSBase.h"

@implementation JGSRSAEncryption

#pragma mark - 加解密 - 公钥加密 & 私钥解密
+ (NSString *)encryptString:(NSString *)string publicKeyWithContentsOfFile:(NSString *)path {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length == 0 || path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return @"";
    }
    
    SecKeyRef keyRef = [self publicKeyRefCreateWithContentsOfFile:path];
    if (keyRef == NULL) {
        return @"";
    }
    
    data = [self encryptData:data publicKeyRef:keyRef];
    CFRelease(keyRef);
    
    NSString *encStr = [data jg_base64EncodeString] ?: @"";
    return encStr;
}

+ (NSString *)encryptString:(NSString *)string publicKey:(NSString *)publicKey {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length == 0 || publicKey.length == 0) {
        return @"";
    }
    
    SecKeyRef keyRef = [self publicKeyRefCreateWithContents:publicKey];
    if (keyRef == NULL) {
        return @"";
    }
    
    data = [self encryptData:data publicKeyRef:keyRef];
    CFRelease(keyRef);
    
    NSString *encStr = [data jg_base64EncodeString] ?: @"";
    return encStr;
}

+ (NSString *)decryptString:(NSString *)string privateKeyWithContentsOfFile:(NSString *)path password:(NSString *)password {
    
    if (string.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return @"";
    }
    
    NSData *data = [string jg_base64DecodeData];
    if (data.length == 0) {
        return @"";
    }
    
    SecKeyRef keyRef = [self privateKeyRefWithContentsOfFile:path password:password ?: @""];
    if (keyRef == NULL) {
        return @"";
    }
    
    data = [self decryptData:data privateKeyRef:keyRef];
    NSString *decStr = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"";
    
    return decStr;
}

+ (NSString *)decryptString:(NSString *)string privateKey:(NSString *)privateKey {
    
    if (string.length == 0 || privateKey.length == 0) {
        return @"";
    }
    
    NSData *data = [string jg_base64DecodeData];
    if (data.length == 0) {
        return @"";
    }
    
    SecKeyRef keyRef = [self privateKeyRefCreateWithContents:privateKey];
    if (keyRef == NULL) {
        return @"";
    }
    
    data = [self decryptData:data privateKeyRef:keyRef];
    CFRelease(keyRef);
    
    NSString *decStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return decStr;
}

#pragma mark - 签名验证 - 私钥签名 & 公钥验证
+ (NSString *)signatureString:(NSString *)string privateKeyWithContentsOfFile:(NSString *)path password:(NSString *)password digest:(JGSRSASignatureDigest)digest algorithm:(SecKeyAlgorithm)algorithm {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length == 0 || path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return @"";
    }
    
    SecKeyRef keyRef = [self privateKeyRefWithContentsOfFile:path password:password ?: @""];
    if (keyRef == NULL) {
        return @"";
    }
    
    data = [self signatureData:data privateKeyRef:keyRef digest:digest algorithm:algorithm];
    CFRelease(keyRef);
    
    NSString *encStr = [data jg_base64EncodeString] ?: @"";
    return encStr;
}

+ (NSString *)signatureString:(NSString *)string privateKey:(NSString *)privateKey digest:(JGSRSASignatureDigest)digest algorithm:(SecKeyAlgorithm)algorithm {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length == 0 || privateKey.length == 0) {
        return @"";
    }
    
    SecKeyRef keyRef = [self privateKeyRefCreateWithContents:privateKey];
    if (keyRef == NULL) {
        return @"";
    }
    
    data = [self signatureData:data privateKeyRef:keyRef digest:digest algorithm:algorithm];
    CFRelease(keyRef);
    
    NSString *encStr = [data jg_base64EncodeString] ?: @"";
    return encStr;
}

+ (BOOL)verifySignature:(NSString *)signature originString:(NSString *)string publicKeyWithContentsOfFile:(NSString *)path digest:(JGSRSASignatureDigest)digest algorithm:(SecKeyAlgorithm)algorithm {
    
    if (signature.length == 0 || string.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return NO;
    }
    
    NSData *sigData = [signature jg_base64DecodeData];
    if (sigData == nil) {
        return NO;
    }
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil) {
        return NO;
    }
    
    SecKeyRef keyRef = [self publicKeyRefCreateWithContentsOfFile:path];
    if (keyRef == NULL) {
        return NO;
    }
    
    BOOL verified = [self verifySignature:sigData originData:data publicKeyRef:keyRef digest:digest algorithm:algorithm];
    CFRelease(keyRef);
    
    return verified;
}

+ (BOOL)verifySignature:(NSString *)signature originString:(NSString *)string publicKey:(NSString *)publicKey digest:(JGSRSASignatureDigest)digest algorithm:(SecKeyAlgorithm)algorithm {
    
    if (string.length == 0 || publicKey.length == 0) {
        return NO;
    }
    
    NSData *sigData = [signature jg_base64DecodeData];
    if (sigData == nil) {
        return NO;
    }
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil) {
        return NO;
    }
    
    SecKeyRef keyRef = [self publicKeyRefCreateWithContents:publicKey];
    if (keyRef == NULL) {
        return NO;
    }
    
    BOOL verified = [self verifySignature:sigData originData:data publicKeyRef:keyRef digest:digest algorithm:algorithm];
    CFRelease(keyRef);
    
    return verified;
}

#pragma mark - 私钥格式转换
+ (NSString *)pkcs1PrivateKeyWithPrivateContent:(NSString *)privateContent {
    
    if (privateContent.length == 0) {
        return @"";
    }
    
    /*
     iOS仅支持pkcs1私钥，针对传入私钥需要判断pkcs1还是pkcs8
     RSA私钥pkcs1、pkcs8区别：https://www.jianshu.com/p/a428e183e72e
     iOS RSA加签 验签 与Java同步 pkcs8 pkcs1：https://www.jianshu.com/p/2b3545336d3d
     */
    
    // pkcs1 - begin
    NSRange startPos = [privateContent rangeOfString:@"-----BEGIN RSA PRIVATE KEY-----"];
    if (startPos.location != NSNotFound) {
        privateContent = [privateContent substringFromIndex:startPos.length];
    }
    
    // pkcs8 - begin
    startPos = [privateContent rangeOfString:@"-----BEGIN PRIVATE KEY-----"]; // pkcs1
    if (startPos.location != NSNotFound) {
        privateContent = [privateContent substringFromIndex:startPos.length];
    }
    
    // pkcs1 - end
    NSRange endPos = [privateContent rangeOfString:@"-----END RSA PRIVATE KEY-----"];
    if (endPos.location != NSNotFound) {
        privateContent = [privateContent substringToIndex:endPos.location];
    }
    
    // pkcs8 - end
    endPos = [privateContent rangeOfString:@"-----END PRIVATE KEY-----"];
    if (endPos.location != NSNotFound) {
        privateContent = [privateContent substringToIndex:endPos.location];
    }
    
    NSMutableCharacterSet *charSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [charSet formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
    privateContent = [privateContent stringByTrimmingCharactersInSet:charSet];
    if (privateContent.length == 0) {
        return @"";
    }
    
    NSData *data = [privateContent jg_base64DecodeData];
    // TODO: 该步骤能够将pkcs8转换为pkcs1，不一定保证转换正确，有待研究
    // 如转换失败则继续使用转换前Data
    data = [self stripPrivateKeyHeader:data] ?: data;
    NSString *pkcs1 = data.length == 0 ? @"" : [data jg_base64EncodeString];
    
    return pkcs1;
    
    // 编码格式及长度 -> 64位字符一行字符串长度 -> 单行字符串长度 -> 单行字符串Data长度
    // pkcs1-1024 -> 824 -> 812 -> 609
    // pkcs8-1024 -> 861 -> 848 -> 635
    // pkcs1-2048 -> 1616 -> 1592 -> 1192
    // pkcs8-2048 -> 1649 -> 1624 -> 1218
    // 其他情况不一一枚举
    //if (privateContent.length == 812 || privateContent.length == 1592) {
    //    // pkcs1
    //    return [data jg_base64EncodeString];
    //}
    //else if (privateContent.length == 848 || privateContent.length == 1624) {
    //    // pkcs8
    //    // Data长度：pkcs8 比 pkcs1 长 26
    //    NSRange pkcs1Range = NSMakeRange(26, MAX(0, data.length - 26));
    //    return [[data subdataWithRange:pkcs1Range] jg_base64EncodeString];
    //}
    //
    //return @"";
}

#pragma mark - Private
+ (NSData *)encryptData:(NSData *)data publicKeyRef:(SecKeyRef)keyRef {
    
    // iOS 10以后系统方法
    CFDataRef dataRef = SecKeyCreateEncryptedData(keyRef, kSecKeyAlgorithmRSAEncryptionPKCS1, (CFDataRef)data, NULL);
    if (dataRef == NULL) {
        return nil;
    }
    
    NSData *encryptedData = [(__bridge NSData *)dataRef copy];
    CFRelease(dataRef);
    
    return encryptedData;
}

+ (NSData *)decryptData:(NSData *)data privateKeyRef:(SecKeyRef)keyRef {
    
    // iOS 10以后系统方法
    CFDataRef dataRef = SecKeyCreateDecryptedData(keyRef, kSecKeyAlgorithmRSAEncryptionPKCS1, (CFDataRef)data, NULL);
    if (dataRef == NULL) {
        return nil;
    }
    
    NSData *decryptedData = [(__bridge NSData *)dataRef copy];
    CFRelease(dataRef);
    
    return decryptedData;
}

+ (NSData *)signatureData:(NSData *)data privateKeyRef:(SecKeyRef)keyRef digest:(JGSRSASignatureDigest)digest algorithm:(SecKeyAlgorithm)algorithm {
    
    data = [self disgestData:data disgest:digest];
    if (data.length == 0) {
        return nil;
    }
    
    if (!SecKeyIsAlgorithmSupported(keyRef, kSecKeyOperationTypeSign, algorithm)) {
        return nil;
    }
    
    // iOS 10以后系统方法
    CFErrorRef error = NULL;
    CFDataRef dataRef = SecKeyCreateSignature(keyRef, algorithm, (CFDataRef)data, &error);
    if (error != NULL || dataRef == NULL) {
        if (dataRef) {
            CFRelease(dataRef);
        }
        return nil;
    }
    
    NSData *signature = [(__bridge NSData *)dataRef copy];
    CFRelease(dataRef);
    
    return signature;
}

+ (BOOL)verifySignature:(NSData *)signature originData:(NSData *)data publicKeyRef:(SecKeyRef)keyRef digest:(JGSRSASignatureDigest)digest algorithm:(SecKeyAlgorithm)algorithm {
    
    data = [self disgestData:data disgest:digest];
    if (data.length == 0) {
        return nil;
    }
    
    if (!SecKeyIsAlgorithmSupported(keyRef, kSecKeyOperationTypeVerify, algorithm)) {
        return nil;
    }
    
    // iOS 10以后系统方法
    CFErrorRef error = NULL;
    Boolean result = SecKeyVerifySignature(keyRef, algorithm, (CFDataRef)data, (CFDataRef)signature, &error);
    if (error != NULL || result != true) {
        return NO;
    }
    
    return result;
}

+ (NSData *)disgestData:(NSData *)data disgest:(JGSRSASignatureDigest)signDigest {
    
    NSString *digestString = nil;
    switch (signDigest) {
        case JGSRSASignatureDigestSHA256:
            digestString = [data jg_sha256];
            break;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        case JGSRSASignatureDigestMD5:
            digestString = [data jg_md5String];
            break;
#pragma clang diagnostic pop
            
        case JGSRSASignatureDigestRaw:
            break;
    }
    
    NSData *digestData = digestString ? [digestString dataUsingEncoding:NSUTF8StringEncoding] : data;
    return digestData;
}

#pragma mark - Private - PublicKey
/// RSA公钥der证书内容获取
/// @param derPath der证书路径
+ (SecKeyRef)publicKeyRefCreateWithContentsOfFile:(NSString *)derPath {
    
    if (derPath.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:derPath]) {
        return NULL;
    }
    
    NSData *certData = [NSData dataWithContentsOfFile:derPath];
    if (certData.length == 0) {
        return NULL;
    }
    
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (CFDataRef)certData);
    if (cert == NULL) {
        return NULL;
    }
    
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    if (policy == NULL) {
        return NULL;
    }
    
    SecTrustRef trust = NULL;
    if (SecTrustCreateWithCertificates((CFTypeRef)cert, policy, &trust) != noErr) {
        CFRelease(cert);
        CFRelease(policy);
        return NULL;
    }
    
    SecTrustResultType result;
    if (SecTrustEvaluate(trust, &result) != noErr) {
        CFRelease(cert);
        CFRelease(policy);
        CFRelease(trust);
        return NULL;
    }
    
    SecKeyRef publicKeyRef = SecTrustCopyPublicKey(trust);
    
    CFRelease(cert);
    CFRelease(policy);
    CFRelease(trust);
    return publicKeyRef;
}

/// RSA公钥der证书内容获取
/// @param publicContent pem公钥文件内容
+ (SecKeyRef)publicKeyRefCreateWithContents:(NSString *)publicContent {
    
    if (publicContent.length == 0) {
        return NULL;
    }
    
    NSRange startPos = [publicContent rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    if (startPos.location != NSNotFound) {
        publicContent = [publicContent substringFromIndex:startPos.length];
    }
    
    NSRange endPos = [publicContent rangeOfString:@"-----END PUBLIC KEY-----"];
    if (endPos.location != NSNotFound) {
        publicContent = [publicContent substringToIndex:endPos.location];
    }
    
    NSMutableCharacterSet *charSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [charSet formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
    publicContent = [publicContent stringByTrimmingCharactersInSet:charSet];
    if (publicContent.length == 0) {
        return NULL;
    }
    
    NSData *data = [publicContent jg_base64DecodeData];
    // TODO: 是否执行该步骤，暂未发现有啥影响，有待研究，暂保留
    // 如转换失败则继续使用转换前Data
    data = [self stripPublicKeyHeader:data] ?: data;
    if (data.length == 0) {
        return NULL;
    }
    
    NSDictionary *options = @{
        (__bridge  id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
        (__bridge  id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPublic,
        //(__bridge  id)kSecAttrKeySizeInBits: @(1024),
    };
    
    // iOS 10以上使用系统方法获取 SecKeyRef
    // 不再需要使用Security/SecItem处理，Security/SecItem处理方式参考：https://github.com/ideawu/Objective-C-RSA
    NSError *error = nil;
    CFErrorRef cfError = (__bridge  CFErrorRef)error;
    SecKeyRef keyRef = SecKeyCreateWithData((__bridge  CFDataRef)data, (__bridge  CFDictionaryRef)options, &cfError);
    if (error) {
        CFRelease(keyRef);
        return NULL;
    }
    
    return keyRef;
}

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key {
    
    // Skip ASN.1 public key header
    if (d_key == nil) {
        return nil;
    }
    
    unsigned long len = [d_key length];
    if (!len) {
        return nil;
    }
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int idx = 0;
    if (c_key[idx++] != 0x30) {
        return(nil);
    }
    
    if (c_key[idx] > 0x80) {
        idx += c_key[idx] - 0x80 + 1;
    } else {
        idx++;
    }
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] = {
        0x30, 0x0d,   0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00
    };
    
    if (memcmp(&c_key[idx], seqiod, 15)) {
        return nil;
    }
    
    idx += 15;
    if (c_key[idx++] != 0x03) {
        return nil;
    }
    
    if (c_key[idx] > 0x80) {
        idx += c_key[idx] - 0x80 + 1;
    } else {
        idx++;
    }
    
    if (c_key[idx++] != '\0') {
        return(nil);
    }
    
    // Now make a new NSData from this buffer
    return [NSData dataWithBytes:&c_key[idx] length:len - idx];
}

#pragma mark - Private - PrivateKey
/// RSA私钥der证书内容获取
/// @param p12Path p12证书路径
/// @param password p12证书密码
+ (SecKeyRef)privateKeyRefWithContentsOfFile:(NSString *)p12Path password:(NSString *)password {
    
    if (p12Path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:p12Path]) {
        return NULL;
    }
    
    NSData *p12Data = [NSData dataWithContentsOfFile:p12Path];
    if (p12Data.length == 0) {
        return NULL;
    }
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    NSDictionary *options = @{(__bridge id)kSecImportExportPassphrase: password};
    OSStatus securityError = SecPKCS12Import((__bridge CFDataRef)p12Data, (__bridge CFDictionaryRef)options, &items);
    if (securityError != noErr || CFArrayGetCount(items) == 0) {
        CFRelease(items);
        return NULL;
    }
    
    CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
    SecIdentityRef identityApp = (SecIdentityRef)CFDictionaryGetValue(identityDict, kSecImportItemIdentity);
    
    SecKeyRef privateKeyRef = NULL;
    if (SecIdentityCopyPrivateKey(identityApp, &privateKeyRef) != noErr) {
        privateKeyRef = NULL;
    }
    
    CFRelease(items);
    return privateKeyRef;
}

/// RSA私钥der证书内容获取
/// @param privateContent pem私钥文件内容
+ (SecKeyRef)privateKeyRefCreateWithContents:(NSString *)privateContent {
    
    privateContent = [self pkcs1PrivateKeyWithPrivateContent:privateContent];
    if (privateContent.length == 0) {
        return NULL;
    }
    
    NSData *data = [privateContent jg_base64DecodeData];
    if (data.length == 0) {
        return NULL;
    }
    
    NSDictionary *options = @{
        (__bridge  id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
        (__bridge  id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPrivate,
        //(__bridge  id)kSecAttrKeySizeInBits: @(1024),
    };
    
    // iOS 10以上使用系统方法获取 SecKeyRef
    // 不再需要使用Security/SecItem处理，Security/SecItem处理方式参考：https://github.com/ideawu/Objective-C-RSA
    NSError *error = nil;
    CFErrorRef cfError = (__bridge  CFErrorRef)error;
    SecKeyRef keyRef = SecKeyCreateWithData((__bridge  CFDataRef)data, (__bridge  CFDictionaryRef)options, &cfError);
    if (error) {
        CFRelease(keyRef);
        return NULL;
    }
    
    return keyRef;
}

+ (NSData *)stripPrivateKeyHeader:(NSData *)d_key {
    
    // Skip ASN.1 private key header
    if (d_key == nil) {
        return nil;
    }
    
    unsigned long len = [d_key length];
    if (!len) {
        return nil;
    }
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int idx = 22; // magic byte at offset 22
    if (0x04 != c_key[idx++]) {
        return nil;
    }
    
    // calculate length of the key
    unsigned int c_len = c_key[idx++];
    int det = c_len & 0x80;
    if (!det) {
        c_len = c_len & 0x7f;
    }
    else {
        
        int byteCount = c_len & 0x7f;
        if (byteCount + idx > len) {
            //rsa length field longer than buffer
            return nil;
        }
        
        unsigned int accum = 0;
        unsigned char *ptr = &c_key[idx];
        idx += byteCount;
        while (byteCount) {
            accum = (accum << 8) + *ptr;
            ptr++;
            byteCount--;
        }
        c_len = accum;
    }
    
    // Now make a new NSData from this buffer
    return [d_key subdataWithRange:NSMakeRange(idx, c_len)];
}

@end
