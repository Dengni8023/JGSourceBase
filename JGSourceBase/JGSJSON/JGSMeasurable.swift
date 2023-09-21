//
//  JGSMeasurable.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/8/11.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

typealias Byte = Int8
public protocol JGSMeasurable {}

extension JGSMeasurable {
    // locate the head of a struct type object in memory
    private mutating func jg_headPointerOfStruct() -> UnsafeMutablePointer<Byte> {
        return withUnsafeMutablePointer(to: &self) { T in
            return UnsafeMutableRawPointer(T).bindMemory(to: Byte.self, capacity: MemoryLayout<Self>.stride)
        }
    }

    // locating the head of a class type object in memory
    private mutating func jg_headPointerOfClass() -> UnsafeMutablePointer<Byte> {
        let opaquePointer = Unmanaged.passUnretained(self as AnyObject).toOpaque()
        let mutableTypedPointer = opaquePointer.bindMemory(to: Byte.self, capacity: MemoryLayout<Self>.stride)
        return UnsafeMutablePointer<Byte>(mutableTypedPointer)
    }
    
    // locating the head of an object
    mutating func jg_headPointer() -> UnsafeMutablePointer<Byte> {
        if Self.self is AnyClass {
            return jg_headPointerOfClass()
        }
        return jg_headPointerOfStruct()
    }
    
    func jg_isNSObjectType() -> Bool {
        return (type(of: self) as? NSObject.Type) != nil
    }

    func jg_getBridgedPropertyList() -> Set<String> {
        if let anyClass = type(of: self) as? AnyClass {
            return jg_getBridgedPropertyList(anyClass: anyClass)
        }
        return []
    }
    
    private func jg_getBridgedPropertyList(anyClass: AnyClass) -> Set<String> {
        if !(anyClass is JGSJSON.Type) {
            return []
        }
        var propertyList = Set<String>()
        if let superClass = class_getSuperclass(anyClass), superClass != NSObject.self {
            propertyList = propertyList.union(jg_getBridgedPropertyList(anyClass: superClass))
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
    static func jg_size() -> Int {
        return MemoryLayout<Self>.size
    }

    // align
    static func jg_align() -> Int {
        return MemoryLayout<Self>.alignment
    }

    // Returns the offset to the next integer that is greater than or equal to Value and is a multiple of Align.
    // Align must be non-zero.
    static func jg_offsetToAlignment(value: Int, align: Int) -> Int {
        let m = value % align
        return m == 0 ? 0 : (align - m)
    }
}
