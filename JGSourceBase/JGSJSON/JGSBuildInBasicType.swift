//
//  JGSBuildInBasicType.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/26.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

public protocol JGSBuildInBasicType: JGSTransformable {
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
        guard let object = object else { return nil }
        
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
extension UInt: JGSIntegerProtocol {}
extension Int8: JGSIntegerProtocol {}
extension UInt8: JGSIntegerProtocol {}
extension Int16: JGSIntegerProtocol {}
extension UInt16: JGSIntegerProtocol {}
extension Int32: JGSIntegerProtocol {}
extension UInt32: JGSIntegerProtocol {}
extension Int64: JGSIntegerProtocol {}
extension UInt64: JGSIntegerProtocol {}

// MARK: - Bool

extension Bool: JGSBuildInBasicType {
    public static func jg_transform(from object: Any?) -> Bool? {
        guard let object = object else { return nil }

        switch object {
        case let str as String:
            let lower = str.lowercased()
            if ["0", "f", "false", "n", "no"].contains(lower) {
                return false
            } else if ["1", "t", "true", "y", "yes"].contains(lower) {
                return true
            }
            return nil
        case let str as NSString:
            let lower = str.lowercased
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
        guard let object = object else { return nil }

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

fileprivate let JGSNumberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.usesGroupingSeparator = false
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 16 // 最大分数位数
    return formatter
}()

extension String: JGSBuildInBasicType {
    public static func jg_transform(from object: Any?) -> String? {
        guard let object = object else { return nil }

        // JSON Object -> String
        let options: JSONSerialization.WritingOptions = [.sortedKeys, .prettyPrinted]
        if JSONSerialization.isValidJSONObject(object),
           let _data = try? JSONSerialization.data(withJSONObject: object, options: options),
           let json = String(data: _data, encoding: .utf8) {
            return json
        }

        // Data -> String
        if let _data = object as? Data {
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
        case _ as NSNull:
            return nil
        default:
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
            // Check for existing percent escapes first to prevent double-escaping of % character
            if _str.range(of: "%[0-9A-Fa-f]{2}", options: .regularExpression, range: nil, locale: nil) != nil {
                return URL(string: _str)
            } else if let urlEncodedStr = _str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                // We have to use `Foundation.URL` otherwise it conflicts with the variable name.
                return URL(string: urlEncodedStr)
            } else {
                return nil
            }
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
    public static func jg_transform(from object: Any?) -> Optional<Wrapped>? {
        guard let object = object else { return nil }

        if let value = (Wrapped.self as? JGSTransformable.Type)?.jg_transform(from: object) as? Wrapped {
            return Optional(value)
        } else if let value = object as? Wrapped {
            return Optional(value)
        }
        return nil
    }

    func jg_wrappedValue() -> Any? {
        return self.map { wrapped -> Any in
            wrapped as Any
        }
    }

    public func jg_plainValue() -> Any? {
        if let value = jg_wrappedValue() {
            if let transformable = value as? JGSTransformable {
                return transformable.jg_plainValue()
            }
            return value
        }
        return nil
    }
}

// MARK: - Collection Support : Array & Set

public extension Collection {
    static func jg_collectionTransform(from object: Any?) -> [Element]? {
        guard let object = object else { return nil }

        var elements = object as? [Any]
        var options: JSONSerialization.ReadingOptions = [.fragmentsAllowed]
        if #available(iOS 15.0, *) {
            options.insert(.json5Allowed)
        }
        
        // JSON String -> Collection
        if let str = object as? String,
           ["{", "["].filter({ prefix in
               str.hasPrefix(prefix)
           }).count > 0,
           let _data = str.data(using: .utf8),
           let collection = try? JSONSerialization.jsonObject(with: _data, options: options) as? [Any] {
            elements = collection
        }
        // JSON Data -> Collection
        else if let _data = object as? Data,
                ["{", "["].filter({ prefix in
                    _data.firstRange(of: Data(prefix.utf8))?.startIndex == _data.startIndex
                }).count > 0,
                let collection = try? JSONSerialization.jsonObject(with: _data, options: options) as? [Any] {
            elements = collection
        }

        guard let elements = elements else {
            return nil
        }
        
        var result: [Element] = [Element]()
        elements.forEach { (each: Any) in

            // JGSPrivateLog(Element.self)
            // JGSPrivateLog(Element.self as? JGSTransformable.Type)
            if Element.self == Any.self, let element = each as? Element {
                result.append(element)
            } else if let element = (Element.self as? JGSTransformable.Type)?.jg_transform(from: each) as? Element {
                // 转换
                result.append(element)
            } else if let element = each as? Element {
                result.append(element)
            } else {
                JGSPrivateLog("Expect element to be \(type(of: Element.self)) but it's \(type(of: each))")
            }
        }

        return result
    }

    func jg_collectionPlainValue() -> Any? {
        var result: [Element] = [Element]()
        forEach { each in
            if let transformable = each as? JGSTransformable {
                if let transValue = transformable.jg_plainValue() as? Element {
                    // 转换
                    result.append(transValue)
                } else {
                    JGSPrivateLog("Expect element to be \(type(of: Element.self)) but it's \(type(of: transformable))")
                }
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
        return jg_collectionTransform(from: object)
    }

    public func jg_plainValue() -> Any? {
        return jg_collectionPlainValue()
    }
}

extension Set: JGSBuildInBasicType {
    public static func jg_transform(from object: Any?) -> Set<Element>? {
        if let arr = jg_collectionTransform(from: object) {
            return Set(arr)
        }
        return nil
    }

    public func jg_plainValue() -> Any? {
        return jg_collectionPlainValue()
    }
}

// MARK: - Dictionary

extension Dictionary: JGSBuildInBasicType {
    public static func jg_transform(from object: Any?) -> Dictionary<Key, Value>? {
        guard let object = object else { return nil }
        
        var keyValues = object as? [AnyHashable: Any]
        var options: JSONSerialization.ReadingOptions = [.fragmentsAllowed]
        if #available(iOS 15.0, *) {
            options.insert(.json5Allowed)
        }
        
        // JSON String -> Dictionary
        if let str = object as? String,
           ["{", "["].filter({ prefix in
               str.hasPrefix(prefix)
           }).count > 0,
           let data = str.data(using: .utf8),
           let dict = try? JSONSerialization.jsonObject(with: data, options: options) as? [AnyHashable: Any] {
            keyValues = dict
        }
        // JSON Data -> Dictionary
        else if let _data = object as? Data,
                ["{", "["].filter({ prefix in
                    _data.firstRange(of: Data(prefix.utf8))?.startIndex == _data.startIndex
                }).count > 0,
                let dict = try? JSONSerialization.jsonObject(with: _data, options: options) as? [AnyHashable: Any] {
            keyValues = dict
        }
        
        guard let keyValues = keyValues else {
            return nil
        }
        
        var result = [Key: Value]()
        keyValues.forEach { (key: AnyHashable, value: Any) in
            
            if let key = key as? Key {
                if Value.self == Any.self, let value = value as? Value {
                    result[key] = value
                } else if let value = (Value.self as? JGSTransformable.Type)?.jg_transform(from: value) as? Value {
                    // 转换
                    result[key] = value
                } else if let value = value as? Value {
                    result[key] = value
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
