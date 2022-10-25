//
//  JGSEncryptionDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/2/16.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSEncryptionDemoVC.h"

@interface JGSEncryptionDemoVC ()

@end

@implementation JGSEncryptionDemoVC

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = @"Encryption";
}

#ifdef JGSEncryption_h
#pragma mark - TableRows
- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
    return @[
        JGSDemoTableSectionMake(@" Base64", @[
            JGSDemoTableRowMake(@" Base64 Encryption", self, @selector(showBase64Encryption:)),
            JGSDemoTableRowMake(@" Base64 Decryption", self, @selector(showBase64Encryption:)),
        ]),
        JGSDemoTableSectionMake(@" AES", @[
            JGSDemoTableRowMake(@" AES-128", self, @selector(showAESEncryption:)),
            JGSDemoTableRowMake(@" AES-256", self, @selector(showAESEncryption:)),
        ]),
        JGSDemoTableSectionMake(@" RSA-公钥加密 & 私钥解密", @[
            JGSDemoTableRowMake(@" RSA-1024证书加解密", self, @selector(showRSAEncryption:)),
            JGSDemoTableRowMake(@" RSA-1024公私钥加解密", self, @selector(showRSAEncryption:)),
            JGSDemoTableRowMake(@" RSA-2048证书加解密", self, @selector(showRSAEncryption:)),
            JGSDemoTableRowMake(@" RSA-2048公私钥加解密", self, @selector(showRSAEncryption:)),
        ]),
        JGSDemoTableSectionMake(@" RSA-私钥签名 & 公钥验证", @[
            JGSDemoTableRowMake(@" RSA-1024证书签名验证", self, @selector(showRSAEncryption:)),
            JGSDemoTableRowMake(@" RSA-1024公私钥签名验证", self, @selector(showRSAEncryption:)),
            JGSDemoTableRowMake(@" RSA-2048证书签名验证", self, @selector(showRSAEncryption:)),
            JGSDemoTableRowMake(@" RSA-2048公私钥签名验证", self, @selector(showRSAEncryption:)),
        ]),
        JGSDemoTableSectionMake(@" RSA-私钥转换", @[
            JGSDemoTableRowMake(@" RSA-1024-pkcs1转换", self, @selector(showRSAPrivateKeySwap:)),
            JGSDemoTableRowMake(@" RSA-1024-pkcs8转换", self, @selector(showRSAPrivateKeySwap:)),
            JGSDemoTableRowMake(@" RSA-2048-pkcs1转换", self, @selector(showRSAPrivateKeySwap:)),
            JGSDemoTableRowMake(@" RSA-2048-pkcs8转换", self, @selector(showRSAPrivateKeySwap:)),
        ]),
    ];
}

#pragma mark - Action
- (void)showBase64Encryption:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0: {
            
            NSString *origin = @"Base64 Encryption origin string";
            NSString *encrypt = [origin jg_base64EncodeString];
            JGSDemoShowConsoleLog(self, @"Base64 encrypt: <%@> >>> <%@>", origin, encrypt);
        }
            break;
            
        case 1: {
            
            NSString *origin = @"QmFzZTY0IEVuY3J5cHRpb24gb3JpZ2luIHN0cmluZw==";
            NSString *decrypt = [origin jg_base64DecodeString];
            JGSDemoShowConsoleLog(self, @"Base64 encrypt: <%@> >>> <%@>", origin, decrypt);
        }
            break;
            
        default:
            break;
    }
}

- (void)showAESEncryption:(NSIndexPath *)indexPath {
    
    // 加解密可以和在线工具进行对比验证：https://www.qtool.net/aes
    NSString *aes128Key = @"1234567890abcdef";
    NSString *aes256Key = @"1234567890abcdef1234567890ABCDEF";
    switch (indexPath.row) {
        case 0: {
            
            NSString *origin = @"AES-128 origin string";
            NSString *encrypt = [origin jg_AES128EncryptWithKey:aes128Key iv:nil];
            JGSDemoShowConsoleLog(self, @"128 encrypt: %@", encrypt);
            JGSDemoShowConsoleLog(self, @"128 decrypt: %@", [encrypt jg_AES128DecryptWithKey:aes128Key iv:nil]);
            
            encrypt = [origin jg_AES128EncryptWithKey:aes128Key iv:aes128Key];
            JGSDemoShowConsoleLog(self, @"128 encrypt with iv: %@", encrypt);
            JGSDemoShowConsoleLog(self, @"128 decrypt: %@", [encrypt jg_AES128DecryptWithKey:aes128Key iv:aes128Key]);
        }
            break;
            
        case 1: {
            
            NSString *origin = @"AES-256 origin string";
            NSString *encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:nil];
            JGSDemoShowConsoleLog(self, @"256 encrypt: %@", encrypt);
            JGSDemoShowConsoleLog(self, @"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:nil]);
            
            encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:@"12345"];
            JGSDemoShowConsoleLog(self, @"256 encrypt with short iv: %@", encrypt);
            JGSDemoShowConsoleLog(self, @"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:@"12345"]);
            
            encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:aes256Key];
            JGSDemoShowConsoleLog(self, @"256 encrypt with iv: %@", encrypt);
            JGSDemoShowConsoleLog(self, @"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:aes256Key]);
        }
            break;
            
        default:
            break;
    }
}

- (void)showRSAEncryption:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
        case 2: {
            
            NSString *publicDer = indexPath.row == 0 ? @"rsa_public_1024.der" : @"rsa_public_2048.der";
            NSString *privateP12 = indexPath.row == 0 ? @"rsa_private_1024.p12" : @"rsa_private_2048.p12";
            
            publicDer = [[NSBundle mainBundle] pathForResource:publicDer ofType:nil];
            privateP12 = [[NSBundle mainBundle] pathForResource:privateP12 ofType:nil];
            
            if (publicDer.length == 0 || privateP12.length == 0) {
                JGSDemoShowConsoleLog(self, @"Public der or private p12 RSA file doesn't exist !");
                return;
            }
            
            if (indexPath.section == 2) {
                
                // 公钥加密 & 私钥解密
                NSString *originText = @"RSA encryption test common content";
                NSString *publicEnc = [JGSRSAEncryption encryptString:originText publicKeyWithContentsOfFile:publicDer];
                JGSDemoShowConsoleLog(self, @"publicEnc: %@", publicEnc);
                NSString *privateDec = [JGSRSAEncryption decryptString:publicEnc privateKeyWithContentsOfFile:privateP12 password:nil];
                JGSDemoShowConsoleLog(self, @"privateDec: %@", privateDec);
            }
            else if (indexPath.section == 3) {
                
                // 私钥签名 & 公钥验证
                NSArray<NSString *> *algorithms = @[
                    (__bridge NSString *)kSecKeyAlgorithmRSASignatureDigestPKCS1v15Raw,
                    (__bridge NSString *)kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA1,
                    (__bridge NSString *)kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA256,
                    (__bridge NSString *)kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA512,
                    (__bridge NSString *)kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA384,
                    (__bridge NSString *)kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA224,
                ];
                for (NSString *algorithm in algorithms) {
                    
                    NSString *originText = @"RSA encryption test special content";
                    NSString *testFilePath = [[NSBundle mainBundle] pathForResource:@"rsa_message.txt" ofType:nil];
                    originText = testFilePath ? [NSString stringWithContentsOfFile:testFilePath encoding:NSUTF8StringEncoding error:nil] : originText;
                    
                    // 原始数据可能较长，因此不直接使用原数据方式
                    for (JGSRSASignatureDigest digest = JGSRSASignatureDigestSHA256; digest <= JGSRSASignatureDigestMD5; digest++) {
                        
                        NSString *publicEnc = [JGSRSAEncryption signatureString:originText privateKeyWithContentsOfFile:privateP12 password:nil digest:digest algorithm:(SecKeyAlgorithm)algorithm];
                        JGSDemoShowConsoleLog(self, @"signature: %@", publicEnc);
                        BOOL verified = [JGSRSAEncryption verifySignature:publicEnc originString:originText publicKeyWithContentsOfFile:publicDer digest:digest algorithm:(SecKeyAlgorithm)algorithm];
                        JGSDemoShowConsoleLog(self, @"verified: %@", verified ? @"YES" : @"NO");
                    }
                }
            }
        }
            break;
            
        case 1:
        case 3: {
            
            NSString *publicPem = indexPath.row == 1 ? @"rsa_public_1024.pem" : @"rsa_public_2048.pem";
            NSString *privatePem = indexPath.row == 1 ? @"rsa_private_1024.pem" : @"rsa_private_2048.pem";
            
            publicPem = [[NSBundle mainBundle] pathForResource:publicPem ofType:nil];
            privatePem = [[NSBundle mainBundle] pathForResource:privatePem ofType:nil];
            
            if (publicPem.length == 0 || privatePem.length == 0) {
                JGSDemoShowConsoleLog(self, @"Public or private RSA pem file doesn't exist !");
                return;
            }
            
            NSString *publicKey = [NSString stringWithContentsOfFile:publicPem encoding:NSUTF8StringEncoding error:nil];
            NSString *privateKey = [NSString stringWithContentsOfFile:privatePem encoding:NSUTF8StringEncoding error:nil];
            
            if (indexPath.section == 2) {
                
                // 公钥加密 & 私钥解密
                NSString *originText = @"RSA encryption test common content";
                NSString *publicEnc = [JGSRSAEncryption encryptString:originText publicKey:publicKey];
                JGSDemoShowConsoleLog(self, @"publicEnc: %@", publicEnc);
                NSString *privateDec = [JGSRSAEncryption decryptString:publicEnc privateKey:privateKey];
                JGSDemoShowConsoleLog(self, @"privateDec: %@", privateDec);
            }
            else if (indexPath.section == 3) {
                
                // 私钥签名 & 公钥验证
                NSArray<NSString *> *algorithms = @[
                    (__bridge NSString *)kSecKeyAlgorithmRSASignatureDigestPKCS1v15Raw,
                    (__bridge NSString *)kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA1,
                    (__bridge NSString *)kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA256,
                    (__bridge NSString *)kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA512,
                    (__bridge NSString *)kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA384,
                    (__bridge NSString *)kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA224,
                ];
                for (NSString *algorithm in algorithms) {
                    
                    NSString *originText = @"RSA encryption test special content";
                    NSString *testFilePath = [[NSBundle mainBundle] pathForResource:@"rsa_message.txt" ofType:nil];
                    originText = testFilePath ? [NSString stringWithContentsOfFile:testFilePath encoding:NSUTF8StringEncoding error:nil] : originText;
                    
                    // 原始数据可能较长，因此不直接使用原数据方式
                    for (JGSRSASignatureDigest digest = JGSRSASignatureDigestSHA256; digest <= JGSRSASignatureDigestMD5; digest++) {
                        
                        NSString *publicEnc = [JGSRSAEncryption signatureString:originText privateKey:privateKey digest:digest algorithm:(SecKeyAlgorithm)algorithm];
                        JGSDemoShowConsoleLog(self, @"signature: %@", publicEnc);
                        BOOL verified = [JGSRSAEncryption verifySignature:publicEnc originString:originText publicKey:publicKey digest:digest algorithm:(SecKeyAlgorithm)algorithm];
                        JGSDemoShowConsoleLog(self, @"verified: %@", verified ? @"YES" : @"NO");
                    }
                }
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)showRSAPrivateKeySwap:(NSIndexPath *)indexPath {
    
    NSArray<NSString *> *files = @[@"rsa_private_1024.pem",
                                   @"rsa_private_1024.pem_pkcs8",
                                   @"rsa_private_2048.pem",
                                   @"rsa_private_2048.pem_pkcs8"];
    [files enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:obj ofType:nil];
        NSError *error = nil;
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        
        JGSDemoShowConsoleLog(self, @"%@", obj);
        //[JGSRSAEncryption pkcs1PrivateKeyWithPrivateContent:content];
        //JGSDemoShowConsoleLog(self, @"\n<%@>\n", [JGSRSAEncryption pkcs1PrivateKeyWithPrivateContent:content]);
        JGSDemoShowConsoleLog(self, @"\n<%@>\n<%@>\n", content, [JGSRSAEncryption pkcs1PrivateKeyWithPrivateContent:content]);
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#endif

@end
