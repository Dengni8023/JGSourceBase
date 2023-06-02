//
//  JGSCustomModelType.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/5/5.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import UIKit

public struct JGSCustomDeserializeOptions: OptionSet {
    
    public static let caseInsensitive = JGSCustomDeserializeOptions(rawValue: 1 << 0)
    public static let defaultOptions: JGSCustomDeserializeOptions = []
    
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

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
extension NSObject {
    static func jg_init() -> NSObject {
        return self.init()
    }
}

public extension JGSCustomModelType {
    
    static func jg_transform(from object: Any?) -> Self? {
        var _dict = object as? [String: Any]
        if let _string = object as? String,
           let _data = _string.data(using: .utf8) {
            _dict = try? JSONSerialization.jsonObject(with: _data, options: [.allowFragments]) as? [String: Any]
        } else if let _data = object as? Data {
            _dict = try? JSONSerialization.jsonObject(with: _data, options: [.allowFragments]) as? [String: Any]
        }
        
        guard let _dict = _dict else {
            return nil
        }
        
        var instance: Self
        if let _NSType = Self.self as? NSObject.Type {
            instance = _NSType.jg_init() as! Self
        } else {
            instance = Self()
        }
        
        _transform(dict: _dict, to: &instance)
        instance.jg_didFinishModeling()
        
        return nil
    }
    
    private static func _transform(dict: [String: Any], to instance: inout Self) {
        return
    }
}
