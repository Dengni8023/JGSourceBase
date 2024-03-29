//
//  Array+JGSBase.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/7.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

public extension Array {
    
    func jg_object<T: JGSTransformable>(at index: Int, default value: T? = nil) -> T? {
        guard index >= 0 && index < count else { return value }
        return T.jg_transform(from: self[index]) ?? value
    }
    
    func jg_object<T>(at index: Int, default value: T? = nil) -> T? {
        guard index >= 0 && index < count else { return value }
        return (self[index] as? T) ?? value
    }
    
    func jg_bool(at index: Int, default value: Bool? = nil) -> Bool? {
        return jg_object(at: index, default: value)
    }
    
    func jg_int(at index: Int, default value: Int? = nil) -> Int? {
        return jg_object(at: index, default: value)
    }
    
    func jg_float(at index: Int, default value: Float? = nil) -> Float? {
        return jg_object(at: index, default: value)
    }
    
    func jg_string(at index: Int, default value: String? = nil) -> String? {
        return jg_object(at: index, default: value)
    }
}
