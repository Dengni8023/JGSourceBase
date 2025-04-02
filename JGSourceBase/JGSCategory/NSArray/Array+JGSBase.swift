//
//  Array+JGSBase.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/7.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

public
extension Array {
    
    func jg_object<T: JGSTransformable>(at index: Int) -> T? {
        guard index >= 0 && index < count else { return nil }
        return T.jg_transform(from: self[index])
    }
    
    func jg_object<T>(at index: Int) -> T? {
        guard index >= 0 && index < count else { return nil }
        return (self[index] as? T)
    }
    
    func jg_string(at index: Int) -> String? {
        return jg_object<String>(at: index)
    }
    
    func jg_number(at index: Int) -> NSNumber? {
        return jg_object<NSNumber>(at: index)
    }
    
    func jg_int(at index: Int) -> Int? {
        return jg_object<Int>(at: index)
    }
    
    func jg_float(at index: Int) -> Float? {
        return jg_object<Float>(at: index)
    }
    
    func jg_double(at index: Int) -> Double? {
        return jg_object<Double>(at: index)
    }
    
    func jg_bool(at index: Int) -> Bool? {
        return jg_object<Bool>(at: index)
    }
    
    func jg_dict<K, V>(at index: Int) -> Dictionary<K, V>? {
        return jg_object<Dictionary<K, V>>(at: index)
    }
    
    func jg_array<T>(at index: Int) -> Array<T>? {
        return jg_object<Array<T>>(at: index)
    }
    
    func jg_set<T>(at index: Int) -> Set<T>? {
        if let arr: [T] = jg_array(at: index) {
            return Set(arr)
        }
        return nil
    }
}
