//
//  JGSTransformable.swift
//  Pods
//
//  Created by 梅继高 on 2023/4/7.
//

import Foundation
import UIKit

// 参考 HandyJSON: _Transformable
// https://github.com/alibaba/handyjson

// MARK: - Transformable

internal protocol JGSTransformable {
    // 定义optional必须引入 objc
    // 此处不引入 objc，在扩展中定义方法
    // 继承时重写扩展方法
    //static func jg_transform(from object: Any?) -> Self?
    //optional func jg_plainValue() -> Any?
}

extension JGSTransformable {
    static func jg_transform(from object: Any?) -> Self? {
        guard let object = object else {
            return nil
        }

        if let typeObj = object as? Self {
            return typeObj
        }

        switch self {
        case let _type as JGSBuildInBridgeType.Type:
            return _type.jg_transform(from: object) as? Self
        case let _type as JGSBuildInBasicType.Type:
            return _type.jg_transform(from: object) as? Self
        case let _type as JGSBuildInRawEnumType.Type:
            return _type.jg_transform(from: object) as? Self
        default:
            return nil
        }
    }

    func jg_plainValue() -> Any? {
        switch self {
        case let _rawValue as JGSBuildInBridgeType:
            return _rawValue.jg_plainValue()
        case let _rawValue as JGSBuildInBasicType:
            return _rawValue.jg_plainValue()
        case let _rawValue as JGSBuildInRawEnumType:
            return _rawValue.jg_plainValue()
        default:
            return nil
        }
    }
}

internal protocol JGSBuildInBasicType: JGSTransformable {
    static func jg_transform(from object: Any?) -> Self?
    func jg_plainValue() -> Any?
}

internal protocol JGSBuildInBridgeType: JGSTransformable {
    static func jg_transform(from object: Any?) -> JGSBuildInBridgeType?
    func jg_plainValue() -> Any?
}

internal protocol JGSBuildInRawEnumType: JGSTransformable {
    static func jg_transform(from object: Any?) -> Self?
    func jg_plainValue() -> Any?
}

// MARK: - Integer

internal protocol JGSIntegerProtocol: FixedWidthInteger, JGSBuildInBasicType {
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
    static func jg_transform(from object: Any?) -> Self? {
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

    func jg_plainValue() -> Any? {
        return self
    }
}

extension Int: JGSIntegerProtocol {}
extension UInt: JGSIntegerProtocol {}
extension Int8: JGSIntegerProtocol {}
extension Int16: JGSIntegerProtocol {}
extension Int32: JGSIntegerProtocol {}
extension Int64: JGSIntegerProtocol {}
extension UInt8: JGSIntegerProtocol {}
extension UInt16: JGSIntegerProtocol {}
extension UInt32: JGSIntegerProtocol {}
extension UInt64: JGSIntegerProtocol {}

// MARK: - Bool

extension Bool: JGSBuildInBasicType {
    static func jg_transform(from object: Any?) -> Bool? {
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

    func jg_plainValue() -> Any? {
        return self
    }
}

// MARK: - Float

internal protocol JGSFloatProtocol: LosslessStringConvertible, JGSBuildInBasicType {
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
    static func jg_transform(from object: Any?) -> JGSFloatProtocol? {
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

    func jg_plainValue() -> Any? {
        return self
    }
}

extension Float: JGSFloatProtocol {}
extension Double: JGSFloatProtocol {}

// MARK: - Optional

extension Optional: JGSBuildInBasicType {
    static func jg_transform(from object: Any?) -> Optional<Wrapped>? {
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

    func jg_wrappedValue() -> Any? {
        return self.map { wrapped -> Any in
            wrapped as Any
        }
    }

    func jg_plainValue() -> Any? {
        if let value = jg_wrappedValue() {
            if let transformable = value as? JGSTransformable {
                return transformable.jg_plainValue()
            }
            return value
        }
        return nil
    }
}

// MARK: - JGSBuildInBasicType

extension Collection {
    static func jg_collectionTransform(from object: Any?) -> [Element]? {
        guard let object = object else {
            return nil
        }
        
        // String -> Collection
        if let str = object as? String,
           let data = str.data(using: .utf8),
           let collection = try? JSONSerialization.jsonObject(with: data) as? [Element] {
            return collection
        }
        
        guard let arr = object as? [Any] else {
            JGSPrivateLogD("Expect object to be a collection but it's not")
            return nil
        }
        
        var result: [Element] = [Element]()
        arr.forEach { each in
            JGSPrivateLogD(Element.self)
            JGSPrivateLogD(Element.self as? JGSTransformable.Type)
            if Element.self == Any.self {
                if let element = each as? Element {
                    result.append(element)
                }
            } else if let element = (Element.self as? JGSTransformable.Type)?.jg_transform(from: each) as? Element {
                result.append(element)
            } else if let element = each as? Element {
                result.append(element)
            } else {
                JGSPrivateLogD("Expect element to be an \(type(of: Element.self)) but it's not")
            }
        }
        return result
    }
    
    func jg_collectionPlainValue() -> Any? {
        
        var result: [Element] = [Element]()
        self.forEach { (each) in
            if let transformable = each as? JGSTransformable, let transValue = transformable.jg_plainValue() {
                if let transValue = transValue as? Element {
                    result.append(transValue)
                } else {
                    JGSPrivateLogD("Expect element to be an \(type(of: Element.self)) but it's not")
                }
            } else {
                JGSPrivateLogE("value: \(each) isn't transformable type!")
            }
        }
        return result
    }
}

// MARK: - JGSBuildInRawEnumType

extension RawRepresentable where Self: JGSBuildInRawEnumType {
    internal static func jg_transform(from object: Any?) -> Self? {
        if let transformableType = RawValue.self as? JGSTransformable.Type {
            if let typedValue = transformableType.jg_transform(from: object) {
                return Self(rawValue: typedValue as! RawValue)
            }
        }
        return nil
    }
    
    internal func jg_plainValue() -> Any? {
        return self.rawValue
    }
}
