//
//  Dictionary+JGSBase.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2022/12/2.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

import Foundation

public
extension Dictionary where Key : Hashable {

    // String
    func jg_string(forKey key: Key) -> String? {
        guard let value = self[key] else { return nil }
        return String.jg_transform(from: value)
    }

    // Number
    func jg_number(forKey key: Key) -> NSNumber? {
        guard let value = self[key] else { return nil }
        return NSNumber.jg_transform(from: value)
    }

    // Int
    func jg_int(forKey key: Key) -> Int? {
        guard let value = self[key] else { return nil }
        return Int.jg_transform(from: value)
    }

    // Float
    func jg_float(forKey key: Key) -> Float? {
        guard let value = self[key] else { return nil }
        return Float.jg_transform(from: value)
    }

    func jg_double(forKey key: Key) -> Double? {
        guard let value = self[key] else { return nil }
        return Double.jg_transform(from: value)
    }

    // BOOL
    func jg_bool(forKey key: Key) -> Bool? {
        guard let value = self[key] else { return nil }
        return Bool.jg_transform(from: value)
    }

    // Object
    func jg_object<T>(forKey key: Key) -> T? {
        guard let value = self[key] else { return nil }

        // T
        let nilT: T? = nil
        if value is T || type(of: value) == type(of: nilT) {
            return (value as? T)
        }

        switch T.self {
        case let transformableType as JGSTransformable.Type:
            return transformableType.jg_transform(from: value) as? T
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
        default:
            JGSPrivateLog()
        }

        // String
        var options: JSONSerialization.ReadingOptions = []
        if #available(iOS 15.0, *) {
            options.insert(.json5Allowed)
        }
        let nilString: String? = nil
        if let string = (value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
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
    func jg_dictionary<K, V>(forKey key: Key) -> [K: V]? {
        guard let value = self[key] else { return nil }
        return Dictionary<K, V>.jg_transform(from: value)
    }

    // Array
    func jg_array<Ele>(forKey key: Key) -> [Ele]? {
        guard let value = self[key] else { return nil }
        return Array<Ele>.jg_transform(from: value)
    }

    // Set
    func jg_set<Ele>(forKey key: Key) -> Set<Ele>? {
        guard let value = self[key] else { return nil }
        return Set<Ele>.jg_transform(from: value)
    }
}
