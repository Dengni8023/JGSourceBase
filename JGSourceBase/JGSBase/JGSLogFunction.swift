//
//  JGSLogFunction.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2022/12/8.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

import Foundation

//fileprivate let JGSLogNil2NullString = "(null)" // 与 OC 保持一致
fileprivate let JGSLogNil2NullString = "nil" // 与 Swift 保持一致
public func JGSLog(format: String, _ args: CVarArg?..., mode: JGSLogMode? = JGSEnableLogMode, level: JGSLogLevel? = JGSConsoleLogLevel, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    
    var tmpArgs: [CVarArg] = []
    for arg in args {
        tmpArgs.append(arg ?? JGSLogNil2NullString)
    }
    let msg = String(format: format, arguments: tmpArgs)
    JGSLog(msg, mode: mode, level: level, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

public func JGSLog(_ args: Any?..., mode logMode: JGSLogMode? = JGSEnableLogMode, level logLv: JGSLogLevel? = JGSConsoleLogLevel, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    
    let level = logLv ?? JGSConsoleLogLevel
    let mode = logMode ?? JGSEnableLogMode
    
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
    
    // 判断log开关及log日志级别设置
    if mode == .none || level < JGSConsoleLogLevel {
        return
    }
    
    // 日志长度、省略处理
    let logLimit = max(JGSConsoleLogLengthLimit, JGSConsoleLogLengthMinLimit)
    if log.count > logLimit {
        switch JGSConsoleLogTruncating {
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
    
    // 日志级别
    let lvMap = JGSLogLevelMap()[NSNumber(value: level.rawValue)] as! [String: String]
    let lvStr = "\(lvMap["emoji"]!) [\(lvMap["level"]!)-Swift]"
    
    // 执行输出日志方法所在文件、方法、行号
    if mode == .func || mode == .file {
        
        // Swift 中 #funcName 不包含类名，因此输出文件名
        // 对文件路径进行处理，获取文件名
        let file = (filePath as NSString).lastPathComponent
        var fileFuncLine = "[\(file) \(funcName)] Line: \(lineNum)"
        // Log长度小于最小限长是时不分行显示，否则 log 内容换行显示
        fileFuncLine.append(log.count > JGSConsoleLogLengthMinLimit ? "\n" : " ")
        log = fileFuncLine.appending(log)
    }
    
    // 使用NSLog输出
    if JGSConsoleWithNSLog.boolValue {
        NSLog("%@ %@", lvStr, log);
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
    
    // 输出时区 +0800 长度为5，最短定义为6
    var timeZone: [CChar] = [CChar](repeating: 0, count: 8)
    strftime(&timeZone, 8, "%z", timeinfo);
    
    // 参考：https://www.cnblogs.com/itmarsung/p/14901052.html
    // 格式化时间字符串
    let formatedDateTimeStr = String(cString: dateTime) + "." + String(format: "%.6d", microseconds) + String(cString: timeZone)
    // 运行进程信息，NSLog使用私有方法GSPrivateThreadID()获取threadID，此处无法获取，仅使用pid
    let prcessInfo = ProcessInfo.processInfo.processName + "[\(getpid())]"
    
    // Log格式参考：https://www.cnblogs.com/itmarsung/p/14901052.html
    print(
        formatedDateTimeStr, // 格式化时间字符串
        prcessInfo, // 运行进程相关
        lvStr, // 日志级别相关
        log // 日志文件、方法、行号、内容
    )
}

public func JGSLogD(_ args: Any?..., mode: JGSLogMode? = JGSEnableLogMode, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSLog(args, mode: mode, level: .debug, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

public func JGSLogI(_ args: Any?..., mode: JGSLogMode? = JGSEnableLogMode, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSLog(args, mode: mode, level: .info, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

public func JGSLogW(_ args: Any?..., mode: JGSLogMode? = JGSEnableLogMode, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSLog(args, mode: mode, level: .warn, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

public func JGSLogE(_ args: Any?..., mode: JGSLogMode? = JGSEnableLogMode, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSLog(args, mode: mode, level: .error, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

// MARK: - 重写 description
fileprivate protocol JGSLogDescription {
    
    /// 日志输出描述，类似
    /// 1. CustomStringConvertible 协议 description 方法
    /// 2. OC 重写 description 方法
    /// - Returns: 日志输出内容
    //var jg_logDescription: String { get }
    func jg_logDescription(level: Int64) -> String
}

extension Dictionary : JGSLogDescription { }
extension Array: JGSLogDescription { }
extension String: JGSLogDescription { }
fileprivate extension JGSLogDescription {
    
    func jg_logDescription(level: Int64 = 0) -> String {
        switch self {
        case let validJsonObj where JSONSerialization.isValidJSONObject(validJsonObj):

            // key升序整理、格式化输出、禁用正斜杠"/"前增加反斜杠"\"转译
            var retDesc = ""
            if #available(iOS 13.0, *) {
                if let data = try? JSONSerialization.data(withJSONObject: validJsonObj, options: [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]) {
                    retDesc = String(data: data, encoding: .utf8) ?? "JGSLog JSONSerialization error"
                }
            } else {
                if let data = try? JSONSerialization.data(withJSONObject: validJsonObj, options: [.sortedKeys, .prettyPrinted]) {
                    retDesc = String(data: data, encoding: .utf8) ?? "JGSLog JSONSerialization error"
                    retDesc = retDesc.replacingOccurrences(of: "\\/", with: "/")
                }
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
            if let data = stringObj.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data) {
                if let dict = json as? Dictionary<AnyHashable, Any> {
                    return "(JSON -> Dictionary) " + dict.jg_logDescription()
                } else if let array = json as? Array<Any> {
                    return "(JSON -> Array) " + array.jg_logDescription()
                }
            }
            
            var retDesc: String = ""
            do {
                retDesc = try PropertyListSerialization.propertyList(from: stringObj.data(using: .utf8)!, options: [], format: nil) as! String
                //retDesc = try PropertyListSerialization.propertyList(from: tempDesc.data(using: .utf8)!, options: [], format: nil) as! String
            } catch {
                retDesc = stringObj
            }
            //retDesc = retDesc.replacingOccurrences(of: "\\r\\n", with: "\n")
            return retDesc
            
        default:
            return "\(self)"
        }
    }
}

// MARK: JGSLogLevel - Calculate
extension JGSLogLevel {
    
    // 枚举类型运算、比较重载 +、-、>、>=、==、<、<=
    static public func + (lhs: JGSLogLevel, rhs: Int) -> JGSLogLevel? {
        return JGSLogLevel(rawValue: lhs.rawValue + rhs)
    }
    
    static internal func - (lhs: JGSLogLevel, rhs: Int) -> JGSLogLevel? {
        return JGSLogLevel(rawValue: lhs.rawValue - rhs)
    }
    
    static internal func > (lhs: JGSLogLevel, rhs: JGSLogLevel) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
    
    static internal func > (lhs: JGSLogLevel, rhs: Int) -> Bool {
        return lhs.rawValue > rhs
    }
    
    static internal func >= (lhs: JGSLogLevel, rhs: JGSLogLevel) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
    
    static internal func >= (lhs: JGSLogLevel, rhs: Int) -> Bool {
        return lhs.rawValue >= rhs
    }
    
    static internal func == (lhs: JGSLogLevel, rhs: JGSLogLevel) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    static internal func == (lhs: JGSLogLevel, rhs: Int) -> Bool {
        return lhs.rawValue == rhs
    }
    
    static internal func < (lhs: JGSLogLevel, rhs: JGSLogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static internal func < (lhs: JGSLogLevel, rhs: Int) -> Bool {
        return lhs.rawValue < rhs
    }
    
    static internal func <= (lhs: JGSLogLevel, rhs: JGSLogLevel) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
    
    static internal func <= (lhs: JGSLogLevel, rhs: Int) -> Bool {
        return lhs.rawValue <= rhs
    }
}

// MARK: JGSLogMode - Calculate
extension JGSLogMode {
    
    // 枚举类型运算、比较重载 +、-、>、>=、==、<、<=
    static internal func + (lhs: JGSLogMode, rhs: Int) -> JGSLogMode? {
        return JGSLogMode(rawValue: lhs.rawValue + rhs)
    }
    
    static internal func - (lhs: JGSLogMode, rhs: Int) -> JGSLogMode? {
        return JGSLogMode(rawValue: lhs.rawValue - rhs)
    }
    
    static internal func > (lhs: JGSLogMode, rhs: JGSLogMode) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
    
    static internal func > (lhs: JGSLogMode, rhs: Int) -> Bool {
        return lhs.rawValue > rhs
    }
    
    static internal func >= (lhs: JGSLogMode, rhs: JGSLogMode) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
    
    static internal func >= (lhs: JGSLogMode, rhs: Int) -> Bool {
        return lhs.rawValue >= rhs
    }
    
    static internal func == (lhs: JGSLogMode, rhs: JGSLogMode) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    static internal func == (lhs: JGSLogMode, rhs: Int) -> Bool {
        return lhs.rawValue == rhs
    }
    
    static internal func < (lhs: JGSLogMode, rhs: JGSLogMode) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static internal func < (lhs: JGSLogMode, rhs: Int) -> Bool {
        return lhs.rawValue < rhs
    }
    
    static internal func <= (lhs: JGSLogMode, rhs: JGSLogMode) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
    
    static internal func <= (lhs: JGSLogMode, rhs: Int) -> Bool {
        return lhs.rawValue <= rhs
    }
}

// MARK: - Private
internal func JGSPrivateLogWithLevel(_ args: Any?..., level: JGSLogLevel? = JGSConsoleLogLevel, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    let mode: JGSLogMode = JGSLogFunction.isLogEnabled() ? (JGSEnableLogMode != .none ? JGSEnableLogMode : .func) : .none;
    JGSLog(args, mode: mode, level: level, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

internal func JGSPrivateLog(_ args: Any?..., level: JGSLogLevel? = JGSConsoleLogLevel, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
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
