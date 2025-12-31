//
//  Data+JGSBase.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/3/27.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation
import CryptoKit
import CommonCrypto

public
extension Data {
    
    /// UTF8字符串
    var jg_utf8String: String? {
        return String(data: self, encoding: .utf8)
    }
    
    // MARK: - Bae64
    /// Base64编码
    var jg_base64EncodeData: Data {
        return jg_base64EncodeData()
    }
    
    /// Base64编码
    /// - Parameter options: 编码选项，默认 [] - 编码内容不换行
    /// - Returns: Data
    func jg_base64EncodeData(_ options: Data.Base64EncodingOptions = []) -> Data {
        return base64EncodedData(options: options)
    }
    
    /// Base64编码
    var jg_base64EncodeString: String {
        return jg_base64EncodeString()
    }
        
    /// Base64编码
    /// - Parameter options: 编码选项，默认 [] - 编码内容不换行
    /// - Returns: String-UTF8
    func jg_base64EncodeString(_ options: Data.Base64EncodingOptions = []) -> String {
        return base64EncodedString(options: options)
    }
    
    /// Base64解码
    var jg_base64DecodeData: Data? {
        return jg_base64DecodeData()
    }
    
    /// Base64解码
    /// - Parameter options: 解码选项，默认 [.ignoreUnknownCharacters]
    /// - Returns: Data
    func jg_base64DecodeData(_ options: Data.Base64DecodingOptions = [.ignoreUnknownCharacters]) -> Data? {
        return Data(base64Encoded: self, options: options)
    }
    
    /// Base64解码
    var jg_base64DecodeString: String? {
        return jg_base64DecodeString()
    }
    
    /// Base64解码
    /// - Parameter options: 解码选项，默认 [.ignoreUnknownCharacters]
    /// - Returns: String
    func jg_base64DecodeString(_ options: Data.Base64DecodingOptions = [.ignoreUnknownCharacters]) -> String? {
        return jg_base64DecodeData(options)?.jg_utf8String
    }
    
    // MARK: - MD5
    /// 获取MD5字符串
    @available(*, deprecated, message: "Weak hashing algorithm, it is recommended to use CC_SHA256 algorithm for data hashing operation")
    var jg_md5: String {
        return jg_md5()
    }
    
    /// 获取MD5
    /// - Parameter style: 字符串大小写风格
    /// - Returns: String
    @available(*, deprecated, message: "Weak hashing algorithm, it is recommended to use CC_SHA256 algorithm for data hashing operation")
    func jg_md5(_ style: JGSStringCaseStyle = .caseDefault) -> String {
        return jg_hash(.md5, style)
    }
    
    // MARK: - SHA
    
    /// 获取SHA128
    @available(*, deprecated, message: "Weak hashing algorithm, it is recommended to use CC_SHA256 algorithm for data hashing operation")
    var jg_sha128: String {
        return jg_sha128()
    }
    
    /// 获取SHA128
    /// - Parameter style: 字符串大小写风格
    /// - Returns: String
    @available(*, deprecated, message: "Weak hashing algorithm, it is recommended to use CC_SHA256 algorithm for data hashing operation")
    func jg_sha128(_ style: JGSStringCaseStyle = .caseDefault) -> String {
        return jg_hash(.SHA128, style)
    }
    
    /// 获取SHA256
    var jg_sha256: String {
        return jg_sha256()
    }
    
    /// 获取SHA256
    /// - Parameter style: 字符串大小写风格
    /// - Returns: String
    func jg_sha256(_ style: JGSStringCaseStyle = .caseDefault) -> String {
        return jg_hash(.SHA256, style)
    }
    
    /// 获取SHA384
    var jg_sha384: String {
        return jg_sha384()
    }
    
    /// 获取SHA384
    /// - Parameter style: 字符串大小写风格
    /// - Returns: String
    func jg_sha384(_ style: JGSStringCaseStyle = .caseDefault) -> String {
        return jg_hash(.SHA384, style)
    }
    
    /// 获取SHA512
    var jg_sha512: String {
        return jg_sha512()
    }
    
    /// 获取SHA512
    /// - Parameter style: 字符串大小写风格
    /// - Returns: String
    func jg_sha512(_ style: JGSStringCaseStyle = .caseDefault) -> String {
        return jg_hash(.SHA512, style)
    }
    
    // MARK: - HASH
    private func jg_hash(_ type: JGSHASHStringType, _ style: JGSStringCaseStyle) -> String {
        
        if #available(iOS 13.0, *) {
            let digest: any Digest = {
                switch type {
                case .md5:
                    return Insecure.MD5.hash(data: self)
                case .SHA128:
                    return Insecure.SHA1.hash(data: self)
                case .SHA256:
                    return SHA256.hash(data: self)
                case .SHA384:
                    return SHA384.hash(data: self)
                case .SHA512:
                    return SHA512.hash(data: self)
                @unknown default:
                    return SHA512.hash(data: self)
                }
            }()
            
            let hash = digest.map { String(format: Bool.random() ? "%02hhx" : "%02hhX", $0) }.joined()
            switch style {
            case .lowercase:
                return hash.lowercased()
            case .uppercase:
                return hash.uppercased()
            case .randomCase:
                return hash
            @unknown default:
                return hash
            }
        }
        
        let digest = {
            switch type {
            case .md5:
                var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
                _ = withUnsafeBytes { bytes in
                    CC_MD5(bytes.baseAddress, CC_LONG(count), &digest)
                }
                return digest
            case .SHA128:
                var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
                _ = withUnsafeBytes { bytes in
                    CC_SHA1(bytes.baseAddress, CC_LONG(count), &digest)
                }
                return digest
            case .SHA256:
                var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
                _ = withUnsafeBytes { bytes in
                    CC_SHA256(bytes.baseAddress, CC_LONG(count), &digest)
                }
                return digest
            case .SHA384:
                var digest = [UInt8](repeating: 0, count: Int(CC_SHA384_DIGEST_LENGTH))
                _ = withUnsafeBytes { bytes in
                    CC_SHA384(bytes.baseAddress, CC_LONG(count), &digest)
                }
                return digest
            case .SHA512:
                var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
                _ = withUnsafeBytes { bytes in
                    CC_SHA512(bytes.baseAddress, CC_LONG(count), &digest)
                }
                return digest
            @unknown default:
                var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
                _ = withUnsafeBytes { bytes in
                    CC_SHA512(bytes.baseAddress, CC_LONG(count), &digest)
                }
                return digest
            }
        }()
        
        let hash = digest.map { String(format: Bool.random() ? "%02hhx" : "%02hhX", $0) }.joined()
        switch style {
        case .lowercase:
            return hash.lowercased()
        case .uppercase:
            return hash.uppercased()
        case .randomCase:
            return hash
        @unknown default:
            return hash
        }
    }
    
    // MARK: - Hex
    /// 获取16进制字符串
    var jg_hex: String {
        return jg_hex()
    }
    
    /// 获取16进制字符串
    /// - Parameter style: 字符串大小写风格
    /// - Returns: String
    func jg_hex(_ style: JGSStringCaseStyle = .randomCase) -> String {
        
        let hex = map { String(format: Bool.random() ? "%02hhx" : "%02hhX", $0) }.joined()
        switch style {
        case .lowercase:
            return hex.lowercased()
        case .uppercase:
            return hex.uppercased()
        case .randomCase:
            return hex
        @unknown default:
            return hex
        }
    }
}
