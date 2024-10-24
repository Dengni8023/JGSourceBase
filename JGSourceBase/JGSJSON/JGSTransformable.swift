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

public protocol JGSTransformable: JGSMeasurable {
    // 定义optional必须引入 objc
    // 此处不引入 objc，在扩展中定义方法
    // 继承时重写扩展方法
    // static func jg_transform(from object: Any?) -> Self?
    // optional func jg_plainValue() -> Any?
}

public extension JGSTransformable {
    static func jg_transform(from object: Any?) -> Self? {
        guard let object = object else { return nil }

        if let typeObj = object as? Self {
            return typeObj
        }
        
        switch self {
        case let type as JGSBuildInBridgeType.Type:
            return type.jg_transform(from: object) as? Self
        case let type as JGSBuildInBasicType.Type:
            return type.jg_transform(from: object) as? Self
        case let type as JGSRawRepresentable.Type:
            return type.jg_transform(from: object) as? Self
        default:
            return nil
        }
    }
    
    func jg_plainValue() -> Any? {
        switch self {
        case let rawValue as JGSBuildInBridgeType:
            return rawValue.jg_plainValue()
        case let rawValue as JGSBuildInBasicType:
            return rawValue.jg_plainValue()
        case let rawValue as JGSRawRepresentable:
            return rawValue.jg_plainValue()
        default:
            return nil
        }
    }
}
