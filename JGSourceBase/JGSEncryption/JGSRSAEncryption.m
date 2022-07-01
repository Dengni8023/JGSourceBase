//
//  JGSRSAEncryption.m
//  JGSEncryption
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSRSAEncryption.h"
#import "JGSBase+JGSPrivate.h"
#import <Security/Security.h>
#import "NSData+JGSBase.h"
#import "NSString+JGSBase.h"

/// RSA公钥der证书内容获取
/// @param derPath der证书路径
SecKeyRef jg_rsaPublicKeyRefCreateWithContentsOfFile(NSString *derPath);

/// RSA公钥der证书内容获取
/// @param publicContent pem公钥文件内容
SecKeyRef jg_rsaPublicKeyRefCreateWithContents(NSString *publicContent);

/// RSA私钥der证书内容获取
/// @param p12Path p12证书路径
/// @param password p12证书密码
SecKeyRef jg_rsaPrivateKeyRefWithContentsOfFile(NSString *p12Path, NSString *password);

/// RSA私钥der证书内容获取
/// @param privateContent pem私钥文件内容
SecKeyRef jg_rsaPrivateKeyRefCreateWithContents(NSString *privateContent);

@implementation JGSRSAEncryption

#pragma mark - 加解密 - 公钥加密 & 私钥解密
+ (NSString *)encryptString:(NSString *)string publicKeyWithContentsOfFile:(NSString *)path {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length == 0 || path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return @"";
    }
    
    SecKeyRef keyRef = jg_rsaPublicKeyRefCreateWithContentsOfFile(path);
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
    
    SecKeyRef keyRef = jg_rsaPublicKeyRefCreateWithContents(publicKey);
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
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (data.length == 0) {
        return @"";
    }
    
    SecKeyRef keyRef = jg_rsaPrivateKeyRefWithContentsOfFile(path, password ?: @"");
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
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (data.length == 0) {
        return @"";
    }
    
    SecKeyRef keyRef = jg_rsaPrivateKeyRefCreateWithContents(privateKey);
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
    
    SecKeyRef keyRef = jg_rsaPrivateKeyRefWithContentsOfFile(path, password ?: @"");
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
    
    SecKeyRef keyRef = jg_rsaPrivateKeyRefCreateWithContents(privateKey);
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
    
    NSData *sigData = [[NSData alloc] initWithBase64EncodedString:signature options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (sigData == nil) {
        return NO;
    }
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil) {
        return NO;
    }
    
    SecKeyRef keyRef = jg_rsaPublicKeyRefCreateWithContentsOfFile(path);
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
    
    NSData *sigData = [[NSData alloc] initWithBase64EncodedString:signature options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (sigData == nil) {
        return NO;
    }
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil) {
        return NO;
    }
    
    SecKeyRef keyRef = jg_rsaPublicKeyRefCreateWithContents(publicKey);
    if (keyRef == NULL) {
        return NO;
    }
    
    BOOL verified = [self verifySignature:sigData originData:data publicKeyRef:keyRef digest:digest algorithm:algorithm];
    CFRelease(keyRef);
    
    return verified;
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
            digestString = [data jg_sha256String];
            break;
            
        case JGSRSASignatureDigestMD5:
            digestString = [data jg_md5String];
            break;
            
        case JGSRSASignatureDigestRaw:
            break;
    }
    
    NSData *digestData = digestString ? [digestString dataUsingEncoding:NSUTF8StringEncoding] : data;
    return digestData;
}

@end

SecKeyRef jg_rsaPublicKeyRefCreateWithContentsOfFile(NSString *derPath) {
    
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

SecKeyRef jg_rsaPublicKeyRefCreateWithContents(NSString *publicContent) {
    
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
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:publicContent options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (data.length == 0) {
        return NULL;
    }
    
    NSDictionary *options = @{
        (__bridge  id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
        (__bridge  id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPublic,
        //(__bridge  id)kSecAttrKeySizeInBits: @(1024),
    };
    
    // iOS 10以上使用系统方法获取 SecKeyRef
    NSError *error = nil;
    CFErrorRef cfError = (__bridge  CFErrorRef)error;
    SecKeyRef keyRef = SecKeyCreateWithData((__bridge  CFDataRef)data, (__bridge  CFDictionaryRef)options, &cfError);
    if (error) {
        CFRelease(keyRef);
        return NULL;
    }
    
    return keyRef;
}

SecKeyRef jg_rsaPrivateKeyRefWithContentsOfFile(NSString *p12Path, NSString *password) {
    
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

SecKeyRef jg_rsaPrivateKeyRefCreateWithContents(NSString *privateContent) {
    
    if (privateContent.length == 0) {
        return NULL;
    }
    
    NSRange startPos = [privateContent rangeOfString:@"-----BEGIN RSA PRIVATE KEY-----"];
    if (startPos.location != NSNotFound) {
        privateContent = [privateContent substringFromIndex:startPos.length];
    }
    
    NSRange endPos = [privateContent rangeOfString:@"-----END RSA PRIVATE KEY-----"];
    if (endPos.location != NSNotFound) {
        privateContent = [privateContent substringToIndex:endPos.location];
    }
    
    NSMutableCharacterSet *charSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [charSet formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
    privateContent = [privateContent stringByTrimmingCharactersInSet:charSet];
    if (privateContent.length == 0) {
        return NULL;
    }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:privateContent options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (data.length == 0) {
        return NULL;
    }
    
    NSDictionary *options = @{
        (__bridge  id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
        (__bridge  id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPrivate,
        //(__bridge  id)kSecAttrKeySizeInBits: @(1024),
    };
    
    // iOS 10以上使用系统方法获取 SecKeyRef
    NSError *error = nil;
    CFErrorRef cfError = (__bridge  CFErrorRef)error;
    SecKeyRef keyRef = SecKeyCreateWithData((__bridge  CFDataRef)data, (__bridge  CFDictionaryRef)options, &cfError);
    if (error) {
        CFRelease(keyRef);
        return NULL;
    }
    
    return keyRef;
}
