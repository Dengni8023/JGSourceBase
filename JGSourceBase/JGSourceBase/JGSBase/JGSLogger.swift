//
//  JGSLogger.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2025/7/7.
//  Copyright © 2025 MeiJiGao. All rights reserved.
//

import Foundation

// MARK: - 日志相关枚举定义
/// 日志打印模式
@objc public
enum JGSLogMode: Int, Sendable {
    case none = 0 // 不打印日志
    case log // 仅打印日志内容
    case `func` // 打印日志所在方法名、行号、日志内容；func、file在Swift日志表现一致，OC两者存在差别
    case file // 打印文件名、方法名、行号、日志内容，各部分分行显示；func、file在Swift日志表现一致，OC两者存在差别
    
    // 保留旧的命名，并标记为废弃，提供迁移提示
    @available(*, deprecated, renamed: "file")
    public static var pretty: JGSLogMode { .file }
}

/// 日志省略方式
@objc public
enum JGSLogTruncating: Int, Sendable {
    case middle // 中间省略:  "ab...yz"
    case head // 头部省略: "...wxyz"
    case tail // 尾部省略: "abcd..."
}

/// 日志打印级别，低于该级别日志不打印
@objc public
enum JGSLogLevel: Int, Sendable {
    // 此类级别表明我们当前正在临时打印一些log为了去调试程序, 或者说我们为了观察某个现象但是需要频繁打印, 比如相机回调中打印时间戳, 因为相机每秒钟出来几十帧数据, 所以打印十分频繁, 我们可以使用此级别在开发中作为调试信息, 一般不建议在正常使用中开启此级别
    case debug = 0 // 调试级别
    // 此类级别一般用于打印模块中一些重要的点, 比如我们可以在某个类初始化完成时打印此类中初始化好的一些重要信息, 或者在使用某个功能前做一个打印, 这样对于追踪代码十分有效
    case info // 重要信息级别
    // 此类错误一般较低于error级别,即在一些可能出错的地方, 但实际并没有出错, 比如当视频帧数量小于0表示出错情况, 我们为了预防, 可以在视频帧数量小于5时使用此类添加一条预防的Log
    case warn // 警告级别
    // 此类打印可用于出现一般错误,比如某个方法调用返回失败, 因为一般而言代码预期是正确的, 所以此类Log不会打印的太频繁, 打开此级别后我们可以清晰看到程序哪些地方出现问题
    case error // 出错级别
}

// MARK: - JGSLogger
@objcMembers public final
class JGSLogger: NSObject, @unchecked Sendable {
    
    private static let shared = {
        let ins = JGSLogger()
        return ins
    }()
    
    override public init() {
        super.init()

        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            objc_sync_enter(self)
            defer {
                objc_sync_exit(self)
            }
            #if os(iOS) || os(watchOS) || os(tvOS)
            useNSLog = UIDevice.current.systemVersion < "15.0"
            #else
            useNSLog = false
            #endif
        }
    }
    
    /// 是否显示内部调试Log
    private var enableDebug = false
    public static var enableDebug: Bool {
        get { shared.enableDebug }
        set { shared.enableDebug = newValue }
    }
    
    /// 日志输出模式，默认为 .none，表示不输出日志
    private var mode: JGSLogMode = .none
    public private(set) static var mode: JGSLogMode {
        get { shared.mode }
        set { shared.mode = newValue }
    }
    
    /// 日志输出级别，默认为 .debug，表示输出所有级别的日志
    private var level: JGSLogLevel = .debug
    public private(set) static var level: JGSLogLevel {
        get { shared.level }
        set { shared.level = newValue }
    }
    
    /// 是否使用系统NSLog输出日志，为 false 则使用自定义的日志输出格式，低于iOS 15默认true，iOS 15及以上默认为 false
    /// 在低版本系统上print日志不如NSLog稳定，建议以iOS15进行区分
    private var useNSLog = false
    public private(set) static var useNSLog: Bool {
        get { shared.useNSLog }
        set { shared.useNSLog = newValue }
    }
    
    /// 日志输出内容长度限制，默认为 0，表示不限制长度
    private var lengthLimit: Int = 0
    public private(set) static var lengthLimit: Int {
        get { shared.lengthLimit }
        set { shared.lengthLimit = newValue }
    }
    
    /// 日志输出内容最小长度限制，默认值为 0xff
    public let lengthMin: Int = 0xFF
    public static let lengthMin: Int = shared.lengthMin
    
    /// 日志内容超过长度限制时的截断方式，默认为 .middle，表示从中间截断
    private var truncating: JGSLogTruncating = .middle
    public private(set) static var truncating: JGSLogTruncating {
        get { shared.truncating }
        set { shared.truncating = newValue }
    }
    
    /// 开启JGSLogger日志打印，精简参数便于OC调用
    /// - Parameters:
    ///   - mode: 日志打印模式，默认为 .none，表示不输出日志
    public static
    func enableLog(mode: JGSLogMode) {
        enableLog(mode: mode, level: JGSLogger.level, useNSLog: JGSLogger.useNSLog, lengthLimit: JGSLogger.lengthLimit, truncating: JGSLogger.truncating)
    }
    
    /// 开启JGSLogger日志打印，精简参数便于OC调用
    /// - Parameters:
    ///   - mode: 日志打印模式，默认为 .none，表示不输出日志
    ///   - level: 日志打印级别，默认为 .debug，表示输出所有级别的日志
    ///   - useNSLog: 是否使用系统NSLog，为 false 则使用自定义的日志输出格式，低于iOS 15默认true，iOS 15及以上默认为 false
    public static
    func enableLog(mode: JGSLogMode = JGSLogger.mode, level: JGSLogLevel = JGSLogger.level, useNSLog: Bool = JGSLogger.useNSLog) {
        enableLog(mode: mode, level: level, useNSLog: useNSLog, lengthLimit: JGSLogger.lengthLimit, truncating: JGSLogger.truncating)
    }
    
    /// 开启JGSLogger日志打印
    /// - Parameters:
    ///   - mode: 日志打印模式，默认为 .none，表示不输出日志
    ///   - level: 日志打印级别，默认为 .debug，表示输出所有级别的日志
    ///   - useNSLog: 是否使用系统NSLog，为 false 则使用自定义的日志输出格式，低于iOS 15默认true，iOS 15及以上默认为 false
    ///   - lengthLimit: 日志输出内容长度限制，默认为 0，表示不限制长度
    ///   - truncating: 日志内容超过长度限制时的截断方式，默认为 .middle，表示从中间截断
    public static
    func enableLog(mode: JGSLogMode = JGSLogger.mode, level: JGSLogLevel = JGSLogger.level, useNSLog: Bool = JGSLogger.useNSLog, lengthLimit: Int = JGSLogger.lengthLimit, truncating: JGSLogTruncating = JGSLogger.truncating) {
        
        shared.mode = mode
        shared.level = level
        shared.useNSLog = useNSLog
        shared.lengthLimit = {
            guard lengthLimit > shared.lengthMin else {
                return 0
            }
            return lengthLimit
        }()
        shared.truncating = truncating
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

/// 打印日志，注意参数方法中不要使用修改变量的表达式，避免打印、不打印日志时外部获取的参数值不一样
/// - Parameters:
    ///   - format: 格式化控制字符串
    ///   - args: 参数
    ///   - mode: 日志打印模式
    ///   - level: 日志级别
    ///   - file: 文件路径
    ///   - funcName: 方法名
    ///   - lineNum: 代码行
    public func JGSLog(format: String? =  nil, _ args: Any?..., mode: JGSLogMode = JGSLogger.mode, level: JGSLogLevel = .debug, file: String = #file, funcName: String = #function, lineNum : Int = #line) {
    
    // 不输出日志，或者输出日志级别小于允许输出日志的级别
    // 不执行后续日志处理逻辑
    if (mode == .none || level < JGSLogger.level) {
        return
    }
    // 调用 JGSLogMessage 生成打印日志内容
    // 注意可变参数多层传递导致变成 Array 问题，外部可变参数传递路径不要超过*层
    let msg = JGSLogMessage(format: format, args)
    JGSOutputLog(msg, mode: mode, level: level, file: file, funcName: funcName, lineNum: lineNum)
}

/// 打印[Debug]日志，注意参数方法中不要使用修改变量的表达式，避免打印、不打印日志时外部获取的参数值不一样
/// - Parameters:
    ///   - args: 参数
    ///   - mode: 日志打印模式
    ///   - file: 文件路径
    ///   - funcName: 方法名
    ///   - lineNum: 代码行
    public func JGSLogD(_ args: Any?..., mode: JGSLogMode = JGSLogger.mode, file: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSLog(format: nil, args, mode: mode, level: .debug, file: file, funcName: funcName, lineNum: lineNum)
}

/// 打印[Info]日志，注意参数方法中不要使用修改变量的表达式，避免打印、不打印日志时外部获取的参数值不一样
/// - Parameters:
    ///   - args: 参数
    ///   - mode: 日志打印模式
    ///   - file: 文件路径
    ///   - funcName: 方法名
    ///   - lineNum: 代码行
    public func JGSLogI(_ args: Any?..., mode: JGSLogMode = JGSLogger.mode, file: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSLog(format: nil, args, mode: mode, level: .info, file: file, funcName: funcName, lineNum: lineNum)
}

/// 打印[Warn]日志，注意参数方法中不要使用修改变量的表达式，避免打印、不打印日志时外部获取的参数值不一样
/// - Parameters:
    ///   - args: 参数
    ///   - mode: 日志打印模式
    ///   - file: 文件路径
    ///   - funcName: 方法名
    ///   - lineNum: 代码行
    public func JGSLogW(_ args: Any?..., mode: JGSLogMode = JGSLogger.mode, file: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSLog(format: nil, args, mode: mode, level: .warn, file: file, funcName: funcName, lineNum: lineNum)
}

/// 打印[Error]日志，注意参数方法中不要使用修改变量的表达式，避免打印、不打印日志时外部获取的参数值不一样
/// - Parameters:
    ///   - args: 参数
    ///   - mode: 日志打印模式
    ///   - file: 文件路径
    ///   - funcName: 方法名
    ///   - lineNum: 代码行
    public func JGSLogE(_ args: Any?..., mode: JGSLogMode = JGSLogger.mode, file: String = #file, funcName: String = #function, lineNum : Int = #line) {
    return JGSLog(format: nil, args, mode: mode, level: .error, file: file, funcName: funcName, lineNum: lineNum)
}

/// 日志内容构建函数，负责将参数转换为可输出的日志字符串
/// - Parameters:
///   - format: 格式化控制字符串，类似 printf 的格式字符串
///   - args: 可变参数列表，可以是任意类型
/// - Returns: 构建完成的日志字符串
/// 
/// 处理逻辑：
/// 1. 如果提供了 format 参数，则尝试使用 String(format:arguments:) 进行格式化
///    - 需要确保所有参数都符合 CVarArg 协议，否则回退到普通拼接方式
/// 2. 如果没有 format 或格式化失败，则按类型处理每个参数：
///    - nil 值：转换为 "(null)" 字符串
///    - JGSLogDescription 协议类型（Dictionary、Array、String）：调用 jg_logDescription() 方法
///    - CustomStringConvertible 协议类型：调用 description 属性
///    - 其他类型：使用字符串插值转换
public func JGSLogMessage(format: String? = nil, _ args: Any?...) -> String {
    
    // format需要可变参数均为 any CVarArg
    // 筛选可变参数类型是否为 any CVarArg
    if let format = format,
       let anyCVarArg = args.map({ $0 ?? JGSLogNil2NullString }).filter({
           $0 is CVarArg
       }) as? [any CVarArg] {
        // 只有当所有参数都符合 CVarArg 协议时才进行格式化输出
        // 否则可能导致格式化失败或崩溃
        if args.count == anyCVarArg.count {
            return String(format: format, arguments: anyCVarArg)
        } else {
            JGSDebugLogE("Format doesn't match argument list")
        }
    }
    
    // 普通拼接模式：按类型逐一处理参数
    let fields = args.map({ arg in

        // nil 拦截处理：Swift 中 nil 进行 is 判断时结果始终为 true
        // 必须先将 nil 转换为占位字符串，否则后续类型判断会出错
        guard let arg = arg else {
            return JGSLogNil2NullString
        }

        // 根据参数类型选择合适的描述方式
        let field = {
            if arg is JGSLogDescription {
                // Dictionary、Array、String 类型使用自定义的日志描述方法
                return (arg as! JGSLogDescription).jg_logDescription()
            } else if arg is CustomStringConvertible {
                // 其他实现了 CustomStringConvertible 协议的类型
                return (arg as! CustomStringConvertible).description
            } else {
                // 默认使用字符串插值
                return "\(arg)"
            }
        }()
        return field
    })
    return fields.joined(separator: " ")
}

@available(*, deprecated, renamed: "JGSLogger", message: "Replaced by JGSLogger")
@objc public final
class JGSLogFunction: NSObject {
    
    /// 是否开启内部调试日志
    @objc public static
    func enableLog(_ enable: Bool) {
        JGSLogger.enableDebug = enable
    }
    
    @objc public static
    var isLogEnabled: Bool {
        return JGSLogger.enableDebug
    }
}
