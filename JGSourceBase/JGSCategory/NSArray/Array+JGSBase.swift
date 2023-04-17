//
//  Array+JGSBase.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/7.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

// MARK: - JGSBuildInBasicType

extension Array: JGSBuildInBasicType {
    static func jg_transform(from object: Any?) -> Array<Element>? {
        return jg_collectionTransform(from: object)
    }

    func jg_plainValue() -> Any? {
        return jg_collectionPlainValue()
    }
}

// MARK: - JGSBuildInBridgeType

extension NSArray: JGSBuildInBridgeType {
    static func jg_transform(from object: Any?) -> JGSBuildInBridgeType? {
        guard let object = object else {
            return nil
        }
        
        // String -> NSArray
        if let str = object as? String,
           let data = str.data(using: .utf8),
           let array = try? JSONSerialization.jsonObject(with: data) as? Self {
            return array
        }
        
        return object as? Self
    }
    
    func jg_plainValue() -> Any? {
        return (self as? Array<Element>)?.jg_plainValue()
    }
}
