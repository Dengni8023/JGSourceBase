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

typealias Byte = Int8

public protocol JGSMeasurable {}
extension JGSMeasurable {
    // locate the head of a struct type object in memory
    mutating func headPointerOfStruct() -> UnsafeMutablePointer<Byte> {
        return withUnsafeMutablePointer(to: &self) {
            return UnsafeMutableRawPointer($0).bindMemory(to: Byte.self, capacity: MemoryLayout<Self>.stride)
        }
    }

    // locating the head of a class type object in memory
    mutating func headPointerOfClass() -> UnsafeMutablePointer<Byte> {
        let opaquePointer = Unmanaged.passUnretained(self as AnyObject).toOpaque()
        let mutableTypedPointer = opaquePointer.bindMemory(to: Byte.self, capacity: MemoryLayout<Self>.stride)
        return UnsafeMutablePointer<Byte>(mutableTypedPointer)
    }

    // locating the head of an object
    mutating func headPointer() -> UnsafeMutablePointer<Byte> {
        if Self.self is AnyClass {
            return self.headPointerOfClass()
        } else {
            return self.headPointerOfStruct()
        }
    }

    func isNSObjectType() -> Bool {
        return (type(of: self) as? NSObject.Type) != nil
    }

    func getBridgedPropertyList() -> Set<String> {
        if let anyClass = type(of: self) as? AnyClass {
            return _getBridgedPropertyList(anyClass: anyClass)
        }
        return []
    }

    func _getBridgedPropertyList(anyClass: AnyClass) -> Set<String> {
        if !(anyClass is HandyJSON.Type) {
            return []
        }
        var propertyList = Set<String>()
        if let superClass = class_getSuperclass(anyClass), superClass != NSObject.self {
            propertyList = propertyList.union(_getBridgedPropertyList(anyClass: superClass))
        }
        let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        if let props = class_copyPropertyList(anyClass, count) {
            for i in 0 ..< count.pointee {
                let name = String(cString: property_getName(props.advanced(by: Int(i)).pointee))
                propertyList.insert(name)
            }
            free(props)
        }
        count.deallocate()
        return propertyList
    }

    // memory size occupy by self object
    static func size() -> Int {
        return MemoryLayout<Self>.size
    }

    // align
    static func align() -> Int {
        return MemoryLayout<Self>.alignment
    }

    // Returns the offset to the next integer that is greater than
    // or equal to Value and is a multiple of Align. Align must be
    // non-zero.
    static func offsetToAlignment(value: Int, align: Int) -> Int {
        let m = value % align
        return m == 0 ? 0 : (align - m)
    }
}

public protocol JGSTransformable: JGSMeasurable {
    // 定义optional必须引入 objc
    // 此处不引入 objc，在扩展中定义方法
    // 继承时重写扩展方法
    // static func jg_transform(from object: Any?) -> Self?
    // optional func jg_plainValue() -> Any?
}

extension JGSTransformable {
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

public protocol _Transformable: JGSMeasurable {}
extension _Transformable {

    static func transform(from object: Any) -> Self? {
        if let typedObject = object as? Self {
            return typedObject
        }
        switch self {
        case let type as _BuiltInBridgeType.Type:
            return type._transform(from: object) as? Self
        case let type as _BuiltInBasicType.Type:
            return type._transform(from: object) as? Self
        case let type as _RawEnumProtocol.Type:
            return type._transform(from: object) as? Self
        case let type as _ExtendCustomModelType.Type:
            return type._transform(from: object) as? Self
        default:
            return nil
        }
    }

    func plainValue() -> Any? {
        switch self {
        case let rawValue as _BuiltInBridgeType:
            return rawValue._plainValue()
        case let rawValue as _BuiltInBasicType:
            return rawValue._plainValue()
        case let rawValue as _RawEnumProtocol:
            return rawValue._plainValue()
        case let rawValue as _ExtendCustomModelType:
            return rawValue._plainValue()
        default:
            return nil
        }
    }
}

