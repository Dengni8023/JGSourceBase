//
//  JGSBase.swift
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/25.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import Foundation

/// 字符串大小写风格枚举
@objc public
enum JGSStringCaseStyle: Int {
    case lower = 0 // 字母小写，默认风格
    case upper // 字母大写风格
    case random // 随机，字符串中随机存在大小写
}

/// HASH散列算法类型
@objc public
enum JGSHASHStringType: Int {
    @available(*, deprecated, message: "Weak hashing algorithm, it is recommended to use CC_SHA256 algorithm for data hashing operation")
    case md5 = 0 // md5
    @available(*, deprecated, message: "Weak hashing algorithm, it is recommended to use CC_SHA256 algorithm for data hashing operation")
    case sha128 // SHA128
    case sha256 // SHA256
    case sha384 // SHA384
    case sha512 // SHA512
}

/// 定义一个不暴露的泛型基类
/// 由于 Objective-C 无法理解 Swift 的泛型，这个类及其子类对 Objective-C 不可见
/// - Parameter T: 泛型类型参数
open class JGSSwiftClass<T> {}

// MARK: - Reuse

/// 通用重用标识协议，为 UITableViewCell、UITableViewHeaderFooterView、UICollectionReusableView 等组件提供统一的重用标识
/// 
/// 协议默认实现使用 `NSStringFromClass(Self.self)` 生成重用标识，
/// 确保每个类的重用标识唯一且与类名一致，便于维护和调试
protocol JGReuseProtocol: NSObjectProtocol {
    /// 获取当前类的重用标识
    static var jg_reuseIdentifier: String { get }
}

extension JGReuseProtocol {
    public static var jg_reuseIdentifier: String {
        return NSStringFromClass(Self.self)
    }
}

extension UITableViewCell: JGReuseProtocol {}
extension UITableViewHeaderFooterView: JGReuseProtocol {}

extension UICollectionReusableView: JGReuseProtocol {}

// MARK: - 设备相关宏定义

/// 判断是否为iPad设备
@MainActor public let JGSIsPadDevice = UIDevice.current.model.contains("iPad")

/// 判断是否为iPad界面
@MainActor public let JGSIsPadUI = UIDevice.current.userInterfaceIdiom == .pad

/// 获取设备的分辨率倍数
@MainActor private let JGSDeviceScale = {
    let scene = UIApplication.shared.connectedScenes.first { scene in
        scene is UIWindowScene
    } as? UIWindowScene
    return scene?.screen.scale ?? UIScreen.main.scale
}()

/// 计算最小显示点单位
@MainActor public let JGSMinimumPoint = 1.0 / JGSDeviceScale
