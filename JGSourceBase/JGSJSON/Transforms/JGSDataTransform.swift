//
//  JGSDataTransform.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2024/10/24.
//  Copyright © 2024 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: DataTransform.swift
// https://github.com/alibaba/handyjson

open class DataTransform: TransformType {
    public typealias Object = Data
    public typealias JSON = String

    public init() {}

    open func transformFromJSON(_ value: Any?) -> Data? {
        guard let string = value as? String else{
            return nil
        }
        return Data(base64Encoded: string)
    }

    open func transformToJSON(_ value: Data?) -> String? {
        guard let data = value else{
            return nil
        }
        return data.base64EncodedString()
    }
}
