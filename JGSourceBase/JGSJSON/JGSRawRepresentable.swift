//
//  JGSRawRepresentable.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/9/25.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: _RawEnumProtocol
// https://github.com/alibaba/handyjson

// MARK: - RawRepresentable
public protocol JGSRawRepresentable: JGSTransformable {
    static func jg_transform(from object: Any?) -> Self?
    func jg_plainValue() -> Any?
}

extension RawRepresentable where Self: JGSRawRepresentable {
    public static func jg_transform(from object: Any?) -> Self? {
        if let transformableType = RawValue.self as? JGSTransformable.Type {
            if let typedValue = transformableType.jg_transform(from: object) {
                return Self(rawValue: typedValue as! RawValue)
            }
        }
        return nil
    }
    
    public func jg_plainValue() -> Any? {
        return self.rawValue
    }
}

// MARK: - Enum
public extension RawRepresentable where RawValue: Comparable {
    static func < (lhs: RawValue, rhs: Self) -> Bool {
        return lhs < rhs.rawValue
    }

    static func < (lhs: Self, rhs: RawValue) -> Bool {
        return lhs.rawValue < rhs
    }

    static func <= (lhs: RawValue, rhs: Self) -> Bool {
        return lhs <= rhs.rawValue
    }

    static func <= (lhs: Self, rhs: RawValue) -> Bool {
        return lhs.rawValue <= rhs
    }

    static func >= (lhs: RawValue, rhs: Self) -> Bool {
        return lhs >= rhs.rawValue
    }

    static func >= (lhs: Self, rhs: RawValue) -> Bool {
        return lhs.rawValue >= rhs
    }

    static func > (lhs: RawValue, rhs: Self) -> Bool {
        return lhs > rhs.rawValue
    }

    static func > (lhs: Self, rhs: RawValue) -> Bool {
        return lhs.rawValue > rhs
    }

    static func == (lhs: RawValue, rhs: Self) -> Bool {
        return lhs == rhs.rawValue
    }

    static func == (lhs: Self, rhs: RawValue) -> Bool {
        return lhs.rawValue == rhs
    }
}

public extension RawRepresentable where RawValue: AdditiveArithmetic {
    // 枚举类型运算重载
    static func + (lhs: Self, rhs: RawValue) -> Self? {
        return Self(rawValue: lhs.rawValue + rhs)
    }

    static func - (lhs: Self, rhs: RawValue) -> Self? {
        return Self(rawValue: lhs.rawValue - rhs)
    }
}
