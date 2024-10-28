//
//  JGSAnyExtensions.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2024/10/24.
//  Copyright © 2024 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: AnyExtensions.swift
// https://github.com/alibaba/handyjson

protocol JGSAnyExtensions {}

extension JGSAnyExtensions {
    
    static func isValueTypeOrSubtype(_ value: Any) -> Bool {
        return value is Self
    }

    static func value(from storage: UnsafeRawPointer) -> Any {
        return storage.assumingMemoryBound(to: self).pointee
    }

    static func write(_ value: Any, to storage: UnsafeMutableRawPointer) {
        guard let this = value as? Self else {
            return
        }
        storage.assumingMemoryBound(to: self).pointee = this
    }

    static func takeValue(from anyValue: Any) -> Self? {
        return anyValue as? Self
    }
}

func extensions(of type: Any.Type) -> JGSAnyExtensions.Type {
    struct Extensions : JGSAnyExtensions {}
    var extensions: JGSAnyExtensions.Type = Extensions.self
    withUnsafePointer(to: &extensions) { pointer in
        UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: Any.Type.self).pointee = type
    }
    return extensions
}

func extensions(of value: Any) -> JGSAnyExtensions {
    struct Extensions : JGSAnyExtensions {}
    var extensions: JGSAnyExtensions = Extensions()
    withUnsafePointer(to: &extensions) { pointer in
        UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: Any.self).pointee = value
    }
    return extensions
}

/// Tests if `value` is `type` or a subclass of `type`
func value(_ value: Any, is type: Any.Type) -> Bool {
    return extensions(of: type).isValueTypeOrSubtype(value)
}

/// Tests equality of any two existential types
func == (lhs: Any.Type, rhs: Any.Type) -> Bool {
    return Metadata(type: lhs) == Metadata(type: rhs)
}

// MARK: AnyExtension + Storage
extension JGSAnyExtensions {

    mutating func storage() -> UnsafeRawPointer {
        if type(of: self) is AnyClass {
            let opaquePointer = Unmanaged.passUnretained(self as AnyObject).toOpaque()
            return UnsafeRawPointer(opaquePointer)
        } else {
            return withUnsafePointer(to: &self) { pointer in
                return UnsafeRawPointer(pointer)
            }
        }
    }
}
