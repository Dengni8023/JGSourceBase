//
//  String+JGSBase.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/7.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

// MARK: - JGSBuildInBasicType

fileprivate let JGSNumberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.usesGroupingSeparator = false
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 16 // 最大分数位数
    return formatter
}()

extension String: JGSBuildInBasicType {
    
    static func jg_transform(from object: Any?) -> String? {
        return jg_transform(from: object, jsonOptions: [.sortedKeys, .prettyPrinted])
    }
    
    static func jg_transform(from object: Any?, jsonOptions: JSONSerialization.WritingOptions) -> String? {
        guard let object = object else {
            return nil
        }
        
        // JSON Object
        if JSONSerialization.isValidJSONObject(object) {
            if let data = try? JSONSerialization.data(withJSONObject: object, options: jsonOptions),
               let json = String(data: data, encoding: .utf8) {
                return json
            }
        }
        
        switch object {
        case let str as String:
            return str
        case let num as NSNumber:
            // Boolean Type Inside
            let boolean = true
            if type(of: num) == type(of: boolean) {
                return num.boolValue ? "true" : "false"
            }
            return JGSNumberFormatter.string(from: num)
        case let _data as Data:
            if let utf8 = String(data: _data, encoding: .utf8) {
                return utf8
            } else {
                // 如不能直接转UTF8字符串，考虑可能是加密数据
                // 进行Base64编码为UTF8字符串（Base64编码后的数据为UTF8编码）
                // .endLineWithLineFeed: 保持Android、ios、后台统一
                let base64 = _data.base64EncodedString(options: .endLineWithLineFeed)
                return base64
            }
        case _ as NSNull:
            return nil
        default:
            return "\(object)"
        }
    }

    func jg_plainValue() -> Any? {
        return self
    }
}

// MARK: - JGSBuildInBridgeType

extension NSString: JGSBuildInBridgeType {
    
    static func jg_transform(from object: Any?) -> JGSBuildInBridgeType? {
        if let str = String.jg_transform(from: object) {
            return NSString(string: str)
        }
        return nil
    }
    
    func jg_plainValue() -> Any? {
        return self
    }
}
