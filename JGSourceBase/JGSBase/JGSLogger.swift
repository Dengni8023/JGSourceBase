//
//  JGSLogger.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2025/7/7.
//  Copyright © 2025 MeiJiGao. All rights reserved.
//

import Foundation

@objcMembers public
class JGSLogLevelDetailInfo: NSObject {
    /// 日志等级对应的emoji图标
    public let emoji: String
    /// 日志等级的字符串描述
    public let level: String

    /// 初始化方法
    /// - Parameters:
    ///   - emoji: 日志等级对应的emoji图标
    ///   - level: 日志等级的字符串描述
    init(emoji: String, level: String) {
        self.emoji = emoji
        self.level = level
    }
}

@objcMembers public
class JGSLogger: NSObject {
    
    /// 是否显示内部调试Log
    public static var enableDebug = false
    /// 日志输出模式，默认为 .none，表示不输出日志
    public private(set) static var mode: JGSLogMode = .none
    /// 日志输出级别，默认为 .debug，表示输出所有级别的日志
    public private(set) static var level: JGSLogLevel = .debug
    /// 是否使用系统NSLog输出日志，默认为false，即使用组件内部自定义的日志输入格式进行日志输出
    public private(set) static var useNSLog: Bool = false
    /// 日志输出内容长度限制，默认为 0，表示不限制长度
    public private(set) static var lengthLimit: Int = 0
    /// 日志输出内容最小长度限制，默认值为 0xff
    public static let lengthMin: Int = 0xff
    /// 日志内容超过长度限制时的截断方式，默认为 .middle，表示从中间截断
    public private(set) static var truncating: JGSLogTruncating = .middle
    
    /// 获取指定日志级别的详细信息，此方法专为开放给OC方法使用（即使是内部OC方法），必须使用public
    /// - Parameter level: 日志级别
    /// - Returns: 日志级别的详细信息，如果不存在则返回nil
    public static
    func logDetailInfo(_ level: JGSLogLevel) -> JGSLogLevelDetailInfo? {
        return JGSLogDetailInfo(level)
    }
    
    /// 开启JGSLogger日志打印
    /// - Parameters:
    ///   - mode: 日志打印模式，默认为 .none，表示不输出日志
    ///   - level: 日志打印级别，默认为 .debug，表示输出所有级别的日志
    ///   - useNSLog: 是否使用系统NSLog，默认为false，即使用组件内部自定义的日志输入格式进行日志输出
    ///   - lengthLimit: 日志输出内容长度限制，默认为nil，表示不限制长度
    ///   - truncating: 日志内容超过长度限制时的截断方式，默认为nil，表示从中间截断
    public static
    func enableLog(mode: JGSLogMode = .none, level: JGSLogLevel = .debug, useNSLog: Bool = false, lengthLimit: Int? = nil, truncating: JGSLogTruncating? = nil) {
        enableLog(mode: mode, level: level, useNSLog: useNSLog, lengthLimit: lengthLimit ?? 0, truncating: truncating ?? .middle)
    }
    
    /// 开启JGSLogger日志打印
    /// - Parameters:
    ///   - mode: 日志打印模式，默认为 .none，表示不输出日志
    ///   - level: 日志打印级别，默认为 .debug，表示输出所有级别的日志
    ///   - useNSLog: 是否使用系统NSLog，默认为false，即使用组件内部自定义的日志输入格式进行日志输出
    ///   - lengthLimit: 日志输出内容长度限制，默认为nil，表示不限制长度
    ///   - truncating: 日志内容超过长度限制时的截断方式，默认为nil，表示从中间截断
    public static
    func enableLog(mode: JGSLogMode = .none, level: JGSLogLevel = .debug, useNSLog: Bool = false, lengthLimit: Int, truncating: JGSLogTruncating) {
        JGSLogger.mode = mode
        JGSLogger.level = level
        JGSLogger.useNSLog = useNSLog
        JGSLogger.lengthLimit = {
            guard lengthLimit > JGSLogger.lengthMin else {
                return 0
            }
            return lengthLimit
        }()
        JGSLogger.truncating = truncating
    }
}

// MARK: - JGSLogLevel - Calculate
public extension JGSLogLevel {
    
    // 枚举类型运算、比较重载 +、-、>、>=、==、<、<=
    static func + (lhs: JGSLogLevel, rhs: Int) -> JGSLogLevel {
        return JGSLogLevel(rawValue: lhs.rawValue + rhs) ?? lhs
    }
    
    static func - (lhs: JGSLogLevel, rhs: Int) -> JGSLogLevel {
        return JGSLogLevel(rawValue: lhs.rawValue - rhs) ?? lhs
    }
    
    static func > (lhs: JGSLogLevel, rhs: JGSLogLevel) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
    
    static func >= (lhs: JGSLogLevel, rhs: JGSLogLevel) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
    
    static func == (lhs: JGSLogLevel, rhs: JGSLogLevel) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    static func < (lhs: JGSLogLevel, rhs: JGSLogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static func <= (lhs: JGSLogLevel, rhs: JGSLogLevel) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
}

// MARK: - JGSLogMode - Calculate
public extension JGSLogMode {
    
    // 枚举类型运算、比较重载 +、-、>、>=、==、<、<=
    static func + (lhs: JGSLogMode, rhs: Int) -> JGSLogMode {
        return JGSLogMode(rawValue: lhs.rawValue + rhs) ?? lhs
    }
    
    static func - (lhs: JGSLogMode, rhs: Int) -> JGSLogMode {
        return JGSLogMode(rawValue: lhs.rawValue - rhs) ?? lhs
    }
    
    static func > (lhs: JGSLogMode, rhs: JGSLogMode) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
    
    static func >= (lhs: JGSLogMode, rhs: JGSLogMode) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
    
    static func == (lhs: JGSLogMode, rhs: JGSLogMode) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    static func < (lhs: JGSLogMode, rhs: JGSLogMode) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static func <= (lhs: JGSLogMode, rhs: JGSLogMode) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
}

// MARK: - Public Log
public func JGSLog(format: String, _ args: CVarArg?..., mode: JGSLogMode? = nil, level: JGSLogLevel = .debug, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    
    var tmpArgs: [CVarArg] = []
    for arg in args {
        tmpArgs.append(arg ?? JGSLogNil2NullString)
    }
    let msg = String(format: format, arguments: tmpArgs)
    JGSLog(msg, mode: mode, level: level, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

public func JGSLog(_ args: Any?..., mode logMode: JGSLogMode? = nil, level logLv: JGSLogLevel = .debug, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    
    let mode = logMode ?? JGSLogger.mode
    
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
    if mode == .none || logLv < JGSLogger.level {
        return
    }
    
    // 日志长度、省略处理
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
    
    // 日志级别
    let lvInfo = JGSLogDetailInfo(logLv)
    let lvStr = "\(lvInfo.emoji) [\(lvInfo.level)-Swift]"
    
    // 执行输出日志方法所在文件、方法、行号
    if mode == .func || mode == .file {
        
        // Swift 中 #funcName 不包含类名，因此输出文件名
        // 对文件路径进行处理，获取文件名
        let file = (filePath as NSString).lastPathComponent
        var fileFuncLine = "[\(file) \(funcName)] Line: \(lineNum)"
        // Log长度小于最小限长是时不分行显示，否则 log 内容换行显示
        fileFuncLine.append(log.count > JGSLogger.lengthMin ? "\n" : " ")
        log = fileFuncLine.appending(log)
    }
    
    // 使用NSLog输出
    if JGSLogger.useNSLog {
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

public func JGSLogD(_ args: Any?..., mode: JGSLogMode? = nil, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSLog(args, mode: mode, level: .debug, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

public func JGSLogI(_ args: Any?..., mode: JGSLogMode? = nil, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSLog(args, mode: mode, level: .info, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

public func JGSLogW(_ args: Any?..., mode: JGSLogMode? = nil, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSLog(args, mode: mode, level: .warn, filePath: filePath, funcName: funcName, lineNum: lineNum)
}

public func JGSLogE(_ args: Any?..., mode: JGSLogMode? = nil, filePath: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSLog(args, mode: mode, level: .error, filePath: filePath, funcName: funcName, lineNum: lineNum)
}
