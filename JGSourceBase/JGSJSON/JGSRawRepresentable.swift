//
//  JGSRawRepresentable.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/9/25.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

// MARK: - RawRepresentable
public protocol JGSRawRepresentable: JGSTransformable {
    static func jg_transform(from object: Any?) -> Self?
    func jg_plainValue() -> Any?
}

extension RawRepresentable where Self: JGSRawRepresentable {
    public static func jg_transform(from object: Any?) -> Self? {
        if let transformableType = RawValue.self as? JGSTransformable.Type {
            if let typedValue = transformableType.jg_transform(from: object) {
                return Self(rawValue: typedValue as! RawValue)
            }
        }
        return nil
    }
    
    public func jg_plainValue() -> Any? {
        return self.rawValue
    }
}
