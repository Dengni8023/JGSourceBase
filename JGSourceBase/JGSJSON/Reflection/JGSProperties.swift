//
//  JGSProperties.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2024/10/24.
//  Copyright © 2024 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: Properties.swift
// https://github.com/alibaba/handyjson

/// An instance property
struct Property {
    let key: String
    let value: Any

    /// An instance property description
    struct Description {
        public let key: String
        public let type: Any.Type
        public let offset: Int
        public func write(_ value: Any, to storage: UnsafeMutableRawPointer) {
            return extensions(of: type).write(value, to: storage.advanced(by: offset))
        }
    }
}

/// Retrieve properties for `instance`
func getProperties(forInstance instance: Any) -> [Property]? {
    if let props = getProperties(forType: type(of: instance)) {
        var copy = extensions(of: instance)
        let storage = copy.storage()
        return props.map {
            nextProperty(description: $0, storage: storage)
        }
    }
    return nil
}

private func nextProperty(description: Property.Description, storage: UnsafeRawPointer) -> Property {
    return Property(
        key: description.key,
        value: extensions(of: description.type).value(from: storage.advanced(by: description.offset))
    )
}

/// Retrieve property descriptions for `type`
func getProperties(forType type: Any.Type) -> [Property.Description]? {
    if let structDescriptor = Metadata.Struct(anyType: type) {
        return structDescriptor.propertyDescriptions()
    } else if let classDescriptor = Metadata.Class(anyType: type) {
        return classDescriptor.propertyDescriptions()
    } else if let objcClassDescriptor = Metadata.ObjcClassWrapper(anyType: type),
        let targetType = objcClassDescriptor.targetType {
        return getProperties(forType: targetType)
    }
    return nil
}
