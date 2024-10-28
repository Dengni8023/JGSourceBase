//
//  JGSEnumTransform.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2024/10/24.
//  Copyright © 2024 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: EnumTransform.swift
// https://github.com/alibaba/handyjson

open class EnumTransform<T: RawRepresentable>: TransformType {
    public typealias Object = T
    public typealias JSON = T.RawValue

    public init() {}

    open func transformFromJSON(_ value: Any?) -> T? {
        if let raw = value as? T.RawValue {
            return T(rawValue: raw)
        }
        return nil
    }

    open func transformToJSON(_ value: T?) -> T.RawValue? {
        if let obj = value {
            return obj.rawValue
        }
        return nil
    }
}
