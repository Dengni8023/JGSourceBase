//
//  JGSJSON.swift
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

public protocol JGSJSONEnum: JGSRawRepresentable {}
public protocol JGSJSON: JGSTransformable {}

public extension JGSJSON {
    
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

    var jg_array: Array<any JGSJSON>? {
        return Array<any JGSJSON>.jg_transform(from: self)
    }

    var jg_arrayValue: Array<any JGSJSON> {
        return jg_array ?? []
    }

    var jg_dictionary: [String: any JGSJSON]? {
        return [String: any JGSJSON].jg_transform(from: self)
    }

    var jg_dictionaryValue: [String: any JGSJSON] {
        return jg_dictionary ?? [:]
    }
}

// MARK: - Optional
extension Optional: JGSJSON {}

// MARK: - BuildInType
extension Int: JGSJSON {}
extension Int8: JGSJSON {}
extension Int16: JGSJSON {}
extension Int32: JGSJSON {}
extension Int64: JGSJSON {}

extension UInt: JGSJSON {}
extension UInt8: JGSJSON {}
extension UInt16: JGSJSON {}
extension UInt32: JGSJSON {}
extension UInt64: JGSJSON {}

extension Double: JGSJSON {}
extension Float: JGSJSON {}
extension Bool: JGSJSON {}

extension String: JGSJSON {}
extension URL: JGSJSON {}
extension Array: JGSJSON {}
extension Dictionary: JGSJSON {}
extension Data: JGSJSON {}

// MARK: - BuildInBridgeType
extension NSNumber: JGSJSON {}
extension NSString: JGSJSON {}
extension NSURL: JGSJSON {}
extension NSData: JGSJSON {}
extension NSArray: JGSJSON {}
extension NSDictionary: JGSJSON {}
