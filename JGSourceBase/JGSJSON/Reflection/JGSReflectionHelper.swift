//
//  JGSReflectionHelper.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2024/10/24.
//  Copyright © 2024 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: ReflectionHelper.swift
// https://github.com/alibaba/handyjson

struct ReflectionHelper {

    static func mutableStorage<T>(instance: inout T) -> UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(mutating: storage(instance: &instance))
    }

    static func storage<T>(instance: inout T) -> UnsafeRawPointer {
        if type(of: instance) is AnyClass {
            let opaquePointer = Unmanaged.passUnretained(instance as AnyObject).toOpaque()
            return UnsafeRawPointer(opaquePointer)
        } else {
            return withUnsafePointer(to: &instance) { pointer in
                return UnsafeRawPointer(pointer)
            }
        }
    }
}


