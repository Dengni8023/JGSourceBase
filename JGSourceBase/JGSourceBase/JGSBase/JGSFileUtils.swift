//
//  JGSFileUtils.swift
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/25.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import Foundation

@objcMembers public
class JGSFileUtils: NSObject {

    // MARK: - MIMEType
    /// 根据文件路径获取 MIME 类型
    /// - Parameter file: 文件路径
    /// - Returns: MIME 类型字符串，如果路径无效或文件不存在则返回 nil
    @objc(getMIMETypeOfFile:)
    public static func getMIMEType(of file: String) -> String? {
        guard !file.isEmpty, FileManager.default.fileExists(atPath: file) else {
            return nil
        }
        let url = URL(fileURLWithPath: file)
        return getMIMEType(of: url)
    }
    
    /// 根据 URL 获取 MIME 类型（通过发送 HEAD 请求）
    /// - Parameter url: 文件 URL
    /// - Returns: MIME 类型字符串，如果 URL 无效或请求失败则返回 nil
    @objc(getMIMETypeOfURL:)
    public static func getMIMEType(of url: URL) -> String? {
        guard !url.absoluteString.isEmpty else {
            return nil
        }
        
        // 使用线程安全的容器类来存储结果，避免并发访问问题
        // @unchecked Sendable: NSLock 本身不遵循 Sendable，但它是线程安全的，且我们通过锁保护了所有访问
        final class ResultContainer: @unchecked Sendable {
            private let lock = NSLock()
            private var _mimeType: String?
            
            var mimeType: String? {
                get {
                    lock.lock()
                    defer { lock.unlock() }
                    return _mimeType
                }
                set {
                    lock.lock()
                    defer { lock.unlock() }
                    _mimeType = newValue
                }
            }
        }
        
        let container = ResultContainer()
        let semaphore = DispatchSemaphore(value: 0)
        
        // JGSDebugLog("begin:", Date().timeIntervalSince1970)
        // URLSession.dataTask 本身就是异步执行的，无需额外的全局队列调度
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { _, response, error in
            // HEAD 请求不返回数据，只需检查响应是否成功
            if error == nil {
                container.mimeType = response?.mimeType
            }
            semaphore.signal()
        }.resume()

        // 等待异步请求完成（等待5秒）
        _ = semaphore.wait(timeout: .now() + .seconds(5))
        // JGSDebugLog("end:", Date().timeIntervalSince1970)
        return container.mimeType
    }
    
    // MARK: - Plist
    
    /// plist 文件整理
    /// - Parameters:
    ///   - path: 文件路径
    ///   - rewrite: 是否覆盖写回源文件
    ///   - completion: 完成回调，(标准的JSON-Dictionary/Array文件内容, 读取/回写结果)
    public static func sortPlistFile(_ path: String, rewrite: Bool, completion: ((_ content: Any?, _ success: Bool) -> Void)? = nil) {
        // 检查路径有效性
        guard !path.isEmpty, FileManager.default.fileExists(atPath: path) else {
            completion?(nil, false)
            return
        }
        let url = URL(fileURLWithPath: path)
        sortPlistFile(url, rewrite: rewrite, completion: completion)
    }
    
    /// plist 文件整理，对 plist 文件中的数据进行 key 排序并格式化输出
    /// - Parameters:
    ///   - url: 文件路径
    ///   - rewrite: 是否覆盖写回源文件
    ///   - completion: 完成回调，(标准的Dictionary/Array文件内容, 读取/回写结果)
    /// 
    /// 处理流程：
    /// 1. 读取并解析 plist 文件内容
    /// 2. 如果 rewrite 为 false，直接返回读取的内容
    /// 3. 如果 rewrite 为 true，尝试将 plist 转换为 JSON 格式进行排序：
    ///    a. 将 plist 对象序列化为 JSON Data（key 排序、格式化输出）
    ///    b. 将 JSON Data 解析回对象
    ///    c. 将排序后的对象转换为 plist XML 格式
    ///    d. 原子写入原文件
    /// 4. 如果转换过程失败，返回原始内容和失败状态
    @objc(sortPlistFileWithURL:rewrite:completion:)
    public static func sortPlistFile(_ url: URL, rewrite: Bool, completion: ((_ content: Any?, _ success: Bool) -> Void)? = nil) {
        
        // 检查路径有效性并读取文件内容
        // 使用 try? 处理文件不存在或读取错误的情况
        guard !url.absoluteString.isEmpty,
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        else {
            completion?(nil, false)
            return
        }
        
        // 如果不需要写回，直接返回读取的内容
        guard rewrite else {
            completion?(plist, true)
            return
        }
        
        // 通过 JSON 中间格式进行 key 排序
        // 原理：利用 JSONSerialization 的 sortedKeys 选项对字典的 key 进行排序
        // 步骤：
        // 1. plist 对象 → JSON Data（排序）
        // 2. JSON Data → JSON 对象（保持排序）
        // 3. JSON 对象 → plist Data（XML 格式）
        // 4. plist Data → 写入文件
        if JSONSerialization.isValidJSONObject(plist),
           let jsonData = try? JSONSerialization.data(withJSONObject: plist, options: [.sortedKeys, .prettyPrinted]),
           let jsonObj = try? JSONSerialization.jsonObject(with: jsonData, options: []),
           PropertyListSerialization.propertyList(jsonObj, isValidFor: .xml),
           let sortData = try? PropertyListSerialization.data(fromPropertyList: jsonObj, format: .xml, options: 0) {
            do {
                // 使用 .atomic 选项确保写入的原子性，防止写入过程中文件损坏
                try sortData.write(to: url, options: .atomic)
                completion?(plist, true)
                return
            } catch let error {
                JGSDebugLog("error:", error)
            }
        }
        
        // 如果排序过程失败，返回原始内容和失败状态
        completion?(plist, false)
    }
    
    // MARK: - JSON
    /// json/json5 文件整理，必须是标准的JSON，即顶层是Dictionary、或者Array，json5文件会丢失注释内容
    /// - Parameters:
    ///   - path: 文件路径
    ///   - rewrite: 是否覆盖写回源文件
    ///   - completion: 完成回调，(标准的JSON字符串(Dictionary/Array), 读取/回写结果)
    public static func sortJSONFile(_ path: String, rewrite: Bool, completion: ((_ content: String?, _ success: Bool) -> Void)? = nil) {
        // 检查路径有效性
        guard !path.isEmpty, FileManager.default.fileExists(atPath: path) else {
            completion?(nil, false)
            return
        }
        let url = URL(fileURLWithPath: path)
        sortJSONFile(url, rewrite: rewrite, completion: completion)
    }
    
    /// json/json5 文件整理，必须是标准的JSON，即顶层是Dictionary、或者Array
    /// - Parameters:
    ///   - url: 文件路径
    ///   - rewrite: 是否覆盖写回源文件
    ///   - completion: 完成回调，(标准的JSON字符串(Dictionary/Array), 读取/回写结果)
    @objc(sortJSONFileWithURL:rewrite:completion:)
    public static func sortJSONFile(_ url: URL, rewrite: Bool, completion: ((_ content: String?, _ success: Bool) -> Void)? = nil) {
        
        var readOps: JSONSerialization.ReadingOptions = []
        if #available(iOS 15, *) {
            readOps.insert(.json5Allowed)
        }
        
        guard !url.absoluteString.isEmpty, // 检查路径有效性
              let data = try? Data(contentsOf: url), // 文件原始内容读取
              let json = try? JSONSerialization.jsonObject(with: data, options: readOps), // 原始内容解析为Object
              let sortData = try? JSONSerialization.data(withJSONObject: json, options: [.sortedKeys, .prettyPrinted]), // Object内容排序整理
              let sortJSON = String(data: sortData, encoding: .utf8)
        else {
            completion?(nil, false)
            return
        }
        
        guard rewrite else {
            completion?(sortJSON, true)
            return
        }
        
        // 如果是标准JSON，对JSON数据进行key排序转Data
        // 再通过plist写入文件
        do {
            try sortJSON.write(to: url, atomically: true, encoding: .utf8)
            completion?(sortJSON, true)
            return
        } catch let error {
            JGSDebugLog("error:", error)
        }
        
        completion?(sortJSON, false)
    }
}
