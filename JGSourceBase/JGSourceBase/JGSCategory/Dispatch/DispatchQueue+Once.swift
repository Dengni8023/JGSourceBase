//
//  DispatchQueue+Once.swift
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/7/13.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import Foundation

/// 对象需要执行once逻辑时，继承JGDispatchQueueOnceUUID协议实现onceToken获取
public protocol JGDispatchQueueOnceUUID {
    var jg_uuid: String { get }
}

struct JGDispatchQueueAssociatedKey {
    // nonisolated(unsafe) static var uuid: UInt8 = 0
    nonisolated(unsafe) static var uuid: String?
}

public extension JGDispatchQueueOnceUUID {
    
    var jg_uuid: String {
        
        objc_sync_enter(self)
        defer {
            // JGSDebugLog("defer")
            objc_sync_exit(self)
        }
        return withUnsafePointer(to: &JGDispatchQueueAssociatedKey.uuid) { key in

            if let uid = objc_getAssociatedObject(self, key) as? String {
                return uid
            }
            
            let uid = UUID().uuidString
            objc_setAssociatedObject(self, key, uid, .OBJC_ASSOCIATION_COPY_NONATOMIC)

            return uid
        }
        
        // UInt8方式代码
        // if let uid = objc_getAssociatedObject(self, &JGDispatchQueueAssociatedKey.uuid) as? String, !uid.isEmpty {
        //    return uid
        // }
        // let uid = UUID().uuidString
        // objc_setAssociatedObject(self, &JGDispatchQueueAssociatedKey.uuid, uid, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        // return uid
    }
}

// MARK: - Once
private final class JGDispatchQueueOnceState: @unchecked Sendable {
    private let lock = NSLock()
    private var _executedIdentifiers: Set<String> = []
    
    var executedIdentifiers: Set<String> {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _executedIdentifiers
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _executedIdentifiers = newValue
        }
    }
    
    func contains(_ token: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return _executedIdentifiers.contains(token)
    }
    
    func insert(_ token: String) {
        lock.lock()
        defer { lock.unlock() }
        _executedIdentifiers.insert(token)
    }
    
    func remove(_ token: String) {
        lock.lock()
        defer { lock.unlock() }
        _executedIdentifiers.remove(token)
    }
}

extension DispatchQueue {
    
    private static let onceState = JGDispatchQueueOnceState()
    
    /// 执行一次代码块逻辑，确保同一个 token 在应用生命周期内只执行一次
    /// 
    /// 使用场景：需要确保某个初始化逻辑或配置代码只执行一次，即使在多线程环境下也能保证线程安全
    /// 
    /// - Parameters:
    ///   - token: 执行标识，对象可继承 JGDispatchQueueOnceUUID，通过 jg_uuid 获取生命周期内的唯一标识
    ///   - block: 需要执行的代码块
    /// 
    /// 线程安全保证：
    /// - 使用 NSLock 进行互斥锁保护，确保同一时间只有一个线程能访问共享的 executedIdentifiers 集合
    /// - defer 语句确保无论函数如何退出（正常返回或提前返回）都会释放锁
    /// - executedIdentifiers 集合存储已执行过的 token，防止重复执行
    public static func jg_once(_ token: String, execute: () -> Void) {
        if onceState.contains(token) {
            return
        }
        onceState.insert(token)
        execute()
    }
    
    /// 清理已执行的标识，用于内存管理
    public static func jg_clearExecutedIdentifier(_ token: String) {
        onceState.remove(token)
    }
}
