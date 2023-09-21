//
//  JGSBuildInBridgeType.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/26.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

internal protocol JGSBuildInBridgeType: JGSTransformable {
    static func jg_transform(from object: Any?) -> JGSBuildInBridgeType?
}

extension NSNull: JGSBuildInBridgeType {
    static func jg_transform(from object: Any?) -> JGSBuildInBridgeType? {
        if object == nil {
            return NSNull()
        }
        if let _null = object as? NSNull {
            return _null
        }
        return nil
    }
    
    public func jg_plainValue() -> Any? {
        return self
    }
}

extension NSString: JGSBuildInBridgeType {
    static func jg_transform(from object: Any?) -> JGSBuildInBridgeType? {
        if let str = String.jg_transform(from: object) {
            return NSString(string: str) as! Self
        }
        return nil
    }

    public func jg_plainValue() -> Any? {
        return self
    }
}

extension NSURL: JGSBuildInBridgeType {
    static func jg_transform(from object: Any?) -> JGSBuildInBridgeType? {
        if let _url = URL.jg_transform(from: object) {
            return NSURL(string: _url.absoluteString) as? Self
        }
        return nil
    }
    
    public func jg_plainValue() -> Any? {
        return self.absoluteString?.removingPercentEncoding
    }
}

extension NSNumber: JGSBuildInBridgeType {
    static func jg_transform(from object: Any?) -> JGSBuildInBridgeType? {
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

    public func jg_plainValue() -> Any? {
        return self
    }
}

extension NSArray: JGSBuildInBridgeType {
    static func jg_transform(from object: Any?) -> JGSBuildInBridgeType? {
        guard let object = object else {
            return nil
        }
        
        var options: JSONSerialization.ReadingOptions = [.fragmentsAllowed]
        if #available(iOS 15.0, *) {
            options.insert(.json5Allowed)
        }
        
        // JSON String -> NSArray
        if let str = object as? String,
           let data = str.data(using: .utf8),
           let collection = try? JSONSerialization.jsonObject(with: data, options: options) as? Self {
            return collection
        }
        // JSON Data -> NSArray
        else if let _data = object as? Data, let collection = try? JSONSerialization.jsonObject(with: _data, options: options) as? Self {
            return collection
        }
        
        return object as? Self
    }

    public func jg_plainValue() -> Any? {
        return (self as? Self)?.jg_plainValue()
    }
}

extension NSDictionary: JGSBuildInBridgeType {
    static func jg_transform(from object: Any?) -> JGSBuildInBridgeType? {
        guard let object = object else {
            return nil
        }
        
        var options: JSONSerialization.ReadingOptions = [.fragmentsAllowed]
        if #available(iOS 15.0, *) {
            options.insert(.json5Allowed)
        }
        
        // JSON String -> Dictionary
        if let str = object as? String,
           let data = str.data(using: .utf8),
           let dict = try? JSONSerialization.jsonObject(with: data, options: options) as? Self {
            return dict
        }
        // JSON Data -> Dictionary
        else if let _data = object as? Data, let dict = try? JSONSerialization.jsonObject(with: _data, options: options) as? Self {
            return dict
        }
        
        return object as? Self
    }

    public func jg_plainValue() -> Any? {
        return (self as? Self)?.jg_plainValue()
    }
}
