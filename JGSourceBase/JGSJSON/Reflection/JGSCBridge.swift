//
//  JGSCBridge.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2024/10/24.
//  Copyright © 2024 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: CBridge.swift
// https://github.com/alibaba/handyjson

@_silgen_name("swift_getTypeByMangledNameInContext")
public func _getTypeByMangledNameInContext(
    _ name: UnsafePointer<UInt8>,
    _ nameLength: Int,
    genericContext: UnsafeRawPointer?,
    genericArguments: UnsafeRawPointer?)
    -> Any.Type?


@_silgen_name("swift_getTypeContextDescriptor")
public func _swift_getTypeContextDescriptor(_ metadata: UnsafeRawPointer?) -> UnsafeRawPointer?
