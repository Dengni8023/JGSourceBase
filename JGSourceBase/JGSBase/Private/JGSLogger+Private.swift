//
//  JGSLogger+Private.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2025/7/7.
//  Copyright © 2025 MeiJiGao. All rights reserved.
//

import Foundation

private let JGSLogLevelInfoMap: [JGSLogLevel: JGSLogLevelDetailInfo] = [
    .debug: JGSLogLevelDetailInfo(emoji: "🛠", level: "Debug"),
    .info: JGSLogLevelDetailInfo(emoji: "ℹ️", level: "Info"),
    .warn: JGSLogLevelDetailInfo(emoji: "⚠️", level: "Warn"),
    .error: JGSLogLevelDetailInfo(emoji: "❌", level: "Error"),
]

// 此方法需要给内部OC方法使用，必须使用public，即使是内部OC方法
internal func JGSLogDetailInfo(_ level: JGSLogLevel) -> JGSLogLevelDetailInfo {
    return JGSLogLevelInfoMap[level] ?? JGSLogLevelDetailInfo(emoji: "🛠", level: "Debug")
}

//internal let JGSLogNil2NullString = "(null)" // 与 OC 保持一致
internal let JGSLogNil2NullString = "nil" // 与 Swift 保持一致

// MARK: - 重写 description
internal protocol JGSLogDescription {
    
    /// 日志输出描述，类似
    /// 1. CustomStringConvertible 协议 description 方法
    /// 2. OC 重写 description 方法
    /// - Returns: 日志输出内容
    //var jg_logDescription: String { get }
    func jg_logDescription(level: Int64) -> String
}

extension Dictionary: JGSLogDescription {}
extension Array: JGSLogDescription {}
extension String: JGSLogDescription {}

extension NSDictionary: JGSLogDescription {}
extension NSArray: JGSLogDescription {}
extension NSString: JGSLogDescription {}

internal extension JGSLogDescription {
    
    func jg_logDescription(level: Int64 = 0) -> String {
        switch self {
        case let validJsonObj where JSONSerialization.isValidJSONObject(validJsonObj):
            
            var options: JSONSerialization.WritingOptions = [.sortedKeys, .prettyPrinted]
            if #available(iOS 13.0, *) {
                options.insert(.withoutEscapingSlashes)
            }
            
            // key升序整理、格式化输出、禁用正斜杠"/"前增加反斜杠"\"转译
            var retDesc = ""
            if let data = try? JSONSerialization.data(withJSONObject: validJsonObj, options: options) {
                retDesc = String(data: data, encoding: .utf8) ?? "JGSLog JSONSerialization error"
                retDesc = retDesc.replacingOccurrences(of: "\\/", with: "/") // Below iOS 13
            }
            
            if retDesc.count == 0 {
                retDesc = "JGSLog JSONSerialization error"
            }
            return retDesc
            
        case let dictObj where dictObj is Dictionary<AnyHashable, Any>?:
            
            var retDesc = "{\n"
            var tabDesc = ""
            for _ in 0..<level {
                tabDesc.append(contentsOf: "\t")
            }
            
            let dictObj = dictObj as? Dictionary<AnyHashable, Any>
            dictObj?.forEach({ (key: AnyHashable, value: Any) in
                
                if value is JGSLogDescription {
                    // Dictionary、Array、String
                    let logObj = value as! JGSLogDescription
                    if logObj is String {
                        retDesc.append("\(tabDesc)\t\"\(key as CVarArg)\": \"\(logObj.jg_logDescription())\",\n")
                    } else {
                        retDesc.append("\(tabDesc)\t\"\(key as CVarArg)\": \(logObj.jg_logDescription()),\n")
                    }
                }
                else if value is CustomStringConvertible {
                    // CustomStringConvertible
                    let logObj = value as! CustomStringConvertible
                    retDesc.append("\(tabDesc)\t\"\(key as CVarArg)\": \(logObj.description),\n")
                }
                else {
                    // Other
                    retDesc.append("\(tabDesc)\t\"\(key as CVarArg)\": \(value),\n")
                }
            })
            retDesc.append("\(tabDesc)}")
            return retDesc
            
        case let arrayObj where arrayObj is Array<Any>:
            
            var retDesc = "[\n"
            var tabDesc = ""
            for _ in 0..<level {
                tabDesc.append(contentsOf: "\t")
            }
            
            let arrayObj = arrayObj as! Array<Any>
            for (_, value) in arrayObj.enumerated() {
                
                if value is JGSLogDescription {
                    // Dictionary、Array、String
                    let logObj = value as! JGSLogDescription
                    if logObj is String {
                        retDesc.append("\(tabDesc)\t\"\(logObj.jg_logDescription(level: level + 1))\",\n")
                    } else {
                        retDesc.append("\(tabDesc)\t\(logObj.jg_logDescription(level: level + 1)),\n")
                    }
                }
                else if value is CustomStringConvertible {
                    // CustomStringConvertible
                    let logObj = value as! CustomStringConvertible
                    retDesc.append("\(tabDesc)\t\(logObj.description),\n")
                }
                else {
                    // Other
                    retDesc.append("\(tabDesc)\t\(value),\n")
                }
            }
            retDesc.append(contentsOf: String(format: "%@]", tabDesc))
            return retDesc
            
        case let stringObj where stringObj is String:
            
            let stringObj = stringObj as! String
            ////var tempDesc = stringObj.replacingOccurrences(of: "\\u", with: "\\U") // Unicode替换，iOS仅识别U
            //var tempDesc = stringObj
            //tempDesc = tempDesc.replacingOccurrences(of: "\"", with: "\\\"")
            //tempDesc = "\"".appending(tempDesc).appending("\"")
            var options: JSONSerialization.ReadingOptions = [.fragmentsAllowed]
            if #available(iOS 15.0, *) {
                options.insert(.json5Allowed)
            }
            let jsonStr = stringObj.trimmingCharacters(in: .whitespacesAndNewlines)
            if ["{", "["].filter({ prefix in
                jsonStr.hasPrefix(prefix)
            }).count > 0,
                let data = jsonStr.data(using: .utf8),
                let json = try? JSONSerialization.jsonObject(with: data, options: options) {
                if let dict = json as? Dictionary<AnyHashable, Any> {
                    return "(JSON -> Dictionary) " + dict.jg_logDescription()
                } else if let array = json as? Array<Any> {
                    return "(JSON -> Array) " + array.jg_logDescription()
                }
            }
            
            let retDesc = try? PropertyListSerialization.propertyList(from: stringObj.data(using: .utf8)!, options: [], format: nil) as? String
            //retDesc = retDesc.replacingOccurrences(of: "\\r\\n", with: "\n")
            return retDesc ?? stringObj
            
        default:
            return "\(self)"
        }
    }
}

// MARK: - Private Log
internal func JGSPrivateLogWithLevel(_ args: Any?..., level: JGSLogLevel = .debug, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    
    // 打印内容
    var log: String = ""
    for arg in args {
        
        // nil 拦截处理，否则后续 is 判断会出错
        // nil 判断 is 结果始终为 true
        guard let arg = arg else {
            log.append((log.count > 0 ? " " : "") + JGSLogNil2NullString)
            continue
        }
        
        // 下列 is 判断，arg 不能为 nil，否则判断结果始终为 true
        var temp = ""
        if arg is JGSLogDescription {
            // Dictionary、Array、String
            temp = (arg as! JGSLogDescription).jg_logDescription()
        } else if arg is CustomStringConvertible {
            // CustomStringConvertible
            temp = (arg as! CustomStringConvertible).description
        } else {
            // Other
            temp = "\(arg)"
        }
        
        log.append((log.count == 0 ? "": " ") + temp)
    }
    // mode
    let mode: JGSLogMode = JGSLogger.enableDebug ? (JGSLogger.mode != .none ? JGSLogger.mode : .func) : .none;
    
    return JGSLog(log, mode: mode, level: level, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

internal func JGSPrivateLog(_ args: Any?..., level: JGSLogLevel = .debug, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSPrivateLogWithLevel(args, level: level, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

internal func JGSPrivateLogD(_ args: Any?..., filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSPrivateLogWithLevel(args, level: .debug, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

internal func JGSPrivateLogI(_ args: Any?..., filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSPrivateLogWithLevel(args, level: .info, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

internal func JGSPrivateLogW(_ args: Any?..., filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSPrivateLogWithLevel(args, level: .warn, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

internal func JGSPrivateLogE(_ args: Any?..., filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSPrivateLogWithLevel(args, level: .error, filePath: filePath, funcName: funcName, lineNum: lineNum)
}
