//
//  JGSBuildInBasicType.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/26.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: _BuiltInBasicType
// https://github.com/alibaba/handyjson

protocol JGSBuildInBasicType: JGSTransformable {
    static func jg_transform(from object: Any?) -> Self?
    func jg_plainValue() -> Any?
}

// MARK: - Integer

protocol JGSIntegerProtocol: FixedWidthInteger, JGSBuildInBasicType {
    // Swift.Math.Integers/FixedWidthInteger
    // @inlinable public init?<S>(_ text: S, radix: Int = 10) where S : StringProtocol
    init?(_ text: String, radix: Int)
    // Foundation/Int
    // @available(swift, deprecated: 4, renamed: "init(truncating:)")
    // public init(_ number: NSNumber)
    // init(_ number: NSNumber)
    // public init(truncating number: NSNumber)
    init(truncating number: NSNumber)
}

extension JGSIntegerProtocol {
    public static func jg_transform(from object: Any?) -> Self? {
        guard let object = object else {
            return nil
        }
        
        switch object {
        case let str as String:
            return Self(str, radix: 10) // 10进制
        case let num as NSNumber:
            return Self(truncating: num)
        default:
            return nil
        }
    }

    public func jg_plainValue() -> Any? {
        return self
    }
}

extension Int: JGSIntegerProtocol {}
extension Int8: JGSIntegerProtocol {}
extension Int16: JGSIntegerProtocol {}
extension Int32: JGSIntegerProtocol {}
extension Int64: JGSIntegerProtocol {}

extension UInt: JGSIntegerProtocol {}
extension UInt8: JGSIntegerProtocol {}
extension UInt16: JGSIntegerProtocol {}
extension UInt32: JGSIntegerProtocol {}
extension UInt64: JGSIntegerProtocol {}

// MARK: - Bool

extension Bool: JGSBuildInBasicType {
    public static func jg_transform(from object: Any?) -> Bool? {
        guard let object = object else {
            return nil
        }

        switch object {
        case let str as String:
            let lower = str.lowercased()
            if ["0", "f", "false", "n", "no"].contains(lower) {
                return false
            } else if ["1", "t", "true", "y", "yes"].contains(lower) {
                return true
            }
            return nil
        case let num as NSNumber:
            return num.boolValue
        default:
            return nil
        }
    }

    public func jg_plainValue() -> Any? {
        return self
    }
}

// MARK: - Float

protocol JGSFloatProtocol: LosslessStringConvertible, JGSBuildInBasicType {
    // Swift.Math.Floating/Float
    // @inlinable public init?<S>(_ text: S) where S : StringProtocol
    init?(_ text: String)
    // Foundation/Int
    // @available(swift, deprecated: 4, renamed: "init(truncating:)")
    // public init(_ number: NSNumber)
    // init(_ number: NSNumber)
    // public init(truncating number: NSNumber)
    init(truncating number: NSNumber)
}

extension JGSFloatProtocol {
    public static func jg_transform(from object: Any?) -> Self? {
        guard let object = object else {
            return nil
        }

        switch object {
        case let str as String:
            return Self(str)
        case let num as NSNumber:
            return Self(truncating: num)
        default:
            return nil
        }
    }
    
    public func jg_plainValue() -> Any? {
        return self
    }
}

extension Float: JGSFloatProtocol {}
extension Double: JGSFloatProtocol {}

// MARK: - String & URL
extension String: JGSBuildInBasicType {
    public static func jg_transform(from object: Any?) -> String? {
        guard let object = object else {
            return nil
        }
        
        switch object {
        case let str as String:
            return str
        case let num as NSNumber:
            // Boolean Type Inside
            if NSStringFromClass(type(of: num)) == "__NSCFBoolean" {
                return num.boolValue ? "true" : "false"
            }
            return num.stringValue
        case _ as NSNull:
            return nil
        case let _data as Data:
            guard _data.count > 0 else {
                return ""
            }
            
            // UTF8 String
            if let utf8 = String(data: _data, encoding: .utf8) {
                return utf8
            }
            
            // 如不能直接转UTF8字符串，考虑可能是加密数据
            // 进行Base64编码为UTF8字符串（Base64编码后的数据为UTF8编码）
            // .endLineWithLineFeed: 保持Android、ios、后台统一
            return _data.base64EncodedString(options: [.endLineWithLineFeed])
        default:
            // JSON Object -> String
            if JSONSerialization.isValidJSONObject(object) {
                var options: JSONSerialization.WritingOptions = [.sortedKeys]
                if #available(iOS 13.0, *) {
                    options.insert(.withoutEscapingSlashes)
                }
                if let _data = try? JSONSerialization.data(withJSONObject: object, options: options),
                   let json = String(data: _data, encoding: .utf8) {
                    return json
                }
            }
            return "\(object)"
        }
    }

    public func jg_plainValue() -> Any? {
        return self
    }
}

extension URL: JGSBuildInBasicType {
    public static func jg_transform(from object: Any?) -> URL? {
        guard let object = object else { return nil }

        switch object {
        case let _url as URL:
            return _url
        case let _str as String:
            var urlStr = _str
            // Query格式不符合规范处理（缺少?而只有&）
            // 此处要求作为URL的各部分包含特殊字符“&”与”?“的内容必须已进行url编码处理
            if let firstAndRange = urlStr.range(of: "&"),
               !firstAndRange.isEmpty && urlStr.range(of: "?") == nil {
                urlStr.replaceSubrange(firstAndRange, with: "?")
            }

            var urlCharSet: CharacterSet = .urlHostAllowed
            urlCharSet.formUnion(.urlPathAllowed)
            urlCharSet.formUnion(.urlQueryAllowed)
            urlCharSet.formUnion(.urlFragmentAllowed)
            urlCharSet.formUnion(.urlUserAllowed)
            urlCharSet.formUnion(.urlPasswordAllowed)

            // query参数未进行url编码，则进行编码
            if urlStr.range(of: "%[0-9A-Fa-f]{2}", options: .regularExpression, range: nil, locale: nil) == nil,
               let urlEncodedStr = urlStr.addingPercentEncoding(withAllowedCharacters: urlCharSet) {
                JGSLogD("urlEncodedStr: \(urlEncodedStr)")
                JGSPrivateLog("urlEncodedStr: \(urlEncodedStr)")
                // urlStr = urlEncodedStr
            }

            // 正则表达式匹配查找中文字符串、不可见字符串，并进行替换
            ["[[\u{4e00}-\u{9fa5}][\u{3002}\u{ff1b}\u{ff0c}\u{ff1a}\u{201c}\u{201d}\u{ff08}\u{ff09}\u{3001}\u{ff1f}\u{300a}\u{300b}]]+", // 中文+中文符号：。 ； ， ： “ ”（ ） 、 ？ 《 》
             "\\s+", // 不可见字符正则表达式
            ].forEach { regStr in
                if let regex = try? NSRegularExpression(pattern: regStr, options: .caseInsensitive) {
                    var matches = regex.matches(in: urlStr, options: [], range: NSRange(location: 0, length: urlStr.count))
                    while let match = matches.first {
                        if let lower = urlStr.index(urlStr.startIndex, offsetBy: match.range.location, limitedBy: urlStr.endIndex),
                           let upper = urlStr.index(urlStr.startIndex, offsetBy: match.range.location + match.range.length, limitedBy: urlStr.endIndex) {
                            let oriStr = String(urlStr[lower ..< upper])
                            if let encStr = oriStr.addingPercentEncoding(withAllowedCharacters: urlCharSet) {
                                // 替换
                                urlStr = urlStr.replacingOccurrences(of: oriStr, with: encStr)

                                // 每次替换后需在新字符串中查找下一串
                                matches = regex.matches(in: urlStr, options: [], range: NSRange(location: 0, length: urlStr.count))
                            }
                        }
                    }
                }
            }
            return URL(string: urlStr)
        default:
            return nil
        }
    }

    public func jg_plainValue() -> Any? {
        return self.absoluteString
    }
}

// MARK: - Optional

extension Optional: JGSBuildInBasicType {
    public static func jg_transform(from object: Any?) -> Optional? {
        guard let object = object else {
            return nil
        }
        
        if let value = (Wrapped.self as? JGSTransformable.Type)?.jg_transform(from: object) as? Wrapped {
            return Optional(value)
        } else if let value = object as? Wrapped {
            return Optional(value)
        }
        return nil
    }

    private func _wrappedValue() -> Any? {
        return self.map { wrapped -> Any in
            wrapped as Any
        }
    }

    public func jg_plainValue() -> Any? {
        if let value = _wrappedValue() {
            if let transformable = value as? JGSTransformable {
                return transformable.jg_plainValue()
            }
            return value
        }
        return nil
    }
}

// MARK: - Collection Support : Array & Set

extension Collection {
    static func _collectionTransform(from object: Any?) -> [Element]? {
        guard let object = object else {
            return nil
        }
        
        var elements = object as? [Any]
        var options: JSONSerialization.ReadingOptions = [.fragmentsAllowed]
        if #available(iOS 15.0, *) {
            options.insert(.json5Allowed)
        }
        
        // JSON String -> Collection
        if let str = (object as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
           ["{", "["].filter({ prefix in
               str.hasPrefix(prefix)
           }).count > 0,
           let _data = str.data(using: .utf8),
           let collection = try? JSONSerialization.jsonObject(with: _data, options: options) as? [Any] {
            elements = collection
        }
        // JSON Data -> Collection
        else if let _data = object as? Data,
                let str = String(data: _data, encoding: .utf8) {
            return _collectionTransform(from: str)
        }
        
        guard let elements = elements else {
            return nil
        }
        
        var result: [Element] = []
        elements.forEach { each in
            
            if Element.self == Any.self, let element = each as? Element {
                result.append(element)
            } else if let element = (Element.self as? JGSTransformable.Type)?.jg_transform(from: each) as? Element {
                result.append(element)
            } else if let element = each as? Element {
                result.append(element)
            } else {
                JGSPrivateLog("Expect element to be \(type(of: Element.self)) but it's \(type(of: each))")
            }
        }

        return result
    }
    
    func _collectionPlainValue() -> Any? {
        var result: [Any] = [Any]()
        forEach { each in
            if let transformable = each as? JGSTransformable,
               let transValue = transformable.jg_plainValue() {
                result.append(transValue)
            } else {
                JGSPrivateLog("value: \(type(of: each)) isn't transformable type!")
            }
        }
        return result
    }
}

// MARK: - Array & Set

extension Array: JGSBuildInBasicType {
    public static func jg_transform(from object: Any?) -> [Element]? {
        return _collectionTransform(from: object)
    }

    public func jg_plainValue() -> Any? {
        return _collectionPlainValue()
    }
}

extension Set: JGSBuildInBasicType {
    public static func jg_transform(from object: Any?) -> Set<Element>? {
        if let arr = _collectionTransform(from: object) {
            return Set(arr)
        }
        return nil
    }

    public func jg_plainValue() -> Any? {
        return _collectionPlainValue()
    }
}

// MARK: - Dictionary

extension Dictionary: JGSBuildInBasicType {
    public static func jg_transform(from object: Any?) -> Dictionary<Key, Value>? {
        guard let object = object else {
            return nil
        }
        
        var keyValues = object as? [AnyHashable: Any]
        var options: JSONSerialization.ReadingOptions = [.fragmentsAllowed]
        if #available(iOS 15.0, *) {
            options.insert(.json5Allowed)
        }
        
        // JSON String -> Dictionary
        if let str = (object as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
           ["{", "["].filter({ prefix in
               str.hasPrefix(prefix)
           }).count > 0,
           let data = str.data(using: .utf8),
           let dict = try? JSONSerialization.jsonObject(with: data, options: options) as? [AnyHashable: Any] {
            keyValues = dict
        }
        // JSON Data -> Dictionary
        else if let _data = object as? Data,
                let str = String(data: _data, encoding: .utf8) {
            return jg_transform(from: str)
        }
        
        guard let keyValues = keyValues else {
            return nil
        }
        
        var result: [Key: Value] = [:]
        keyValues.forEach { (key: AnyHashable, value: Any) in
            
            if let sKey = key as? Key {
                if Value.self == Any.self, let value = value as? Value {
                    result[sKey] = value
                } else if let nValue = (Value.self as? JGSTransformable.Type)?.jg_transform(from: value) as? Value {
                    result[sKey] = nValue
                } else if let nValue = value as? Value {
                    result[sKey] = nValue
                } else {
                    JGSPrivateLog("Expect value to be \(type(of: Value.self)) but it's \(type(of: value))")
                }
            } else {
                JGSPrivateLog("Expect key to be any \(type(of: Key.self)) but it's \(type(of: key))")
            }
        }
        return result
    }

    public func jg_plainValue() -> Any? {
        var result = [AnyHashable: Value]()
        forEach { pair in
            if let transformable = pair.value as? JGSTransformable {
                if let transValue = transformable.jg_plainValue() as? Value {
                    // 转换
                    result[pair.key] = transValue
                } else {
                    JGSPrivateLog("Expect value to be \(type(of: Value.self)) but it's \(type(of: transformable))")
                }
            } else {
                JGSPrivateLog("value: \(type(of: pair.value)) isn't transformable type!")
            }
        }
        return result
    }
}
