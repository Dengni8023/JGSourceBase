//
//  JGSAnyExtension.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/5/9.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

protocol JGSAnyExtension {}
extension JGSAnyExtension {
    public static func jg_isValueTypeOrSubtype(_ value: Any) -> Bool {
        return value is Self
    }

    public static func jg_value(from storage: UnsafeRawPointer) -> Any {
        return storage.assumingMemoryBound(to: self).pointee
    }

    public static func jg_write(_ value: Any, to storage: UnsafeMutableRawPointer) {
        guard let this = value as? Self else {
            return
        }
        storage.assumingMemoryBound(to: self).pointee = this
    }

    public static func jg_takeValue(from anyValue: Any) -> Self? {
        return anyValue as? Self
    }
}

func jg_extensions(of type: Any.Type) -> JGSAnyExtension.Type {
    struct Extensions: JGSAnyExtension {}
    var extensions: JGSAnyExtension.Type = Extensions.self
    withUnsafePointer(to: &extensions) { pointer in
        UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: Any.Type.self).pointee = type
    }
    return extensions
}

func jg_extensions(of value: Any) -> JGSAnyExtension {
    struct Extensions: JGSAnyExtension {}
    var extensions: JGSAnyExtension = Extensions()
    withUnsafePointer(to: &extensions) { pointer in
        UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: Any.self).pointee = value
    }
    return extensions
}

/// Tests if `value` is `type` or a subclass of `type`
func jg_value(_ value: Any, is type: Any.Type) -> Bool {
    return jg_extensions(of: type).jg_isValueTypeOrSubtype(value)
}

/// Tests equality of any two existential types
func == (lhs: Any.Type, rhs: Any.Type) -> Bool {
//    return Metadata(type: lhs) == Metadata(type: rhs)
    return false
}

// MARK: AnyExtension + Storage

extension JGSAnyExtension {
    mutating func jg_storage() -> UnsafeRawPointer {
        if type(of: self) is AnyClass {
            let opaquePointer = Unmanaged.passUnretained(self as AnyObject).toOpaque()
            return UnsafeRawPointer(opaquePointer)
        } else {
            return withUnsafePointer(to: &self) { pointer in
                UnsafeRawPointer(pointer)
            }
        }
    }
}
