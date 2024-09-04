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
    public func jg_string(forKey key: Key) -> String? {
        guard let value = self[key] else { return nil }
        return String.jg_transform(from: value)
    }

    // Number
    public func jg_number(forKey key: Key) -> NSNumber? {
        guard let value = self[key] else { return nil }
        return NSNumber.jg_transform(from: value)
    }

    // Int
    public func jg_int(forKey key: Key) -> Int? {
        guard let value = self[key] else { return nil }
        return Int.jg_transform(from: value)
    }

    // Float
    public func jg_float(forKey key: Key) -> Float? {
        guard let value = self[key] else { return nil }
        return Float.jg_transform(from: value)
    }

    public func jg_double(forKey key: Key) -> Double? {
        guard let value = self[key] else { return nil }
        return Double.jg_transform(from: value)
    }

    // BOOL
    public func jg_bool(forKey key: Key) -> Bool? {
        guard let value = self[key] else { return nil }
        return Bool.jg_transform(from: value)
    }

    // Object
    public func jg_object<T>(forKey key: Key) -> T? {
        guard let value = self[key] else { return nil }

        // T
        let nilT: T? = nil
        if value is T || type(of: value) == type(of: nilT) {
            return (value as? T)
        }

        switch T.self {
        case _ as String.Type:
            return jg_string(forKey: key) as? T
        case _ as NSNumber.Type:
            return jg_number(forKey: key) as? T
        case _ as Int.Type:
            return jg_int(forKey: key) as? T
        case _ as Float.Type:
            return jg_float(forKey: key) as? T
        case _ as Double.Type:
            return jg_double(forKey: key) as? T
        case _ as Bool.Type:
            return jg_bool(forKey: key) as? T
        case _ as [Key: Value].Type:
            return jg_dictionary(forKey: key) as? T
        case _ as Dictionary.Type:
            return jg_dictionary(forKey: key) as? T
        // case _ as [AnyHashable: Any].Type:
        //    return jg_dictionary(forKey: key) as? T
        case _ as [Element].Type:
            return jg_array(forKey: key) as? T
        case _ as Array<Element>.Type:
            return jg_array(forKey: key) as? T
        case _ as Array<Any>.Type:
            return jg_array(forKey: key) as? T
        // case _ as [Any].Type:
        //    return jg_array(forKey: key) as? T
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
           ["{", "["].filter({ prefix in
               string.hasPrefix(prefix)
           }).count > 0,
           value is String || type(of: value) == type(of: nilString),
           let jsonData = string.data(using: .utf8),
           let object = try? JSONSerialization.jsonObject(with: jsonData, options: options) as? T {
            return object
        }

        // 直接转换
        return value as? T
    }

    // Dict
    public func jg_dictionary(forKey key: Key) -> [Key: Value]? {
        guard let value = self[key] else { return nil }
        return Dictionary<Key, Value>.jg_transform(from: value)
    }

    // Array
    public func jg_array(forKey key: Key) -> [Element]? {
        guard let value = self[key] else { return nil }
        return Array<Element>.jg_transform(from: value)
    }

    // Set
    public func jg_set<Element>(forKey key: Key) -> Set<Element>? {
        guard let value = self[key] else { return nil }
        return Set<Element>.jg_transform(from: value)
    }
}
