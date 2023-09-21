//
//  JGSSwiftyJSON.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/26.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation
import UIKit

// 参考
// SwiftyJSON: https://github.com/SwiftyJSON/SwiftyJSON
// HandyJSON: https://github.com/alibaba/handyjson

public protocol JGSSwiftyJSON {
    // MARK: - Int, UInt, Int8, Int16, Int32, Int64

    var jg_int: Int? { get }
    var jg_intValue: Int { get }
    var jg_integerValue: NSInteger { get }
    var jg_uInt: UInt? { get }
    var jg_uIntValue: UInt { get }

    var jg_int8: Int8? { get }
    var jg_int8Value: Int8 { get }
    var jg_uInt8: UInt8? { get }
    var jg_uInt8Value: UInt8 { get }

    var jg_int16: Int16? { get }
    var jg_int16Value: Int16 { get }
    var jg_uInt16: UInt16? { get }
    var jg_uInt16Value: UInt16 { get }

    var jg_int32: Int32? { get }
    var jg_int32Value: Int32 { get }
    var jg_uInt32: UInt32? { get }
    var jg_uInt32Value: UInt32 { get }

    var jg_int64: Int64? { get }
    var jg_int64Value: Int64 { get }
    var jg_uInt64: UInt64? { get }
    var jg_uInt64Value: UInt64 { get }

    // MARK: - Double, Float, Bool

    var jg_double: Double? { get }
    var jg_doubleValue: Double { get }
    var jg_float: Float? { get }
    var jg_floatValue: Float { get }
    var jg_bool: Bool? { get }
    var jg_boolValue: Bool { get }

    // MARK: - String, Number, Null, URL

    var jg_string: String? { get }
    var jg_stringValue: String { get }
    var jg_number: NSNumber? { get }
    var jg_numberValue: NSNumber { get }
    var jg_URL: URL? { get }
    var jg_null: NSNull? { get }

    // MARK: - Array, Dict

    var jg_array: Array<any JGSSwiftyJSON>? { get }
    var jg_arrayValue: Array<any JGSSwiftyJSON> { get }
    var jg_dictionary: [String: any JGSSwiftyJSON]? { get }
    var jg_dictionaryValue: [String: any JGSSwiftyJSON] { get }
}

public extension JGSSwiftyJSON {
    
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
    var jg_null: NSNull? { return NSNull.jg_transform(from: self) }

    // MARK: - Array, Dict

    var jg_array: Array<any JGSSwiftyJSON>? {
        return Array<any JGSSwiftyJSON>.jg_transform(from: self)
    }

    var jg_arrayValue: Array<any JGSSwiftyJSON> {
        return jg_array ?? []
    }

    var jg_dictionary: [String: any JGSSwiftyJSON]? {
        return [String: any JGSSwiftyJSON].jg_transform(from: self)
    }

    var jg_dictionaryValue: [String: any JGSSwiftyJSON] {
        return jg_dictionary ?? [:]
    }

    fileprivate func jg_sortedJSON() -> String {
        guard JSONSerialization.isValidJSONObject(self) else {
            return ""
        }
        var options: JSONSerialization.WritingOptions = [.sortedKeys, .prettyPrinted]
        if #available(iOS 13.0, *) {
            options.insert(.withoutEscapingSlashes)
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: self, options: options) {
            return String(data: data, encoding: .utf8) ?? ""
        }
        return ""
    }
}

// MARK: - Comparable

public protocol JGSSwiftyComparable: JGSSwiftyJSON, Comparable {}
public extension JGSSwiftyComparable {
    static func < (lhs: Self, rhs: Self) -> Bool { return lhs < rhs }
    static func <= (lhs: Self, rhs: Self) -> Bool { return lhs <= rhs }
    static func >= (lhs: Self, rhs: Self) -> Bool { return lhs >= rhs }
    static func > (lhs: Self, rhs: Self) -> Bool { return lhs > rhs }
    static func == (lhs: Self, rhs: Self) -> Bool { return lhs == rhs }
}

// MARK: - BuildInType

extension Int: JGSSwiftyJSON {}
extension UInt: JGSSwiftyJSON {}
extension Int8: JGSSwiftyJSON {}
extension UInt8: JGSSwiftyJSON {}
extension Int16: JGSSwiftyJSON {}
extension UInt16: JGSSwiftyJSON {}
extension Int32: JGSSwiftyJSON {}
extension UInt32: JGSSwiftyJSON {}
extension Int64: JGSSwiftyJSON {}
extension UInt64: JGSSwiftyJSON {}

extension Double: JGSSwiftyJSON {}
extension Float: JGSSwiftyJSON {}
extension Bool: JGSSwiftyComparable {
    public static func < (lhs: Self, rhs: Self) -> Bool { return lhs.jg_intValue < rhs.jg_intValue }
    public static func <= (lhs: Self, rhs: Self) -> Bool { return lhs.jg_intValue <= rhs.jg_intValue }
    public static func >= (lhs: Self, rhs: Self) -> Bool { return lhs.jg_intValue >= rhs.jg_intValue }
    public static func > (lhs: Self, rhs: Self) -> Bool { return lhs.jg_intValue > rhs.jg_intValue }
    public static func == (lhs: Self, rhs: Self) -> Bool { return lhs.jg_intValue == rhs.jg_intValue }
}

// enum
public extension RawRepresentable where RawValue: Comparable {
    static func < (lhs: RawValue, rhs: Self) -> Bool { return lhs < rhs.rawValue }
    static func < (lhs: Self, rhs: RawValue) -> Bool { return lhs.rawValue < rhs }
    static func <= (lhs: RawValue, rhs: Self) -> Bool { return lhs <= rhs.rawValue }
    static func <= (lhs: Self, rhs: RawValue) -> Bool { return lhs.rawValue <= rhs }
    static func >= (lhs: RawValue, rhs: Self) -> Bool { return lhs >= rhs.rawValue }
    static func >= (lhs: Self, rhs: RawValue) -> Bool { return lhs.rawValue >= rhs }
    static func > (lhs: RawValue, rhs: Self) -> Bool { return lhs > rhs.rawValue }
    static func > (lhs: Self, rhs: RawValue) -> Bool { return lhs.rawValue > rhs }
    static func == (lhs: RawValue, rhs: Self) -> Bool { return lhs == rhs.rawValue }
    static func == (lhs: Self, rhs: RawValue) -> Bool { return lhs.rawValue == rhs }
}

public extension RawRepresentable where RawValue: JGSSwiftyComparable {
    static func < (lhs: RawValue, rhs: Self) -> Bool { return lhs < rhs.rawValue }
    static func < (lhs: Self, rhs: RawValue) -> Bool { return lhs.rawValue < rhs }
    static func <= (lhs: RawValue, rhs: Self) -> Bool { return lhs <= rhs.rawValue }
    static func <= (lhs: Self, rhs: RawValue) -> Bool { return lhs.rawValue <= rhs }
    static func >= (lhs: RawValue, rhs: Self) -> Bool { return lhs >= rhs.rawValue }
    static func >= (lhs: Self, rhs: RawValue) -> Bool { return lhs.rawValue >= rhs }
    static func > (lhs: RawValue, rhs: Self) -> Bool { return lhs > rhs.rawValue }
    static func > (lhs: Self, rhs: RawValue) -> Bool { return lhs.rawValue > rhs }
    static func == (lhs: RawValue, rhs: Self) -> Bool { return lhs == rhs.rawValue }
    static func == (lhs: Self, rhs: RawValue) -> Bool { return lhs.rawValue == rhs }
}

// MARK: - Optional

extension Optional: JGSSwiftyJSON {}
extension NSNumber: JGSSwiftyComparable {}
extension String: JGSSwiftyComparable {}
extension NSString: JGSSwiftyComparable {}
extension URL: JGSSwiftyComparable {}
extension NSURL: JGSSwiftyComparable {}
extension Data: JGSSwiftyComparable {}
extension NSData: JGSSwiftyComparable {}

// MARK: - Array

extension Array: JGSSwiftyJSON {
    /// 数组比较：
    /// 1、先比对数量
    /// 数量不一致，直接使用数量比较结果
    /// 2、数量一致，则逐个比较元素

    public static func < (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count < rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedAscending
    }

    public static func <= (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count <= rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedAscending || compare == .orderedSame
    }

    public static func >= (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count >= rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedDescending || compare == .orderedSame
    }

    public static func > (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count > rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedDescending
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count == rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedSame
    }
}

extension NSArray: JGSSwiftyComparable {
    /// 数组比较：
    /// 1、先比对数量
    /// 数量不一致，直接使用数量比较结果
    /// 2、数量一致，则逐个比较元素

    public static func < (lhs: NSArray, rhs: NSArray) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count < rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedAscending
    }

    public static func <= (lhs: NSArray, rhs: NSArray) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count <= rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedAscending || compare == .orderedSame
    }

    public static func >= (lhs: NSArray, rhs: NSArray) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count >= rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedDescending || compare == .orderedSame
    }

    public static func > (lhs: NSArray, rhs: NSArray) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count > rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedDescending
    }

    public static func == (lhs: NSArray, rhs: NSArray) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count == rhs.count }

        if let rAny = rhs as? [Any], lhs.isEqual(to: rAny) { return true }
        if lhs.isEqual(rhs) { return true }

        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedSame
    }
}

extension Array: Comparable where Element: Comparable {
    /// 数组比较：
    /// 1、先比对数量
    /// 数量不一致，直接使用数量比较结果
    /// 2、数量一致，则逐个比较元素

    public static func < (lhs: [Element], rhs: [Element]) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count < rhs.count }

        for idx in 0 ..< lhs.count {
            guard lhs[idx] <= rhs[idx] else { return false }
        }
        return lhs.last! < rhs.last!
    }

    public static func <= (lhs: [Element], rhs: [Element]) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count <= rhs.count }

        for idx in 0 ..< lhs.count {
            guard lhs[idx] <= rhs[idx] else { return false }
        }
        return lhs.last! <= rhs.last!
    }

    public static func >= (lhs: [Element], rhs: [Element]) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count >= rhs.count }

        for idx in 0 ..< lhs.count {
            guard lhs[idx] >= rhs[idx] else { return false }
        }
        return lhs.last! >= rhs.last!
    }

    public static func > (lhs: [Element], rhs: [Element]) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count > rhs.count }

        for idx in 0 ..< lhs.count {
            guard lhs[idx] >= rhs[idx] else { return false }
        }
        return lhs.last! > rhs.last!
    }

    public static func == (lhs: [Element], rhs: [Element]) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count == rhs.count }

        for idx in 0 ..< lhs.count {
            guard lhs[idx] == rhs[idx] else { return false }
        }
        return lhs.last! == rhs.last!
    }
}

// MARK: - Dictionary

extension Dictionary: JGSSwiftyJSON {
    /// 字典比较：
    /// 1、先比key-value键值对数量
    /// 数量不一致，直接使用数量比较结果
    /// 2、数量一致，则逐个比较键值对
    /// 3、键值对先比较Key，后比较value

    public static func < (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count < rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedAscending
    }

    public static func <= (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count <= rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedAscending || compare == .orderedSame
    }

    public static func >= (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count >= rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedDescending || compare == .orderedSame
    }

    public static func > (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count > rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedDescending
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count == rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedSame
    }
}

extension NSDictionary: JGSSwiftyComparable {
    public static func < (lhs: NSDictionary, rhs: NSDictionary) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count < rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedAscending
    }

    public static func <= (lhs: NSDictionary, rhs: NSDictionary) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count <= rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedAscending || compare == .orderedSame
    }

    public static func >= (lhs: NSDictionary, rhs: NSDictionary) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count >= rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedDescending || compare == .orderedSame
    }

    public static func > (lhs: NSDictionary, rhs: NSDictionary) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count > rhs.count }
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedDescending
    }

    public static func == (lhs: NSDictionary, rhs: NSDictionary) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count == rhs.count }

        if let rAny = rhs as? [AnyHashable: Any], lhs.isEqual(to: rAny) { return true }
        if lhs.isEqual(rhs) { return true }

        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedSame
    }
}

extension Dictionary: Comparable where Key: Comparable, Value: Comparable {
    /// 字典比较：
    /// 1、先比key-value键值对数量
    /// 数量不一致，直接使用数量比较结果
    /// 2、数量一致，则逐个比较键值对
    /// 3、键值对先比较Key，后比较value

    public static func < (lhs: [Key: Value], rhs: [Key: Value]) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count < rhs.count }
        
        let lKeys = lhs.keys.sorted(by: <)
        let rKeys = rhs.keys.sorted(by: <)
        guard lKeys.count == rKeys.count, lKeys.count > 0 else { return lKeys.count < rKeys.count }
        
        for idx in 0 ..< lKeys.count {
            
            let lKey = lKeys[idx], rKey = rKeys[idx]
            guard lKey <= rKey else { return false }
            guard let lValue = lhs[lKey], let rValue = rhs[rKey], lValue <= rValue else {
                return false
            }
        }
        
        if let lValue = lhs[lKeys.last!], let rValue = rhs[rKeys.last!] {
            return lValue < rValue
        }
        
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedAscending
    }

    public static func <= (lhs: [Key: Value], rhs: [Key: Value]) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count <= rhs.count }
        
        let lKeys = lhs.keys.sorted(by: <)
        let rKeys = rhs.keys.sorted(by: <)
        guard lKeys.count == rKeys.count, lKeys.count > 0 else { return lKeys.count <= rKeys.count }

        for idx in 0 ..< lKeys.count {
            
            let lKey = lKeys[idx], rKey = rKeys[idx]
            guard lKey <= rKey else { return false }
            guard let lValue = lhs[lKey], let rValue = rhs[rKey], lValue <= rValue else {
                return false
            }
        }
        
        if let lValue = lhs[lKeys.last!], let rValue = rhs[rKeys.last!] {
            return lValue <= rValue
        }
        
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedAscending || compare == .orderedSame
    }

    public static func >= (lhs: [Key: Value], rhs: [Key: Value]) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count >= rhs.count }
        
        let lKeys = lhs.keys.sorted(by: <)
        let rKeys = rhs.keys.sorted(by: <)
        guard lKeys.count == rKeys.count, lKeys.count > 0 else { return lKeys.count >= rKeys.count }

        for idx in 0 ..< lKeys.count {
            
            let lKey = lKeys[idx], rKey = rKeys[idx]
            guard lKey >= rKey else { return false }
            guard let lValue = lhs[lKey], let rValue = rhs[rKey], lValue >= rValue else {
                return false
            }
        }
        
        if let lValue = lhs[lKeys.last!], let rValue = rhs[rKeys.last!] {
            return lValue >= rValue
        }
        
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedDescending || compare == .orderedSame
    }

    public static func > (lhs: [Key: Value], rhs: [Key: Value]) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count > rhs.count }
        
        let lKeys = lhs.keys.sorted(by: <)
        let rKeys = rhs.keys.sorted(by: <)
        guard lKeys.count == rKeys.count, lKeys.count > 0 else { return lKeys.count > rKeys.count }

        for idx in 0 ..< lKeys.count {
            
            let lKey = lKeys[idx], rKey = rKeys[idx]
            guard lKey >= rKey else { return false }
            guard let lValue = lhs[lKey], let rValue = rhs[rKey], lValue >= rValue else {
                return false
            }
        }
        
        if let lValue = lhs[lKeys.last!], let rValue = rhs[rKeys.last!] {
            return lValue > rValue
        }
        
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedDescending || compare == .orderedSame
    }

    public static func == (lhs: [Key: Value], rhs: [Key: Value]) -> Bool {
        guard lhs.count == rhs.count, lhs.count > 0 else { return lhs.count == rhs.count }
        
        let lKeys = lhs.keys.sorted(by: <)
        let rKeys = rhs.keys.sorted(by: <)
        guard lKeys.count == rKeys.count, lKeys.count > 0 else { return lKeys.count == rKeys.count }

        for idx in 0 ..< lKeys.count {
            
            let lKey = lKeys[idx], rKey = rKeys[idx]
            guard lKey == rKey else { return false }
            guard let lValue = lhs[lKey], let rValue = rhs[rKey], lValue == rValue else {
                return false
            }
        }
        
        if let lValue = lhs[lKeys.last!], let rValue = rhs[rKeys.last!] {
            return lValue == rValue
        }
        
        let compare = lhs.jg_sortedJSON().compare(rhs.jg_sortedJSON(), options: [.caseInsensitive, .numeric])
        return compare == .orderedSame
    }
}
