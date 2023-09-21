//
//  Dictionary+JGSBase.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2022/12/2.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

import Foundation

extension Dictionary where Key : Hashable {

    // String
    public func jg_string(forKey key: Key, default defaultValue: String? = nil) -> String? {
        guard let value = self[key] else {
            return defaultValue
        }
        
        return String.jg_transform(from: value)
    }

    // Number
    public func jg_number(forKey key: Key, default defaultValue: NSNumber? = nil) -> NSNumber? {
        guard let value = self[key] else {
            return defaultValue
        }
        
        return NSNumber.jg_transform(from: value)
    }

    // Int
    public func jg_int(forKey key: Key, default defaultValue: Int? = nil) -> Int? {
        guard let value = self[key] else {
            return defaultValue
        }
        
        return Int.jg_transform(from: value)
    }
    
    // Float
    public func jg_float(forKey key: Key, default defaultValue: Float? = nil) -> Float? {
        guard let value = self[key] else {
            return defaultValue
        }
        
        return Float.jg_transform(from: value)
    }

    public func jg_double(forKey key: Key, default defaultValue: Double? = nil) -> Double? {
        guard let value = self[key] else {
            return defaultValue
        }
        
        return Double.jg_transform(from: value)
    }

    // BOOL
    public func jg_bool(forKey key: Key, default defaultValue: Bool? = nil) -> Bool? {
        guard let value = self[key] else {
            return defaultValue
        }
        
        return Bool.jg_transform(from: value)
    }
    
    // Object
    public func jg_object<T>(forKey key: Key, default defaultValue: T? = nil) -> T? {
        guard let value = self[key] else {
            return defaultValue
        }

        // T
        let nilT: T? = nil
        if value is T || type(of: value) == type(of: nilT) {
            return value as? T
        }
        
        switch T.self {
        case _ as String.Type:
            return jg_string(forKey: key, default: defaultValue as? String) as? T
        case _ as NSNumber.Type:
            return jg_number(forKey: key, default: defaultValue as? NSNumber) as? T
        case _ as Int.Type:
            return jg_int(forKey: key, default: defaultValue as? Int) as? T
        case _ as Float.Type:
            return jg_float(forKey: key, default: defaultValue as? Float) as? T
        case _ as Double.Type:
            return jg_double(forKey: key, default: defaultValue as? Double) as? T
        case _ as Bool.Type:
            return jg_bool(forKey: key, default: defaultValue as? Bool) as? T
        case _ as Dictionary.Type:
            return jg_dictionary(forKey: key, default: defaultValue as? Dictionary) as? T
        //case _ as [AnyHashable: Any].Type:
        //    return jg_dictionary(forKey: key, default: defaultValue as? [AnyHashable: Any]) as? T
        case _ as Array<Any>.Type:
            return jg_array(forKey: key, default: defaultValue as? Array) as? T
        //case _ as [Any].Type:
        //    return jg_array(forKey: key, default: defaultValue as? [Any]) as? T
        default:
            JGSPrivateLog()
        }
        
        // String
        var options: JSONSerialization.ReadingOptions = [.fragmentsAllowed]
        if #available(iOS 15.0, *) {
            options.insert(.json5Allowed)
        }
        let nilString: String? = nil
        if let string = value as? String,
           value is String || type(of: value) == type(of: nilString),
           let jsonData = string.data(using: .utf8),
           let object = try? JSONSerialization.jsonObject(with: jsonData, options: options) as? T {
            return object
        }
        
        // 直接转换
        return value as? T ?? defaultValue
    }
    
    // Dict
    public func jg_dictionary(forKey key: Key, default defaultValue: [Key: Value]? = nil) -> [Key: Value]? {
        guard let value = self[key] else {
            return defaultValue
        }
        
        return Dictionary<Key, Value>.jg_transform(from: value)
    }
    
    // Array
    public func jg_array(forKey key: Key, default defaultValue: [Any]? = nil) -> [Any]? {
        guard let value = self[key] else {
            return defaultValue
        }
        
        return Array<Any>.jg_transform(from: value)
    }
    
    // Set
    public func jg_set(forKey key: Key, default defaultValue: [AnyHashable]? = nil) -> Set<AnyHashable>? {
        guard let value = self[key] else {
            if let defaultValue = defaultValue {
                return Set(defaultValue)
            }
            return nil
        }
        
        return Set<AnyHashable>.jg_transform(from: value)
    }
}
