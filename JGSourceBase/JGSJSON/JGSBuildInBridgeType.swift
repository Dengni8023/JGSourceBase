//
//  JGSBuildInBridgeType.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/26.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: BuiltInBridgeType.swift
// https://github.com/alibaba/handyjson

public protocol JGSBuildInBridgeType: JGSTransformable {
    static func _transform(from object: Any?) -> JGSBuildInBridgeType?
    func _plainValue() -> Any?
}

extension NSString: JGSBuildInBridgeType {
    public static func _transform(from object: Any?) -> JGSBuildInBridgeType? {
        if let str = String._transform(from: object) {
            return NSString(string: str)
        }
        return nil
    }

    public func _plainValue() -> Any? {
        return self
    }
}

extension NSURL: JGSBuildInBridgeType {
    public static func _transform(from object: Any?) -> JGSBuildInBridgeType? {
        if let _url = URL._transform(from: object) {
            return NSURL(string: _url.absoluteString) as? Self
        }
        return nil
    }
    
    public func _plainValue() -> Any? {
        return self.absoluteString
    }
}

extension NSNumber: JGSBuildInBridgeType {
    public static func _transform(from object: Any?) -> JGSBuildInBridgeType? {
        guard let object = object else {
            return nil
        }
        
        switch object {
        case let num as NSNumber:
            return num
        case let str as String:
            let lower = str.lowercased()
            if ["0", "f", "false", "n", "no"].contains(lower) {
                return NSNumber(booleanLiteral: false)
            } else if ["1", "t", "true", "y", "yes"].contains(lower) {
                return NSNumber(booleanLiteral: true)
            } else {
                // normal number
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                return formatter.number(from: str)
            }
        default:
            return nil
        }
    }
    
    public func _plainValue() -> Any? {
        return self
    }
}

extension NSArray: JGSBuildInBridgeType {
    public static func _transform(from object: Any?) -> JGSBuildInBridgeType? {
        return [Element]._transform(from: object) as? Self
    }

    public func _plainValue() -> Any? {
        return (self as? [Element])?._plainValue()
    }
}

extension NSDictionary: JGSBuildInBridgeType {
    
    public static func _transform(from object: Any?) -> JGSBuildInBridgeType? {
        if Key.self is AnyHashable {
            return [AnyHashable: Element]._transform(from: object) as? Self
        }
        
        return object as? Self
    }

    public func _plainValue() -> Any? {
        return (self as? Dictionary<AnyHashable, Any>)?._plainValue()
    }
}
