//
//  JGSProperty.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/5/9.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

/// 对象属性
fileprivate struct JGSProperty {
    let key: String
    let value: Any
    
    /// Property Description
    fileprivate struct Description {
        let key: String
        let type: Any.Type
        let offset: Int
        func write(_ value: Any, to storage: UnsafeMutableRawPointer) {
            //return jg_extensions(of: type).write
        }
    }
}
