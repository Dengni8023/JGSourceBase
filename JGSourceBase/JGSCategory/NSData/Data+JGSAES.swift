//
//  Data+JGSAES.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/3/27.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation
import CryptoKit

public
extension Data {
    
    enum JGSAESOperation: Int {
        case encrypt = 0 // AES加密
        case decrypt // AES解密
    }
    
    // MARK: - Encrypt
    /// AES128加密后NSData，CBC / PKCS7Padding，加密入参为原始Data
    /// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param iv 偏移向量，可为空
    /// @return 加密后Data / Base64编码的String，Data不可转换为UTF8字符串，可转换为base64字符串
    func jg_AES128Encrypt<T>(key: String, iv: String? = nil) -> T? {
        return jg_AESOperation(operation: .encrypt, keySize: 128 / 8, key: key, iv: iv)
    }

    /// AES128加密后NSData，CBC / PKCS7Padding，加密入参为原始NSData
    /// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param iv 偏移向量，可为空
    /// @return NSString 加密后NSData，转换为base64字符串
//    - (nullable NSString *)jg_AES128EncryptStringWithKey:(NSString *)key iv:(nullable NSString *)iv;

    /// AES256加密后NSData，CBC / PKCS7Padding，加密入参为原始NSData
    /// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param iv 偏移向量，可为空
    /// @return NSData 加密后NSData，不可转换为UTF8字符串，可转换为base64字符串
//    - (nullable NSData *)jg_AES256EncryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

    /// AES256加密后NSData，CBC / PKCS7Padding，加密入参为原始NSData
    /// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param iv 偏移向量，可为空
    /// @return NSString 加密后NSData转换为base64字符串
//    - (nullable NSString *)jg_AES256EncryptStringWithKey:(NSString *)key iv:(nullable NSString *)iv;

    // MARK: - Decrypt
    /// AES128解密，CBC / PKCS7Padding，解密入参为原始NSData
    /// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param iv 偏移向量，可为空
    /// @return NSData 解密获取的原始NSData
//    - (nullable NSData *)jg_AES128DecryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

    /// AES128解密，CBC / PKCS7Padding，解密入参为原始NSData
    /// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param iv 偏移向量，可为空
    /// @return NSString 解密获取的原始NSData转换为UTF8字符串
//    - (nullable NSString *)jg_AES128DecryptStringWithKey:(NSString *)key iv:(nullable NSString *)iv;

    /// AES256解密，CBC / PKCS7Padding，解密入参为原始NSData
    /// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param iv 偏移向量，可为空
    /// @return NSData 解密获取的原始NSData
//    - (nullable NSData *)jg_AES256DecryptWithKey:(NSString *)key iv:(nullable NSString *)iv;

    /// AES256解密，CBC / PKCS7Padding，解密入参为原始NSData
    /// @param key 加密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param iv 偏移向量，可为空
    /// @return NSString 解密获取的原始NSData转换为UTF8字符串
//    - (nullable NSString *)jg_AES256DecryptStringWithKey:(NSString *)key iv:(nullable NSString *)iv;

    // MARK: - Operation
    /// AES加解密，加密入参为原始NSData，解密入参为加密后NSData
    /// iOS只有CBC和ECB模式，iOS13之后内部自动识别
    /// @param operation kCCEncrypt - 加密，kCCDecrypt - 解密
    /// @param keyLength  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param key 加解密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param iv 偏移向量，可为空
    /// @param options 加密模式以及填充模式，默认加密模式为CBC-需要IV，可选ECB-不需要IV，填充模式PKCS7
    /// @return NSData 加密结果为NSData，不可转换为UTF8字符串，可转换为base64字符串；解密结果为原始NSData
    func jg_AESOperation<T>(operation: JGSAESOperation, keySize: Int, key: String, iv: String?, options: CCOptions) -> T? {
        guard T.self is Data.Type || T.self is String.Type else {
            return nil
        }
        
        // key
        guard let keyData = key.data(using: .utf8) else {
            return nil
        }
        let symKey = SymmetricKey(data: keyData)
        
        // key长度检查
        let validKeySize: [SymmetricKeySize] = [.bits128, .bits192, .bits256]
        assert(validKeySize.filter({ size in
            size.bitCount == symKey.bitCount
        }).count > 0, "The keyLength of AES must be \(validKeySize.map { "\($0.bitCount)" }.joined(separator: ", "))")
        assert(key.count == keySize, "The key length of AES-\(keySize * 8) must be \(keySize)")
        
        // iv
        let symIv: AES.GCM.Nonce? = {
            guard let ivData = iv?.data(using: .utf8) else {
                return nil
            }
            return try? AES.GCM.Nonce(data: ivData)
        }()
        
        switch operation {
        case .encrypt:
            let combined = try? AES.GCM.seal(self, using: symKey, nonce: symIv).combined
            if T.self is Data.Type {
                return combined as? T
            }
            return combined?.base64EncodedString() as? T
        case .decrypt:
            guard let sealedBox: AES.GCM.SealedBox? = {
                if let symIv = symIv {
                    return try? AES.GCM.SealedBox(nonce: symIv, ciphertext: self, tag: nil)
                }
                return try? AES.GCM.SealedBox(combined: self)
            }(),
                  let plainData = try? AES.GCM.open(sealedBox, using: SymmetricKey(data: keyData))
            else {
                return nil
            }
            T
            if T.self is Data.Type {
                return plainData as? T
            }
            return String(data: plainData, encoding: .utf8) as? T
        }
    }

    /// AES加解密，iOS只有CBC和ECB模式，加密入参为原始NSData，解密入参为加密后NSData
    /// @param operation kCCEncrypt - 加密，kCCDecrypt - 解密
    /// @param keyLength  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param key 加解密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param iv 偏移向量，可为空
    /// @param options 加密模式以及填充模式，默认加密模式为CBC-需要IV，可选ECB-不需要IV，填充模式PKCS7
    /// @return NSString 加密结果为NSData转换为base64字符串；解密结果为原始NSData转换为UTF8字符串
//    - (nullable NSString *)jg_AESStringWithOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(nullable NSString *)iv options:(CCOptions)options;

    /// AES加解密，CBC / PKCS7Padding，加密入参为原始NSData，解密入参为加密后NSData
    /// @param operation kCCEncrypt - 加密，kCCDecrypt - 解密
    /// @param keyLength  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param key 加解密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param iv 偏移向量，可为空
    /// @return NSData 加密结果为NSData，不可转换为UTF8字符串，可转换为base64字符串；解密结果为原始NSData
    func jg_AESOperation<T>(operation: JGSAESOperation, keySize: Int, key: String, iv: String?) -> T? {
        return jg_AESOperation(operation: operation, keySize: keySize, key: key, iv: iv, options: [])
    }

    /// AES加解密，CBC / PKCS7Padding，加密入参为原始NSData，解密入参为加密后NSData
    /// @param operation kCCEncrypt - 加密，kCCDecrypt - 解密
    /// @param keyLength  kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param key 加解密key，不可为空，key长度需与对应的AES加密方式要求长度保持一致：kCCKeySizeAES128 - 16 / kCCKeySizeAES256 - 32
    /// @param iv 偏移向量，可为空
    /// @return NSString 加密结果为NSData转换为base64字符串；解密结果为原始NSData转换为UTF8字符串
//    - (nullable NSString *)jg_AESStringWithOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(nullable NSString *)iv;

}
