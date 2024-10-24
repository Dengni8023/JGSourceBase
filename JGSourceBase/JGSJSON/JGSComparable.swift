//
//  JGSComparable.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2024/10/23.
//  Copyright © 2024 MeiJiGao. All rights reserved.
//

import Foundation

// MARK: - Comparable

public protocol JGSComparable: Comparable {}
public extension JGSComparable {
    // <
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs < rhs
    }

    static func < (lhs: Self?, rhs: Self) -> Bool {
        return lhs != nil ? lhs! < rhs : true
    }

    static func < (lhs: Self, rhs: Self?) -> Bool {
        return rhs != nil ? lhs < rhs! : false
    }

    // <=
    static func <= (lhs: Self, rhs: Self) -> Bool {
        return lhs <= rhs
    }

    static func <= (lhs: Self?, rhs: Self) -> Bool {
        return lhs != nil ? lhs! <= rhs : true
    }

    static func <= (lhs: Self, rhs: Self?) -> Bool {
        return rhs != nil ? lhs <= rhs! : false
    }

    // >=
    static func >= (lhs: Self, rhs: Self) -> Bool {
        return lhs >= rhs
    }

    static func >= (lhs: Self?, rhs: Self) -> Bool {
        return lhs != nil ? lhs! >= rhs : false
    }

    static func >= (lhs: Self, rhs: Self?) -> Bool {
        return rhs != nil ? lhs >= rhs! : true
    }

    // >
    static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs > rhs
    }

    static func > (lhs: Self?, rhs: Self) -> Bool {
        return lhs != nil ? lhs! > rhs : false
    }

    static func > (lhs: Self, rhs: Self?) -> Bool {
        return rhs != nil ? lhs > rhs! : true
    }
}

extension JGSJSON {
    func jg_sortedJSON() -> String? {
        return String.jg_transform(from: self)
    }
}

// MARK: - Optional
public extension Optional where Wrapped: JGSComparable {}

// MARK: - BuildInType
extension Int: JGSComparable {}
extension Int8: JGSComparable {}
extension Int16: JGSComparable {}
extension Int32: JGSComparable {}
extension Int64: JGSComparable {}

extension UInt: JGSComparable {}
extension UInt8: JGSComparable {}
extension UInt16: JGSComparable {}
extension UInt32: JGSComparable {}
extension UInt64: JGSComparable {}

extension Double: JGSComparable {}
extension Float: JGSComparable {}
extension Bool: JGSComparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return !lhs && rhs
    }

    public static func <= (lhs: Self, rhs: Self) -> Bool {
        return !lhs || rhs
    }

    public static func >= (lhs: Self, rhs: Self) -> Bool {
        return lhs || !rhs
    }

    public static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs && !rhs
    }
}

extension Array {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if let lJson = lhs.jg_sortedJSON(),
           let rJson = rhs.jg_sortedJSON() {
           return lJson == rJson
        }
        return lhs == rhs
    }

    public static func != (lhs: Self, rhs: Self) -> Bool {
        if let lJson = lhs.jg_sortedJSON(),
           let rJson = rhs.jg_sortedJSON() {
           return lJson != rJson
        }
        return lhs != rhs
    }
}

extension Dictionary {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if let lJson = lhs.jg_sortedJSON(),
           let rJson = rhs.jg_sortedJSON() {
           return lJson == rJson
        }
        return lhs == rhs
    }

    public static func != (lhs: Self, rhs: Self) -> Bool {
        if let lJson = lhs.jg_sortedJSON(),
           let rJson = rhs.jg_sortedJSON() {
           return lJson != rJson
        }
        return lhs != rhs
    }
}

// MARK: - BuildInBridgeType
extension NSArray {
    public static func == (lhs: NSArray, rhs: NSArray) -> Bool {
        if let lJson = lhs.jg_sortedJSON(),
           let rJson = rhs.jg_sortedJSON() {
           return lJson == rJson
        }
        return lhs == rhs
    }

    public static func != (lhs: NSArray, rhs: NSArray) -> Bool {
        if let lJson = lhs.jg_sortedJSON(),
           let rJson = rhs.jg_sortedJSON() {
           return lJson != rJson
        }
        return lhs != rhs
    }
}

extension NSDictionary {
    public static func == (lhs: NSDictionary, rhs: NSDictionary) -> Bool {
        if let lJson = lhs.jg_sortedJSON(),
           let rJson = rhs.jg_sortedJSON() {
           return lJson == rJson
        }
        return lhs == rhs
    }

    public static func != (lhs: NSDictionary, rhs: NSDictionary) -> Bool {
        if let lJson = lhs.jg_sortedJSON(),
           let rJson = rhs.jg_sortedJSON() {
           return lJson != rJson
        }
        return lhs != rhs
    }
}
