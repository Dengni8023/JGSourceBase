//
//  JGSRSAEncryption.h
//  JGSEncryption
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 RSA证书、密钥生成，参考链接：https://www.jianshu.com/p/e8cd42e6af95
 
 一、RSA密钥对生成
 Mac系统内置OpenSSL(开源加密库)，所以我们可以使用终端尝试使用RSA
 生成RSA私钥，指定长度1024bit，命令为：
    openssl genrsa -out rsa_private_1024.pem 1024
    openssl genrsa -out rsa_private_2048.pem 2048
 
 从私钥中提取公钥，命令为：
    openssl rsa -in rsa_private_1024.pem -pubout -out rsa_public_1024.pem
    openssl rsa -in rsa_private_2048.pem -pubout -out rsa_public_2048.pem
 
 二、RSA加解密测试
 随便创建一个txt文件，并写入一些内容，注意不能太长，比如rsa_message.txt

 公钥加密私钥解密：
 openssl rsautl -encrypt -in rsa_message.txt -inkey rsa_public_1024.pem -pubin -out public_1024_enc
 openssl rsautl -decrypt -in public_1024_enc -inkey rsa_private_1024.pem -out private_1024_dec

 私钥加密公钥解密：
 openssl rsautl -sign -in rsa_message.txt -inkey rsa_private_1024.pem -out private_1024_enc
 openssl rsautl -verify -in private_1024_enc -inkey rsa_public_1024.pem -pubin -out public_1024_dec

 三、OC加解密der、p12格式证书转换
 OC代码中使用RSA不能直接使用pem格式文件，需要将私钥转成p12文件，公钥转成der格式
 
 首先需要请求一个csr的文件，因为证书是需要认证的，这个csr文件中包含一些信息如Country Name、Organization Name、Email等。随便填~
 1. 终端命令为：
    openssl req -new -key rsa_private_1024.pem -out rsa_cert_1024.csr
    openssl req -new -key rsa_private_2048.pem -out rsa_cert_2048.csr
    过程中需要填写一些信息以及密码(空即可)。

 2. 证书签名生成crt文件：
    openssl x509 -req -days 36500 -in rsa_cert_1024.csr -signkey rsa_private_1024.pem -out rsa_private_1024.crt
    openssl x509 -req -days 36500 -in rsa_cert_2048.csr -signkey rsa_private_2048.pem -out rsa_private_2048.crt
    -days 36500有效期100年的自签名证书(https协议就需要这样的一个证书，想省钱可以使用这种自签名证书，将crt文件放在服务器上，让别人接受即可~)

 3. crt生成p12文件：
    openssl pkcs12 -export -out rsa_private_1024.p12 -inkey rsa_private_1024.pem -in rsa_private_1024.crt
    openssl pkcs12 -export -out rsa_private_2048.p12 -inkey rsa_private_2048.pem -in rsa_private_2048.crt
    需要输入密码，密码可为空

 4. 生成der文件：
    openssl x509 -outform der -in rsa_private_1024.crt -out rsa_public_1024.der
    openssl x509 -outform der -in rsa_private_2048.crt -out rsa_public_2048.der

 将rsa_private_1024.p12和rsa_public_1024.der文件添加到工程中使用。主要是使用动态库Security中的SecKey类中的方法。

 ⚠️ Demo工程中公私钥文件同时存在与前端APP项目中且证书文件密码为空，仅为测试使用。
 根据上述步骤，可以得出结论：
 ⚠️ RSA公钥可通过私钥获取
 
 因此，考虑前端安全问题，实际使用过程前端APP应
 ⚠️ 1、仅存储公钥字符串或相关证书文件
 ❌ 2、私钥字符串、证书文件严禁存储
 */

// RSA签名数据源，RSA签名数据源不能过长，因此需对原数据进行相应HASH处理，对HASH结果进行签名、验证
typedef NS_ENUM(NSInteger, JGSRSASignatureDigest) {
    JGSRSASignatureDigestRaw = 0, // 原数据较短或外部已进行HASH处理，内部无需HASH处理
    JGSRSASignatureDigestSHA256, // 先获取SHA256，对SHA256进行签名、验证
    JGSRSASignatureDigestMD5, // 先获取MD5，对MD5进行签名、验证
};

@interface JGSRSAEncryption : NSObject

#pragma mark - 加解密 - 公钥加密 & 私钥解密
/// RSA公钥加密方法，填充方式为 kSecKeyAlgorithmRSAEncryptionPKCS1，iOS仅支持该方式
/// @param string 需要加密的字符串
/// @param path 公钥文件路径，无法直接使用pem格式文件，公钥需要转成der格式文件
+ (NSString *)encryptString:(NSString *)string publicKeyWithContentsOfFile:(NSString *)path;

/// RSA公钥加密方法，填充方式为 kSecKeyAlgorithmRSAEncryptionPKCS1，iOS仅支持该方式
/// @param string 需要加密的字符串
/// @param publicKey 公钥字符串
+ (NSString *)encryptString:(NSString *)string publicKey:(NSString *)publicKey;

/// RSA私钥解密方法，填充方式为 kSecKeyAlgorithmRSAEncryptionPKCS1，iOS仅支持该方式
/// @param string 需要解密的字符串
/// @param path 私钥文件路径，无法直接使用pem格式文件，公钥需要转成p12格式文件
/// @param password 私钥文件密码，nil默认为空密码
+ (NSString *)decryptString:(NSString *)string privateKeyWithContentsOfFile:(NSString *)path password:(nullable NSString *)password;

/// RSA私钥解密方法，填充方式为 kSecKeyAlgorithmRSAEncryptionPKCS1，iOS仅支持该方式
/// @param string 需要解密的字符串
/// @param privateKey 私钥字符串
+ (NSString *)decryptString:(NSString *)string privateKey:(NSString *)privateKey;

#pragma mark - 签名验证 - 私钥签名 & 公钥验证
/// RSA私钥签名方法
/// @param string 需要加密的字符串
/// @param path 私钥文件路径，无法直接使用pem格式文件，公钥需要转成p12格式文件
/// @param password 私钥文件密码，nil默认为空密码
/// @param algorithm RSA签名数据源，是否对原数据进行相应处理，对处理结果进行签名、验证
+ (NSString *)signatureString:(NSString *)string privateKeyWithContentsOfFile:(NSString *)path password:(nullable NSString *)password digest:(JGSRSASignatureDigest)digest algorithm:(SecKeyAlgorithm)algorithm;

/// RSA私钥签名方法
/// @param string 需要加密的字符串
/// @param privateKey 私钥字符串
/// @param algorithm RSA签名数据源，是否对原数据进行相应处理，对处理结果进行签名、验证
+ (NSString *)signatureString:(NSString *)string privateKey:(NSString *)privateKey digest:(JGSRSASignatureDigest)digest algorithm:(SecKeyAlgorithm)algorithm;

/// RSA私钥解密方法
/// @param string 需要解密的字符串
/// @param path 公钥文件路径，无法直接使用pem格式文件，公钥需要转成der格式文件
/// @param algorithm RSA签名数据源，是否对原数据进行相应处理，对处理结果进行签名、验证
+ (BOOL)verifySignature:(NSString *)signature originString:(NSString *)string publicKeyWithContentsOfFile:(NSString *)path digest:(JGSRSASignatureDigest)digest algorithm:(SecKeyAlgorithm)algorithm;

/// RSA私钥解密方法
/// @param string 需要解密的字符串
/// @param publicKey 公钥字符串
/// @param algorithm RSA签名数据源，是否对原数据进行相应处理，对处理结果进行签名、验证
+ (BOOL)verifySignature:(NSString *)signature originString:(NSString *)string publicKey:(NSString *)publicKey digest:(JGSRSASignatureDigest)digest algorithm:(SecKeyAlgorithm)algorithm;

@end

NS_ASSUME_NONNULL_END
