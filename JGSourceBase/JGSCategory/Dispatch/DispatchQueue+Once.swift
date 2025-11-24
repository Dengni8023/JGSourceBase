//
//  DispatchQueue+Once.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2025/11/18.
//  Copyright © 2025 MeiJiGao. All rights reserved.
//

import Foundation

/// 对象需要执行once逻辑时，继承JGDispatchQueueOnceUUID协议实现onceToken获取
protocol JGDispatchQueueOnceUUID {
    var jg_uuid: String { get }
}

extension JGDispatchQueueOnceUUID {
    var jg_uuid: String {
        return UUID().uuidString
    }
}

// MARK: - Once
extension DispatchQueue {
    
    private static var executedIdentifiers: Set<String> = []
    
    /// 执行一次代码块逻辑
    /// - Parameters:
    ///   - token: 执行标识，对象可继承 JGDispatchQueueOnceUUID，通过 jg_uuid 获取生命周期内的唯一标识
    ///   - block: 执行逻辑
    public static func jg_once(_ token: String, execute: () -> Void) {
        objc_sync_enter(self) // 加锁
        defer {
            objc_sync_exit(self) // 确保解锁
        }
        if executedIdentifiers.contains(token) {
            return // defer 确保这里也会解锁
        }
        
        executedIdentifiers.insert(token) // 线程安全地修改共享数据
        execute() // defer 确保函数结束时自动解锁
    }
    
    /// 清理已执行的标识，用于内存管理
    public static func jg_clearExecutedIdentifier(_ token: String) {
        objc_sync_enter(self) // 加锁
        defer { objc_sync_exit(self) } // 确保解锁

        executedIdentifiers.remove(token) // defer 确保函数结束时自动解锁
    }
}
