//
//  JGSCustomModelType.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/5/5.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import UIKit

public protocol JGSCustomModelType: JGSTransformable {
    init()
    mutating func jg_modeling(helper: JGSCustomModelHelper)
    mutating func jg_didFinishModeling()
}

public extension JGSCustomModelType {
    mutating func jg_modeling(helper: JGSCustomModelHelper) {}
    mutating func jg_didFinishModeling() {}
}

// this's a workaround before https://bugs.swift.org/browse/SR-5223 fixed
fileprivate extension NSObject {
    static func jg_createInstance() -> NSObject {
        return self.init()
    }
}

// MARK: - Transform
public extension JGSCustomModelType {
    
    static func jg_transform(from object: Any?) -> JGSCustomModelType? {
        var _dict = object as? [String: Any]
        var options: JSONSerialization.ReadingOptions = [.fragmentsAllowed]
        if #available(iOS 15.0, *) {
            options.insert(.json5Allowed)
        }
        if let _string = object as? String, let _data = _string.data(using: .utf8) {
            _dict = try? JSONSerialization.jsonObject(with: _data, options: options) as? [String: Any]
        } else if let _data = object as? Data {
            _dict = try? JSONSerialization.jsonObject(with: _data, options: options) as? [String: Any]
        }
        
        guard let dict = _dict else { return nil }
        
        var instance: Self
        if let _NSType = Self.self as? NSObject.Type {
            instance = _NSType.jg_createInstance() as! Self
        } else {
            instance = Self()
        }
        
        _transform(dict: dict, to: &instance)
        instance.jg_didFinishModeling()
        
        return instance
    }
    
    private static func _transform(dict: [String: Any], to instance: inout Self) {
        return
    }
}
