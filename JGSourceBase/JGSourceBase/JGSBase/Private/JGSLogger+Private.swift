//
//  JGSLogger+Private.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2025/7/7.
//  Copyright © 2025 MeiJiGao. All rights reserved.
//

import Foundation

// internal let JGSLogNil2NullString = "(null)" // 与 OC 保持一致
internal let JGSLogNil2NullString = "nil" // 与 Swift 保持一致
private let JGSLogNilString = "nil" // 与 Swift 保持一致
private let JGSDebugLogMode: JGSLogMode = .func

private var JGSLogDetailInfo: [JGSLogLevel: (emoji: String, level: String)] {
    [
        .debug: ("🛠", "Debug"),
        .info: ("ℹ️", "Info"),
        .warn: ("⚠️", "Warn"),
        .error: ("❌", "Error"),
    ]
}

// MARK: - Core Log Output
/// 统一的日志输出核心方法
internal func JGSOutputLog(_ log: String, mode: JGSLogMode, level: JGSLogLevel, file: String, funcName: String, lineNum: Int) {
    
    // 不输出日志，或者输出日志级别小于允许输出日志的级别
    // 不执行后续日志处理逻辑
    if mode == .none || level < JGSLogger.level {
        return
    }
    
    // 日志长度、省略处理
    var log = log
    let logLimit = JGSLogger.lengthLimit > 0 ? max(JGSLogger.lengthLimit, JGSLogger.lengthMin) : 0
    if logLimit > 0 && log.count > logLimit {
        switch JGSLogger.truncating {
        case .middle:
            let logHead = log.prefix(logLimit / 2)
            let logTail = log.suffix(logLimit / 2)
            log = logHead.appending("\n\n\t\t...\n\n\t\t").appending(logTail).appending(" (log count: \(log.count))")
            
        case .head:
            let logTail = log.suffix(logLimit)
            log = "...\n\n\t\t".appending(logTail).appending(" (log count: \(log.count))")
            
        case .tail:
            let logHead = log.prefix(logLimit)
            log = logHead.appending("\n\n\t\t...").appending(" (log count: \(log.count))")
            
        @unknown default:
            break
        }
    }
    
    // 执行输出日志方法所在文件、方法、行号
    if mode == .func || mode == .file {
        
        // 对文件路径进行处理，获取文件名
        let file = URL(fileURLWithPath: file).lastPathComponent
        var fileFuncLine = "[\(file) \(funcName)] Line: \(lineNum)"
        // Log长度小于最小限长时不分行显示，否则 log 内容换行显示
        fileFuncLine.append(log.count > JGSLogger.lengthMin ? "\n" : " ")
        log = fileFuncLine.appending(log)
    }
    
    let lvStr: String? = {
        if let lvInfo = JGSLogDetailInfo[level] {
            return "\(lvInfo.emoji) [\(lvInfo.level)-Swift]"
        }
        return nil
    }()
    
    // 使用NSLog输出
    if JGSLogger.useNSLog {
        // 日志级别
        if let lvStr = lvStr {
            NSLog("%@ %@", lvStr, log)
        } else {
            NSLog("%@", log)
        }
        return
    }
    
    // 时间戳相关处理，获取类似NSLog时间相关信息
    var now: timeval = timeval(tv_sec: 0, tv_usec: 0)
    gettimeofday(&now, nil)
    var seconds: Int = now.tv_sec
    let timeinfo = localtime(&seconds)
    let microseconds: Int32 = now.tv_usec
    
    // 输出日期时间 2021-03-11 20:23:39 长度为 19，最短定义为20
    var dateTime: [CChar] = [CChar](repeating: 0, count: 32)
    strftime(&dateTime, 32, "%Y-%m-%d %H:%M:%S", timeinfo)
    let dateTimeStr = String(decoding: dateTime[..<dateTime.count].map({ UInt8($0) }), as: UTF8.self)
    
    // 输出时区 +0800 长度为5，最短定义为6
    var timeZone: [CChar] = [CChar](repeating: 0, count: 8)
    strftime(&timeZone, 8, "%z", timeinfo);
    let timeZoneStr = String(decoding: timeZone[..<timeZone.count].map({ UInt8($0) }), as: UTF8.self)
    
    // 参考：https://www.cnblogs.com/itmarsung/p/14901052.html
    // 格式化时间字符串
    let formattedDateTimeStr = dateTimeStr + "." + String(format: "%.6d", microseconds) + timeZoneStr
    // 运行进程信息，NSLog使用私有方法GSPrivateThreadID()获取threadID，此处无法获取，仅使用pid
    let processInfo = ProcessInfo.processInfo.processName + "[\(getpid())]"
    
    // Log格式参考：https://www.cnblogs.com/itmarsung/p/14901052.html
    if let lvStr = lvStr {
        print(formattedDateTimeStr, processInfo, lvStr, log)
    } else {
        print(formattedDateTimeStr, processInfo, log)
    }
}

/**
 * 可变参数多层传递导致变成 Array 问题，因此
 * 每个可变参数方法，直接调用 JGSLog 而不是将可变参数逐层往下最终传递给 JGSLog
 */

// MARK: - Debug Log
internal func JGSDebugLogD(format: String? = nil, _ args: Any?..., file: String = #file, funcName: String = #function, lineNum: Int = #line) {
    // 调试日志未开启，则不执行后续逻辑
    guard JGSLogger.enableDebug else { return }
    
    // 调用 JGSLogMessage 生成打印日志内容
    // 注意可变参数多层传递导致变成 Array 问题，外部可变参数传递路径不要超过*层
    let msg = JGSLogMessage(format: format, args)
    return JGSDebugLog(msg, level: .debug, file: file, funcName: funcName, lineNum: lineNum)
}

internal func JGSDebugLogI(format: String? = nil, _ args: Any?..., file: String = #file, funcName: String = #function, lineNum: Int = #line) {
    // 调试日志未开启，则不执行后续逻辑
    guard JGSLogger.enableDebug else { return }
    
    // 调用 JGSLogMessage 生成打印日志内容
    // 注意可变参数多层传递导致变成 Array 问题，外部可变参数传递路径不要超过*层
    let msg = JGSLogMessage(format: format, args)
    return JGSDebugLog(msg, level: .info, file: file, funcName: funcName, lineNum: lineNum)
}

internal func JGSDebugLogW(format: String? = nil, _ args: Any?..., file: String = #file, funcName: String = #function, lineNum: Int = #line) {
    // 调试日志未开启，则不执行后续逻辑
    guard JGSLogger.enableDebug else { return }
    
    // 调用 JGSLogMessage 生成打印日志内容
    // 注意可变参数多层传递导致变成 Array 问题，外部可变参数传递路径不要超过*层
    let msg = JGSLogMessage(format: format, args)
    return JGSDebugLog(msg, level: .warn, file: file, funcName: funcName, lineNum: lineNum)
}

internal func JGSDebugLogE(format: String? = nil, _ args: Any?..., file: String = #file, funcName: String = #function, lineNum: Int = #line) {
    // 调试日志未开启，则不执行后续逻辑
    guard JGSLogger.enableDebug else { return }
    
    // 调用 JGSLogMessage 生成打印日志内容
    // 注意可变参数多层传递导致变成 Array 问题，外部可变参数传递路径不要超过*层
    let msg = JGSLogMessage(format: format, args)
    return JGSDebugLog(msg, level: .error, file: file, funcName: funcName, lineNum: lineNum)
}

internal func JGSDebugLog(format: String? = nil, _ args: Any?..., level: JGSLogLevel = .debug, file: String = #file, funcName: String = #function, lineNum: Int = #line) {
    // 调试日志未开启，则不执行后续逻辑
    guard JGSLogger.enableDebug else { return }
    
    // 调用 JGSLogMessage 生成打印日志内容
    // 注意可变参数多层传递导致变成 Array 问题，外部可变参数传递路径不要超过*层
    let msg = JGSLogMessage(format: format, args)
    return JGSLog(msg, mode: JGSDebugLogMode, level: level, file: file, funcName: funcName, lineNum: lineNum)
}

// MARK: - 自定义 Description
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
        // 优先级最高：处理标准 JSON 对象（Dictionary 或 Array）
        // 通过 JSONSerialization 序列化，确保输出格式统一、可读性强
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
            
        // 处理 Dictionary 类型，手动构建格式化输出
        // 支持嵌套结构的递归处理，根据 level 参数控制缩进层级
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
            
        // 处理 Array 类型，手动构建格式化输出
        // 支持嵌套结构的递归处理，根据 level 参数控制缩进层级
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
            
        // 处理 String 类型，尝试解析为 JSON 字符串
        // 如果字符串是有效的 JSON，递归调用 jg_logDescription 处理解析后的对象
        // 否则尝试通过 PropertyListSerialization 解析，最后回退到原始字符串
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
                    return "(JSON -> Dictionary) \(dict.jg_logDescription())"
                } else if let array = json as? Array<Any> {
                    return "(JSON -> Array) \(array.jg_logDescription())"
                } else {
                    return "(JSON -> Fragments) \(json)"
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
