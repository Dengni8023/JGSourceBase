//
//  NSNumber+JGSBase.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/12.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

// MARK: - JGSBuildInBridgeType

extension NSNumber: JGSBuildInBridgeType {
    
    static func jg_transform(from object: Any?) -> JGSBuildInBridgeType? {
        guard let object = object else {
            return nil
        }
        
        switch object {
        case let num as NSNumber:
            return num
        case let str as String:
            let lower = str.lowercased()
            if ["0", "f", "false", "n", "no"].contains(lower) {
                return NSNumber(booleanLiteral: false)
            } else if ["1", "t", "true", "y", "yes"].contains(lower) {
                return NSNumber(booleanLiteral: true)
            } else {
                // normal number
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                return formatter.number(from: str)
            }
        default:
            return nil
        }
    }
    
    func jg_plainValue() -> Any? {
        return self
    }
}
