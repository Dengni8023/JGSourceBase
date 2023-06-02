//
//  JGSTransformable.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/7.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: _Transformable
// https://github.com/alibaba/handyjson

public protocol JGSTransformable {
    static func jg_transform(from object: Any?) -> Self?
    func jg_plainValue() -> Any?
    
    init?(_ data: Data?)
    init?(_ json: String?)
    init?(_ dict: [String: Any]?)
}

public extension JGSTransformable {
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
    
    // MARK: - init
    init?(_ data: Data?) {
        guard let object = Self.jg_transform(from: data) else {
            return nil
        }
        self = object
    }
    
    init?(_ json: String?) {
        guard let object = Self.jg_transform(from: json) else {
            return nil
        }
        self = object
    }
    
    init?(_ dict: [String: Any]?) {
        guard let object = Self.jg_transform(from: dict) else {
            return nil
        }
        self = object
    }
}

// MARK: - JGSRawEnumProtocol

public protocol JGSBuildInRawEnumType: JGSTransformable {}
public extension RawRepresentable where Self: JGSBuildInRawEnumType {
    static func jg_transform(from object: Any?) -> Self? {
        if let transformableType = RawValue.self as? JGSTransformable.Type {
            if let typedValue = transformableType.jg_transform(from: object) {
                return Self(rawValue: typedValue as! RawValue)
            }
        }
        return nil
    }

    func jg_plainValue() -> Any? {
        return self.rawValue
    }
}
