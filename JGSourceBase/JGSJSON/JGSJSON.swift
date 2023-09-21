//
//  JGSJSON.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/25.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation
import UIKit

// 参考 HandyJSON: _Transformable
// https://github.com/alibaba/handyjson

public protocol JGSJSONEnum: JGSRawEnumProtocol {}
public protocol JGSJSON: JGSCustomModelType {}

// MARK: - Deserializer

public extension JGSJSON {
    /// 将 path 指定的 dictionary 转换为 Model
    /// - Parameters:
    ///   - dict: 原始Dictionary
    ///   - path: 将要转换的数据的key，多层key使用`.`拼接，eg: `result.data.orderInfo`
    /// - Returns: Model
    static func deserialize(from dict: NSDictionary?, path: String? = nil) -> Self? {
        return deserialize(from: dict as? [String: Any], path: path)
    }

    /// 将 path 指定的 dictionary 转换为 Model
    /// - Parameters:
    ///   - dict: 原始Dictionary
    ///   - path: 将要转换的数据的key，多层key使用`.`拼接，eg: `result.data.orderInfo`
    /// - Returns: Model
    static func deserialize(from dict: [String: Any]?, path: String? = nil) -> Self? {
        return JGJSONDeserializer<Self>.deserializeFrom(dict: dict, path: path)
    }

    /// 将 path 指定的 JSON 转换为 Model
    /// - Parameters:
    ///   - json: 原始JSON
    ///   - path: 将要转换的数据的key，多层key使用`.`拼接，eg: `result.data.orderInfo`
    /// - Returns: Model
    static func deserialize(from json: String?, path: String? = nil) -> Self? {
        return JGJSONDeserializer<Self>.deserializeFrom(json: json, path: path)
    }
}

public extension Array where Element: JGSJSON {
    /// 将 path 指定的 JSON 转换为 [Model]
    /// - Parameters:
    ///   - json: 原始JSON
    ///   - path: 将要转换的数据的key，多层key使用`.`拼接，eg: `result.data.orders`
    /// - Returns: [Model]
    static func deserialize(from json: String?, path: String? = nil) -> [Element?]? {
        return JGJSONDeserializer<Element>.deserializeModelArrayFrom(json: json, path: path)
    }

    /// array 转 [Model]
    /// - Parameter array: 原始Array
    /// - Returns: [Model]
    static func deserialize(from array: NSArray?) -> [Element?]? {
        return JGJSONDeserializer<Element>.deserializeModelArrayFrom(array: array)
    }

    /// array 转 [Model]
    /// - Parameter array: 原始Array
    /// - Returns: [Model]
    static func deserialize(from array: [Any]?) -> [Element?]? {
        return JGJSONDeserializer<Element>.deserializeModelArrayFrom(array: array)
    }
}

private func JGSJSONGetInnerObject(inside object: Any?, by path: String?) -> Any? {
    var result: Any? = object
    var abort = false
    if let paths = path?.components(separatedBy: "."), paths.count > 0 {
        var next = object as? [String: Any]
        for seg in paths {
            // path不合规或者中断
            if seg.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                abort = true
                break
            }

            result = next?[seg]
            if let _next = result as? [String: Any] {
                next = _next
            } else {
                abort = true
                break
            }
        }
    }
    return abort ? nil : result
}

private final class JGJSONDeserializer<T: JGSJSON> {
    /// Finds the internal dictionary in `dict` as the `path` specified, and map it to a Model
    /// `path` is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    static func deserializeFrom(dict: NSDictionary?, path: String? = nil) -> T? {
        return deserializeFrom(dict: dict as? [String: Any], path: path)
    }

    /// Finds the internal dictionary in `dict` as the `path` specified, and map it to a Model
    /// `path` is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    static func deserializeFrom(dict: [String: Any]?, path: String? = nil) -> T? {
        var srcDict = dict
        if let path = path {
            srcDict = JGSJSONGetInnerObject(inside: dict, by: path) as? [String: Any]
        }
        guard let srcDict = srcDict else { return nil }
        return T.jg_transform(from: srcDict)
    }
    
    /// Finds the internal JSON field in `json` as the `path` specified, and converts it to Model
    /// `path` is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    static func deserializeFrom(json: String?, path: String? = nil) -> T? {
        guard let jsonData = json?.data(using: .utf8) else { return nil }
        do {
            var options: JSONSerialization.ReadingOptions = [.fragmentsAllowed]
            if #available(iOS 15.0, *) {
                options.insert(.json5Allowed)
            }
            
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: options)
            if let srcDict = jsonObject as? [String: Any] {
                return self.deserializeFrom(dict: srcDict, path: path)
            }
        } catch let error {
            JGSPrivateLogE(error)
        }
        return nil
    }

    /// if the JSON field found by `path` in `json` is representing a array, such as `[{...}, {...}, {...}]`,
    /// this method converts it to a Models array
    static func deserializeModelArrayFrom(json: String?, path: String? = nil) -> [T?]? {
        guard let jsonData = json?.data(using: .utf8) else { return nil }
        do {
            var options: JSONSerialization.ReadingOptions = [.fragmentsAllowed]
            if #available(iOS 15.0, *) {
                options.insert(.json5Allowed)
            }
            
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: options)
            if let jsonArray = JGSJSONGetInnerObject(inside: jsonObject, by: path) as? [Any] {
                return jsonArray.map { (item: Any) -> T? in
                    self.deserializeFrom(dict: item as? [String: Any])
                }
            }
        } catch let error {
            JGSPrivateLogE(error)
        }
        return nil
    }

    /// mapping raw array to Models array
    static func deserializeModelArrayFrom(array: NSArray?) -> [T?]? {
        return deserializeModelArrayFrom(array: array as? [Any])
    }

    /// mapping raw array to Models array
    static func deserializeModelArrayFrom(array: [Any]?) -> [T?]? {
        guard let array = array else { return nil }
        return array.map { (item: Any) -> T? in
            self.deserializeFrom(dict: item as? [String: Any])
        }
    }
}

// MARK: - Serializer

public extension JGSJSON {
    func jg_JSON() -> [String: Any]? {
        #warning("TODO: _serializeAny(object")
//        if let dict = Self._serializeAny(object: self) as? [String: Any] {
//            return dict
//        }
        return nil
    }

    func jg_JSONString(prettyPrint: Bool = false) -> String? {
        guard let anyObject = self.jg_JSON(),
              JSONSerialization.isValidJSONObject(anyObject) else {
            JGSPrivateLogD("\(self)) is not a valid JSON Object")
            return nil
        }

        do {
            var options: JSONSerialization.WritingOptions = [.sortedKeys]
            if prettyPrint {
                options.insert(.prettyPrinted)
            }
            let jsonData = try JSONSerialization.data(withJSONObject: anyObject, options: options)
            return String(data: jsonData, encoding: .utf8)
        } catch let error {
            JGSPrivateLogE(error)
        }
        return nil
    }
}

public extension Collection where Iterator.Element: JGSJSON {
    func jg_JSON() -> [[String: Any]?] {
        return self.map { element in
            element.jg_JSON()
        }
    }

    func jg_JSONString(prettyPrint: Bool = false) -> String? {
        let anyArray = self.jg_JSON()
        guard JSONSerialization.isValidJSONObject(anyArray) else {
            JGSPrivateLogD("\(anyArray)) is not a valid JSON Object")
            return nil
        }

        do {
            var options: JSONSerialization.WritingOptions = [.sortedKeys]
            if prettyPrint {
                options.insert(.prettyPrinted)
            }

            let jsonData = try JSONSerialization.data(withJSONObject: anyArray, options: options)
            return String(data: jsonData, encoding: .utf8)
        } catch let error {
            JGSPrivateLogE(error)
        }
        return nil
    }
}

