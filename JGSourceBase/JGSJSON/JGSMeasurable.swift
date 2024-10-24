//
//  JGSMesurable.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2024/10/21.
//  Copyright © 2024 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: _Measurable
// https://github.com/alibaba/handyjson

private typealias Byte = Int8

public protocol JGSMeasurable {}

extension JGSMeasurable {

    // locate the head of a struct type object in memory
    private mutating func headPointerOfStruct() -> UnsafeMutablePointer<Byte> {
        return withUnsafeMutablePointer(to: &self) {
            return UnsafeMutableRawPointer($0).bindMemory(to: Byte.self, capacity: MemoryLayout<Self>.stride)
        }
    }

    // locating the head of a class type object in memory
    private mutating func headPointerOfClass() -> UnsafeMutablePointer<Byte> {

        let opaquePointer = Unmanaged.passUnretained(self as AnyObject).toOpaque()
        let mutableTypedPointer = opaquePointer.bindMemory(to: Byte.self, capacity: MemoryLayout<Self>.stride)
        return UnsafeMutablePointer<Byte>(mutableTypedPointer)
    }

    // locating the head of an object
    private mutating func headPointer() -> UnsafeMutablePointer<Byte> {
        if Self.self is AnyClass {
            return self.headPointerOfClass()
        } else {
            return self.headPointerOfStruct()
        }
    }

    private func isNSObjectType() -> Bool {
        return (type(of: self) as? NSObject.Type) != nil
    }

    private func getBridgedPropertyList() -> Set<String> {
        if let anyClass = type(of: self) as? AnyClass {
            return _getBridgedPropertyList(anyClass: anyClass)
        }
        return []
    }

    private func _getBridgedPropertyList(anyClass: AnyClass) -> Set<String> {
        if !(anyClass is JGSJSON.Type) {
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
    private static func size() -> Int {
        return MemoryLayout<Self>.size
    }

    // align
    private static func align() -> Int {
        return MemoryLayout<Self>.alignment
    }

    // Returns the offset to the next integer that is greater than
    // or equal to Value and is a multiple of Align. Align must be
    // non-zero.
    private static func offsetToAlignment(value: Int, align: Int) -> Int {
        let m = value % align
        return m == 0 ? 0 : (align - m)
    }
}
