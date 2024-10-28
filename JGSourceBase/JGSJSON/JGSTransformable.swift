//
//  JGSTransformable.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/7.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: Transformable.swift
// https://github.com/alibaba/handyjson

public protocol JGSTransformable: JGSMeasurable {
    // 定义optional必须引入 objc
    // 此处不引入 objc，在扩展中定义方法
    // 继承时重写扩展方法
    // 为区分内外部扩展方法，内部扩展方法使用“_”开头，外部可使用扩展使用“jg_”开头
}

public extension JGSTransformable {
    static func jg_transform(from object: Any?) -> Self? {
        guard let object = object else { return nil }
        
        if let typeObj = object as? Self {
            return typeObj
        }
        
        switch self {
        case let type as JGSCustomTransform.Type:
            return type.jg_transform(from: object) as? Self
        case let type as JGSCustomModelType.Type:
            return type._transform(from: object) as? Self
        case let type as JGSBuildInBridgeType.Type:
            return type._transform(from: object) as? Self
        case let type as JGSBuildInBasicType.Type:
            return type._transform(from: object) as? Self
        case let type as JGSRawRepresentable.Type:
            return type.jg_transform(from: object) as? Self
        default:
            return nil
        }
    }
    
    func jg_plainValue() -> Any? {
        switch self {
        case let rawValue as JGSCustomTransform:
            return rawValue.jg_plainValue()
        case let rawValue as JGSCustomModelType:
            return rawValue._plainValue()
        case let rawValue as JGSBuildInBridgeType:
            return rawValue._plainValue()
        case let rawValue as JGSBuildInBasicType:
            return rawValue._plainValue()
        case let rawValue as JGSRawRepresentable:
            return rawValue.jg_plainValue()
        default:
            return nil
        }
    }
}

// MARK: - Easy Trans
/// 系统内置类型间互转快捷方法
public extension JGSTransformable {
    
    // MARK: - Int, Int8, Int16, Int32, Int64

    var jg_int: Int? { return Int.jg_transform(from: self) }
    var jg_intValue: Int { return jg_int ?? 0 }
    var jg_integerValue: NSInteger { return jg_intValue }
    var jg_uInt: UInt? { return UInt.jg_transform(from: self) }
    var jg_uIntValue: UInt { return jg_uInt ?? 0 }

    var jg_int8: Int8? { return Int8.jg_transform(from: self) }
    var jg_int8Value: Int8 { return jg_int8 ?? 0 }
    var jg_uInt8: UInt8? { return UInt8.jg_transform(from: self) }
    var jg_uInt8Value: UInt8 { return jg_uInt8 ?? 0 }

    var jg_int16: Int16? { return Int16.jg_transform(from: self) }
    var jg_int16Value: Int16 { return jg_int16 ?? 0 }
    var jg_uInt16: UInt16? { return UInt16.jg_transform(from: self) }
    var jg_uInt16Value: UInt16 { return jg_uInt16 ?? 0 }

    var jg_int32: Int32? { return Int32.jg_transform(from: self) }
    var jg_int32Value: Int32 { return jg_int32 ?? 0 }
    var jg_uInt32: UInt32? { return UInt32.jg_transform(from: self) }
    var jg_uInt32Value: UInt32 { return jg_uInt32 ?? 0 }

    var jg_int64: Int64? { return Int64.jg_transform(from: self) }
    var jg_int64Value: Int64 { return jg_int64 ?? 0 }
    var jg_uInt64: UInt64? { return UInt64.jg_transform(from: self) }
    var jg_uInt64Value: UInt64 { return jg_uInt64 ?? 0 }

    // MARK: - Double, Float, Bool

    var jg_double: Double? { return Double.jg_transform(from: self) }
    var jg_doubleValue: Double { return jg_double ?? 0.0 }
    var jg_float: Float? { return Float.jg_transform(from: self) }
    var jg_floatValue: Float { return jg_float ?? 0.0 }
    var jg_bool: Bool? { return Bool.jg_transform(from: self) }
    var jg_boolValue: Bool { return jg_bool ?? false }

    // MARK: - String, Number, Null, URL

    var jg_string: String? { return String.jg_transform(from: self) }
    var jg_stringValue: String { return jg_string ?? "" }
    var jg_number: NSNumber? { return NSNumber.jg_transform(from: self) }
    var jg_numberValue: NSNumber { return jg_number ?? NSNumber(value: 0.0) }
    var jg_URL: URL? { return URL.jg_transform(from: self) }
    
    // MARK: - Array, Dict

    func jg_array<Ele>() -> Array<Ele>? {
        return Array<Ele>.jg_transform(from: self)
    }

    func jg_arrayValue<Ele>() -> Array<Ele> {
        return jg_array() ?? []
    }
    
    func jg_dictionary<K, V>() -> [K: V]? {
        return [K: V].jg_transform(from: self)
    }
    
    func jg_dictionaryValue<K, V>() -> [K: V] {
        return jg_dictionary() ?? [:]
    }
}
