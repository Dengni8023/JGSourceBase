//
//  JGSCommandLine.swift
//  JGSCommandLine
//
//  Created by Mei JiGao on 2026/6/26.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import Foundation

class JGSCommandLine {
    
    private let repoLoction = "/Users/meijigao/Desktop/Git•GitHub/Dengni8023/JGSourceBase_spm"
    static let shared = {
        let ins = JGSCommandLine()
        return ins
    }()
    
    func sortPlistFiles() {
        
        let sortFiles = [
            "JGSourceBase/JGSourceBase/Resources/PrivacyInfo.xcprivacy"
        ]
        let dirUrl = URL(filePath: repoLoction)
        sortFiles.forEach { file in
            let fileUrl = dirUrl.appending(component: file)
            JGSLog("getMIMEType:", JGSFileUtils.getMIMEType(of: fileUrl))
            JGSFileUtils.sortPlistFile(fileUrl, rewrite: true) { content, success in
                JGSLog("Plist文件处理\(success ? "成功" : "失败"):", fileUrl.path(percentEncoded: false))
            }
        }
    }
    
    func sortJSONFiles() {
        
        let sortFiles = [String]()
        let dirUrl = URL(filePath: repoLoction)
        sortFiles.forEach { file in
            let fileUrl = dirUrl.appending(component: file)
            JGSLog("getMIMEType:", JGSFileUtils.getMIMEType(of: fileUrl))
            JGSFileUtils.sortJSONFile(fileUrl, rewrite: true) { content, success in
                JGSLog("JSON文件处理\(success ? "成功" : "失败"):", fileUrl.path(percentEncoded: false))
            }
        }
    }
    
    func sortAndAESEncryptionDeviceList() {
        
        // 原始数据在json5文件维护
        let deviceJson5 = "JGSourceBase/JGSourceBase/Resources/JGSiOSDeviceList-Origin.json5"
        let fileUrl = URL(filePath: repoLoction).appending(component: deviceJson5)
        JGSLog("getMIMEType:", JGSFileUtils.getMIMEType(of: fileUrl))
        // json5文件读取
        JGSFileUtils.sortJSONFile(fileUrl, rewrite: false) { content, success in
            JGSLog("iOS设备JSON5文件处理读取\(success ? "成功" : "失败"):", fileUrl.path(percentEncoded: false))
            
            guard success, let data = content?.data(using: .utf8),
                  let content = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: [[String: Any]]] else {
                return
            }
            
            // json源文件转设备清单json文件
            var diviceList: [String: String] = [:]
            content.flatMap({ (key: String, value: [[String: Any]]) in
                value
            }).forEach { tmp in

                guard let generation = tmp["Generation"] as? String,
                      let identifiers = tmp["Identifier"] as? [String]
                else {
                    return
                }
                
                identifiers.forEach { identifier in
                    diviceList[identifier] = generation
                }
            }
            
            guard let listData = try? JSONSerialization.data(withJSONObject: diviceList, options: [.sortedKeys, .prettyPrinted]) else { return }
            do {
                let diviceListFile = fileUrl.deletingLastPathComponent().appending(path: "JGSiOSDeviceList.json")
                try listData.write(to: diviceListFile, options: .atomic)
                JGSLog("iOS设备文件写入成功:", fileUrl.path(percentEncoded: false))
            } catch let error {
                JGSLog("iOS设备文件写入失败:", fileUrl.path(percentEncoded: false), "error:", error)
            }
            
            // TODO: 设备清单json文件加密写入打包资源文件
        }
    }
}
