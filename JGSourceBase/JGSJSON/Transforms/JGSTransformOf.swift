//
//  JGSTransformOf.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2024/10/24.
//  Copyright © 2024 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: TransformOf.swift
// https://github.com/alibaba/handyjson

open class TransformOf<ObjectType, JSONType>: TransformType {
    public typealias Object = ObjectType
    public typealias JSON = JSONType

    private let fromJSON: (JSONType?) -> ObjectType?
    private let toJSON: (ObjectType?) -> JSONType?

    public init(fromJSON: @escaping(JSONType?) -> ObjectType?, toJSON: @escaping(ObjectType?) -> JSONType?) {
        self.fromJSON = fromJSON
        self.toJSON = toJSON
    }

    open func transformFromJSON(_ value: Any?) -> ObjectType? {
        return fromJSON(value as? JSONType)
    }

    open func transformToJSON(_ value: ObjectType?) -> JSONType? {
        return toJSON(value)
    }
}
