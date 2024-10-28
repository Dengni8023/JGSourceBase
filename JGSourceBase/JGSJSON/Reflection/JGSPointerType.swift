//
//  JGSPointerType.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2024/10/24.
//  Copyright © 2024 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: PointerType.swift
// https://github.com/alibaba/handyjson

protocol PointerType : Equatable {
    associatedtype Pointee
    var pointer: UnsafePointer<Pointee> { get set }
}

extension PointerType {
    init<R>(pointer: UnsafePointer<R>) {
        func cast<T, U>(_ value: T) -> U {
            return unsafeBitCast(value, to: U.self)
        }
        self = cast(UnsafePointer<Pointee>(pointer))
    }
}

func == <T: PointerType>(lhs: T, rhs: T) -> Bool {
    return lhs.pointer == rhs.pointer
}
