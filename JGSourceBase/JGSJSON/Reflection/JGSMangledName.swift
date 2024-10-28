//
//  JGSMangledName.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2024/10/24.
//  Copyright © 2024 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: MangledName.swift
// https://github.com/alibaba/handyjson

// mangled name might contain 0 but it is not the end, do not just use strlen
func getMangledTypeNameSize(_ mangledName: UnsafePointer<UInt8>) -> Int {
   // TODO: should find the actually size
   return 256
}
