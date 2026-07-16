//
//  UIAlertController+JGSBase.swift
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/21.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import UIKit

@MainActor private var jg_showingAlertControllers = NSPointerArray(options: .weakMemory)
extension UIAlertController {
    
    /// 取消按钮索引，用于 action 回调中标识点击的是取消按钮
    /// 默认值为 0
    @objc public
    var jg_cancelIdx: Int { return 0 }
    /// 红色警告按钮索引，用于 action 回调中标识点击的是警告按钮
    /// 默认值为 1
    @objc public
    var jg_destructiveIdx: Int { return 1 }
    /// 其他按钮首个按钮索引，用于 action 回调中标识点击的是其他按钮
    /// 默认值为 2，后续其他按钮依次递增
    @objc public
    var jg_firstOtherIdx: Int { return 2 }
    
    /// ⚠️注意：多场景可能无法达到预期效果
    /// 显示系统 alert 弹窗，内部自动获取应用当前 key window 进行展示
    /// - Parameters:
    ///   - title: 弹窗标题，默认 nil
    ///   - message: 弹窗提示内容，默认 nil
    ///   - cancel: 取消按钮标题，默认 nil（不传则不显示取消按钮）
    ///   - destructive: 红色警告按钮标题，默认 nil（不传则不显示警告按钮）
    ///   - others: 其他按钮标题数组，默认空数组（不传则不显示其他按钮）
    ///   - action: 按钮点击回调，idx 参数对应按钮索引：cancel 为 jg_cancelIdx(0)，destructive 为 jg_destructiveIdx(1)，others 从 jg_firstOtherIdx(2) 开始递增
    /// - Returns: 创建的 UIAlertController 实例
    @discardableResult @objc public static
    func jg_alert(title: String? = nil, message: String? = nil, cancel: String? = nil, destructive: String? = nil, others: [String] = [], action: ((_ alert: UIAlertController, _ idx: Int) -> Void)? = nil) -> UIAlertController {
        jg_showAlert(title: title, message: message, style: .alert, cancel: cancel, destructive: destructive, others: others, action: action)
    }
    
    /// ⚠️注意：多场景可能无法达到预期效果
    /// 显示系统 actionSheet 弹窗，内部自动获取应用当前 key window 进行展示
    /// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
    /// - Parameters:
    ///   - title: 弹窗标题，默认 nil
    ///   - message: 弹窗提示内容，默认 nil
    ///   - cancel: 取消按钮标题，默认 nil（不传则不显示取消按钮）
    ///   - destructive: 红色警告按钮标题，默认 nil（不传则不显示警告按钮）
    ///   - others: 其他按钮标题数组，默认空数组（不传则不显示其他按钮）
    ///   - action: 按钮点击回调，idx 参数对应按钮索引：cancel 为 jg_cancelIdx(0)，destructive 为 jg_destructiveIdx(1)，others 从 jg_firstOtherIdx(2) 开始递增
    /// - Returns: 创建的 UIAlertController 实例
    @discardableResult @objc public static
    func jg_actionSheet(title: String? = nil, message: String? = nil, cancel: String? = nil, destructive: String? = nil, others: [String] = [], action: ((_ alert: UIAlertController, _ idx: Int) -> Void)? = nil) -> UIAlertController {
        jg_showAlert(title: title, message: message, style: .actionSheet, cancel: cancel, destructive: destructive, others: others, action: action)
    }
    
    /// ⚠️注意：多场景可能无法达到预期效果
    /// 显示系统 alert / actionSheet 弹窗，内部自动获取应用当前 key window 进行展示
    /// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
    /// - Parameters:
    ///   - title: 弹窗标题，默认 nil
    ///   - message: 弹窗提示内容，默认 nil
    ///   - style: 弹窗风格，.alert 或 .actionSheet，默认 .alert
    ///   - cancel: 取消按钮标题，默认 nil（不传则不显示取消按钮）
    ///   - destructive: 红色警告按钮标题，默认 nil（不传则不显示警告按钮）
    ///   - others: 其他按钮标题数组，默认空数组（不传则不显示其他按钮）
    ///   - action: 按钮点击回调，idx 参数对应按钮索引：cancel 为 jg_cancelIdx(0)，destructive 为 jg_destructiveIdx(1)，others 从 jg_firstOtherIdx(2) 开始递增
    /// - Returns: 创建的 UIAlertController 实例
    @discardableResult @objc public static
    func jg_showAlert(title: String? = nil, message: String? = nil, style: UIAlertController.Style = .alert, cancel: String? = nil, destructive: String? = nil, others: [String] = [], action: ((_ alert: UIAlertController, _ idx: Int) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, style: style, cancel: cancel, destructive: destructive, others: others, action: action)
        
        // 展示
        alert.jg_show()
        
        return alert
    }
    
    /// 系统 alert / actionSheet 弹窗便捷初始化
    /// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
    /// - Warning: 标题、内容、按钮至少有一项，否则会触发 fatalError
    /// - Parameters:
    ///   - title: 弹窗标题，默认 nil
    ///   - message: 弹窗提示内容，默认 nil
    ///   - style: 弹窗风格，.alert 或 .actionSheet，默认 .alert
    ///   - cancel: 取消按钮标题，默认 nil（不传则不显示取消按钮）
    ///   - destructive: 红色警告按钮标题，默认 nil（不传则不显示警告按钮）
    ///   - others: 其他按钮标题数组，默认空数组（不传则不显示其他按钮）
    ///   - action: 按钮点击回调，idx 参数对应按钮索引：cancel 为 jg_cancelIdx(0)，destructive 为 jg_destructiveIdx(1)，others 从 jg_firstOtherIdx(2) 开始递增
    internal convenience init(title: String? = nil, message: String? = nil, style: UIAlertController.Style = .alert, cancel: String? = nil, destructive: String? = nil, others: [String] = [], action: ((_ alert: UIAlertController, _ idx: Int) -> Void)? = nil) {
        // 参数检查，标题/内容/按钮 必须有一项以供展示
        if title == nil && message == nil && cancel == nil && destructive == nil && others.count == 0 {
            let msg = "UIAlertController must have a title, a message or an action to display"
            JGSDebugLog(msg)
            fatalError(msg)
        }
        
        self.init(title: title, message: message, preferredStyle: style)
        
        // 取消、警告按钮添加先后顺序不影响展示：
        // 两个按钮时，取消在左、警告在右；
        // 多按钮时，警告在顶、取消在底
        if let cancel = cancel {
            let alertAct = UIAlertAction(title: cancel, style: .cancel) { [weak self] act in
                guard let `self` = self else { return }
                action?(self, self.jg_cancelIdx)
                self.updateWindowStatus()
            }
            addAction(alertAct)
        }
        
        if let destructive = destructive {
            let alertAct = UIAlertAction(title: destructive, style: .destructive) { [weak self] act in
                guard let `self` = self else { return }
                action?(self, self.jg_destructiveIdx)
                self.updateWindowStatus()
            }
            addAction(alertAct)
        }
        
        for idx in 0 ..< others.count {
            let alertAct = UIAlertAction(title: others[idx], style: .default) { [weak self] act in
                guard let `self` = self else { return }
                action?(self, self.jg_firstOtherIdx + idx)
                self.updateWindowStatus()
            }
            addAction(alertAct)
        }
    }
}

extension UIAlertController {
    
    @MainActor struct JGSAssociatedKey {
        static var jg_alertWindowKey: UInt8 = 0
    }
    
    /// 全局弹窗容器 window，使用关联对象存储在 UIApplication 实例上
    /// 采用这种方式是为了保证弹窗 window 的生命周期与应用一致，避免被提前释放
    /// 同时确保在弹窗关闭设置 window 为不可见时不会影响 APP 正常交互
    private var jg_appAlertWindow: UIWindow? {
        get {
            // 从 UIApplication 实例获取关联的弹窗 window
            // 使用关联对象而非存储在 AlertController 实例上，是因为弹窗可能在多个地方展示
            // 共享同一个 window 可以避免重复创建和资源浪费
            objc_getAssociatedObject(UIApplication.shared, &JGSAssociatedKey.jg_alertWindowKey) as? UIWindow
        }
        set {
            // 将弹窗 window 关联到 UIApplication 实例
            // 使用 RETAIN_NONATOMIC 策略，因为所有操作都在主线程进行
            objc_setAssociatedObject(UIApplication.shared, &JGSAssociatedKey.jg_alertWindowKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 在指定视图所在的 window 上展示弹窗，如果未指定则使用全局 key window 或创建自定义 window
    /// - Parameter from: 指定的视图，弹窗将从该视图所在的 window 进行展示
    fileprivate func jg_show(from: UIView? = nil) {
        // Window 获取优先级：
        // 1. from?.window - 优先使用指定视图所在的 window，确保弹窗在正确的场景中展示
        // 2. UIApplication.shared.jg_keyWindow - 如果未指定视图，则使用应用当前的 key window
        // 3. 自定义 window - 如果以上都不可用，则创建一个临时的 alert window
        
        // 注意：自定义 window 适用于单场景应用，多场景应用中 window 可能无法达到预期效果
        guard let alertWin = from?.window ?? UIApplication.shared.jg_keyWindow ?? {
            // 尝试获取已缓存的自定义弹窗 window
            let alertWin = jg_appAlertWindow ?? {
                // 如果没有缓存的 window，则创建一个新的
                // 首先获取当前 key window 的 windowScene，用于创建新 window
                guard let fromScene = UIApplication.shared.jg_keyWindow?.windowScene else { return nil }
                
                // 创建新的 UIWindow，层级设置为 .alert 确保在其他 window 之上
                let alertWin = UIWindow(windowScene: fromScene)
                alertWin.windowLevel = .alert
                
                // 创建一个透明的根视图控制器
                // 注意：必须设置透明背景色，因为 alert 展示时系统会默认添加半透明背景
                // 如果设置了自定义背景色，在 alert 消失动画结束前，自定义背景色会残留
                // 导致界面闪烁或影响用户体验
                let vcT = UIViewController()
                vcT.view.backgroundColor = .clear
                alertWin.rootViewController = vcT
                
                // 设置初始状态：完全不透明但隐藏，准备好接收展示请求
                alertWin.alpha = 1.0
                alertWin.isHidden = true
                
                // 将 window 关联到 UIApplication 以便后续复用
                jg_appAlertWindow = alertWin
                
                return alertWin
            }()
            return alertWin
        }(),
        // 获取 window 根控制器的顶层可见控制器，用于 present 弹窗
        let vcT = alertWin.rootViewController?.jg_topViewController
        else {
            // 如果无法获取有效的 window 或顶层控制器，直接返回，不展示弹窗
            return
        }
        
        // 使用弱引用持有 alert 对象到全局数组中
        // 使用 NSPointerArray + weakMemory 选项，避免循环引用导致的内存泄漏
        // 当 alert 对象被释放时，数组中的指针会自动变为 nil
        jg_showingAlertControllers.addPointer(Unmanaged.passUnretained(self).toOpaque())
        
        // iPad 上需要配置 popoverPresentationController
        // iPhone 上如设置 sourceView，在 iOS 26 上与 iPad 表现一致：取消按钮不显示
        // 且非弹窗区域点击后弹窗会自动消失；消失后如设置了 cancel，则通过 cancel 回调；如未设置 cancel，则不回调
        if let popover = popoverPresentationController, UIDevice.current.userInterfaceIdiom == .pad {
            popover.sourceView = alertWin
            popover.sourceRect = alertWin.bounds
            popover.permittedArrowDirections = [] // 设置为空数组，表示无箭头，弹窗居中显示
        }
        
        // 确保 window 可见且完全不透明
        // 此处设置仅对自定义 jg_appAlertWindow 生效，因为系统 window 本身就是可见的
        alertWin.isHidden = false
        alertWin.alpha = 1.0
        
        // 使用顶层控制器 present 弹窗
        // 注意：UIAlertController 的 modalPresentationStyle 由系统内部指定，手动设置无效
        vcT.present(self, animated: true) {
            // 弹窗展示完成后的回调（目前为空）
        }
    }
    
    /// 隐藏所有弹出的 Alert 弹窗
    /// - Parameters:
    ///   - animated: 是否执行消失动画，默认 true
    ///   - from: 指定的视图，若传入则仅查找并隐藏该视图所在 window 上展示的第一个弹窗；若不传则隐藏所有已展示的弹窗
    /// - Returns: 是否有需要隐藏的弹窗（true 表示有弹窗被隐藏，false 表示当前没有展示的弹窗）
    @discardableResult @objc public static
    func jg_hideAll(_ animated: Bool = true, from: UIView? = nil) -> Bool {
        
        if let from = from {
            // from查找第一次 present 出的 alert
            var cur = from.window?.rootViewController
            var alert = cur as? UIAlertController
            while let new = cur?.presentedViewController {
                cur = new
                if let newAlert = cur as? UIAlertController {
                    alert = newAlert
                    break // 找到第一个中断循环
                }
            }
            
            alert?.dismiss(animated: animated) {[weak alert] in
                alert?.updateWindowStatus()
            }
            
            return alert != nil
        }
        
        // 未指定 from 则隐藏所有展示的 alert
        let allAlert = jg_showingAlertControllers.allObjects as? [UnsafeMutableRawPointer] ?? []
        for idx in 0 ..< allAlert.count {
            if let alert = Unmanaged<NSObject>.fromOpaque(allAlert[idx]).takeUnretainedValue() as? UIAlertController {
                alert.dismiss(animated: animated) { [weak alert] in
                    alert?.updateWindowStatus()
                }
            }
        }
        
        return allAlert.count > 0
    }
    
    /// 隐藏当前弹出的 Alert 弹窗（最近展示的一个）
    /// - Parameters:
    ///   - animated: 是否执行消失动画，默认 true
    ///   - from: 指定的视图，若传入则查找并隐藏该视图所在 window 上展示的最后一个弹窗；若不传则隐藏所有已展示弹窗中最后一个
    /// - Returns: 是否有需要隐藏的弹窗（true 表示有弹窗被隐藏，false 表示当前没有展示的弹窗）
    @discardableResult @objc public static
    func jg_hideCurrent(_ animated: Bool = true, from: UIView? = nil) -> Bool {
        
        if let from = from {
            // from查找最后一次 present 出的 alert
            var cur = from.window?.rootViewController
            var alert = cur as? UIAlertController
            while let new = cur?.presentedViewController {
                cur = new
                if let newAlert = cur as? UIAlertController {
                    alert = newAlert
                }
            }
            
            alert?.dismiss(animated: animated) {[weak alert] in
                alert?.updateWindowStatus()
            }
            
            return alert != nil
        }
        
        // 未指定 from 则隐藏展示的 alert 的最后一个
        guard let alert = jg_showingAlertControllers.allObjects.last as? UIAlertController else {
            return false
        }
        
        alert.dismiss(animated: animated) { [weak alert] in
            alert?.updateWindowStatus()
        }
        
        return true
    }
    
    /// 更新弹窗 window 的状态，在弹窗关闭后清理资源
    /// 这是一个关键的清理方法，负责管理弹窗 window 的生命周期
    fileprivate func updateWindowStatus() {
        // 注意：不能直接同步执行清理逻辑
        // 原因是刚刚关闭的 alert 内存尚未释放，presentingViewController 仍被 alert 持有
        // 导致 jg_showingAlertControllers.allObjects 中仍存储有该 alert 对象
        // 无法准确判断是否还有其他弹窗正在展示
        
        // 解决方案：进行一次主线程异步调度，让系统有机会处理 alert 的释放逻辑
        // 这样在下一次 runloop 中，alert 的内存状态和 presentingViewController 引用都会更新
        DispatchQueue.main.async { [weak self] in
            // 清理 jg_showingAlertControllers 数组中的无效指针
            // NSPointerArray 使用 weakMemory 选项时，对象释放后指针会变为 NULL
            // 但需要手动调用 compact() 才能真正移除这些 NULL 元素
            
            // 先添加一个 nil 指针，这是为了触发 NSPointerArray 的内部标记机制
            // 确保后续的 compact() 能够正确清理所有 NULL 元素
            JGSDebugLog("count:", jg_showingAlertControllers.count, jg_showingAlertControllers.allObjects)
            jg_showingAlertControllers.addPointer(nil)
            
            // 调用 compact() 清理所有 NULL/nil 元素
            // 此时所有已释放的 alert 对象对应的指针都会被移除
            jg_showingAlertControllers.compact()
            JGSDebugLog("count:", jg_showingAlertControllers.count, jg_showingAlertControllers.allObjects)
            
            // 如果还有弹窗正在展示，则不清理 window
            // 因为多个弹窗可能共用同一个 window，提前清理会导致后续弹窗无法展示
            guard jg_showingAlertControllers.allObjects.count == 0 else {
                return
            }
            
            // 当所有弹窗都已关闭时，清理自定义的 alert window
            // 使用一个短暂的动画将 window 透明度变为 0
            // 这样可以避免突然消失带来的视觉闪烁
            
            // 注意：动画时长设置为 0.02 秒，非常短暂
            // 因为此时 alert 已经完全消失，只需要处理 window 的清理
            // 如果动画太长，用户会在这段时间内无法操作界面
            UIView.animate(withDuration: 0.02) { [weak self] in
                self?.jg_appAlertWindow?.alpha = 0
            } completion: { [weak self] finished in
                // 动画完成后，隐藏 window 并从父视图中移除
                // 这样可以释放 window 占用的资源，同时确保不会影响其他界面操作
                self?.jg_appAlertWindow?.isHidden = true
                self?.jg_appAlertWindow?.removeFromSuperview()
                JGSDebugLog("jg_showingAlertControllers:", jg_showingAlertControllers.allObjects)
            }
        }
    }
}

extension UIView {
    
    /// 显示系统 alert 弹窗，从当前视图所在的 window 进行展示
    /// - Parameters:
    ///   - title: 弹窗标题，默认 nil
    ///   - message: 弹窗提示内容，默认 nil
    ///   - cancel: 取消按钮标题，默认 nil（不传则不显示取消按钮）
    ///   - destructive: 红色警告按钮标题，默认 nil（不传则不显示警告按钮）
    ///   - others: 其他按钮标题数组，默认空数组（不传则不显示其他按钮）
    ///   - action: 按钮点击回调，idx 参数对应按钮索引：cancel 为 jg_cancelIdx(0)，destructive 为 jg_destructiveIdx(1)，others 从 jg_firstOtherIdx(2) 开始递增
    /// - Returns: 创建的 UIAlertController 实例
    @discardableResult @objc public
    func jg_alert(title: String? = nil, message: String? = nil, cancel: String? = nil, destructive: String? = nil, others: [String] = [], action: ((_ alert: UIAlertController, _ idx: Int) -> Void)? = nil) -> UIAlertController {
        jg_showAlert(title: title, message: message, style: .alert, cancel: cancel, destructive: destructive, others: others, action: action)
    }
    
    /// 显示系统 actionSheet 弹窗，从当前视图所在的 window 进行展示
    /// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
    /// - Parameters:
    ///   - title: 弹窗标题，默认 nil
    ///   - message: 弹窗提示内容，默认 nil
    ///   - cancel: 取消按钮标题，默认 nil（不传则不显示取消按钮）
    ///   - destructive: 红色警告按钮标题，默认 nil（不传则不显示警告按钮）
    ///   - others: 其他按钮标题数组，默认空数组（不传则不显示其他按钮）
    ///   - action: 按钮点击回调，idx 参数对应按钮索引：cancel 为 jg_cancelIdx(0)，destructive 为 jg_destructiveIdx(1)，others 从 jg_firstOtherIdx(2) 开始递增
    /// - Returns: 创建的 UIAlertController 实例
    @discardableResult @objc public
    func jg_actionSheet(title: String? = nil, message: String? = nil, cancel: String? = nil, destructive: String? = nil, others: [String] = [], action: ((_ alert: UIAlertController, _ idx: Int) -> Void)? = nil) -> UIAlertController {
        jg_showAlert(title: title, message: message, style: .actionSheet, cancel: cancel, destructive: destructive, others: others, action: action)
    }
    
    /// 显示系统 alert / actionSheet 弹窗，从当前视图所在的 window 进行展示
    /// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
    /// - Parameters:
    ///   - title: 弹窗标题，默认 nil
    ///   - message: 弹窗提示内容，默认 nil
    ///   - style: 弹窗风格，.alert 或 .actionSheet，默认 .alert
    ///   - cancel: 取消按钮标题，默认 nil（不传则不显示取消按钮）
    ///   - destructive: 红色警告按钮标题，默认 nil（不传则不显示警告按钮）
    ///   - others: 其他按钮标题数组，默认空数组（不传则不显示其他按钮）
    ///   - action: 按钮点击回调，idx 参数对应按钮索引：cancel 为 jg_cancelIdx(0)，destructive 为 jg_destructiveIdx(1)，others 从 jg_firstOtherIdx(2) 开始递增
    /// - Returns: 创建的 UIAlertController 实例
    @discardableResult @objc public
    func jg_showAlert(title: String? = nil, message: String? = nil, style: UIAlertController.Style = .alert, cancel: String? = nil, destructive: String? = nil, others: [String] = [], action: ((_ alert: UIAlertController, _ idx: Int) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, style: style, cancel: cancel, destructive: destructive, others: others, action: action)
        
        alert.jg_show(from: self)
        
        return alert
    }
    
    /// 隐藏当前视图所在 window 上展示的所有 Alert 弹窗
    /// - Parameter animated: 是否执行消失动画，默认 true
    /// - Returns: 是否有需要隐藏的弹窗（true 表示有弹窗被隐藏，false 表示当前没有展示的弹窗）
    @discardableResult @objc public
    func jg_hideAllAlert(_ animated: Bool = true) -> Bool {
        return UIAlertController.jg_hideAll(animated, from: self)
    }
    
    /// 隐藏当前视图所在 window 上展示的最后一个 Alert 弹窗
    /// - Parameter animated: 是否执行消失动画，默认 true
    /// - Returns: 是否有需要隐藏的弹窗（true 表示有弹窗被隐藏，false 表示当前没有展示的弹窗）
    @discardableResult @objc public
    func jg_hideCurrentAlert(_ animated: Bool = true) -> Bool {
        return UIAlertController.jg_hideCurrent(animated, from: self)
    }
}

extension UIViewController {
    
    /// 显示系统 alert 弹窗，从当前控制器视图所在的 window 进行展示
    /// - Parameters:
    ///   - title: 弹窗标题，默认 nil
    ///   - message: 弹窗提示内容，默认 nil
    ///   - cancel: 取消按钮标题，默认 nil（不传则不显示取消按钮）
    ///   - destructive: 红色警告按钮标题，默认 nil（不传则不显示警告按钮）
    ///   - others: 其他按钮标题数组，默认空数组（不传则不显示其他按钮）
    ///   - action: 按钮点击回调，idx 参数对应按钮索引：cancel 为 jg_cancelIdx(0)，destructive 为 jg_destructiveIdx(1)，others 从 jg_firstOtherIdx(2) 开始递增
    /// - Returns: 创建的 UIAlertController 实例
    @discardableResult @objc public
    func jg_alert(title: String? = nil, message: String? = nil, cancel: String? = nil, destructive: String? = nil, others: [String] = [], action: ((_ alert: UIAlertController, _ idx: Int) -> Void)? = nil) -> UIAlertController {
        return jg_showAlert(title: title, message: message, style: .alert, cancel: cancel, destructive: destructive, others: others, action: action)
    }
    
    /// 显示系统 actionSheet 弹窗，从当前控制器视图所在的 window 进行展示
    /// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
    /// - Parameters:
    ///   - title: 弹窗标题，默认 nil
    ///   - message: 弹窗提示内容，默认 nil
    ///   - cancel: 取消按钮标题，默认 nil（不传则不显示取消按钮）
    ///   - destructive: 红色警告按钮标题，默认 nil（不传则不显示警告按钮）
    ///   - others: 其他按钮标题数组，默认空数组（不传则不显示其他按钮）
    ///   - action: 按钮点击回调，idx 参数对应按钮索引：cancel 为 jg_cancelIdx(0)，destructive 为 jg_destructiveIdx(1)，others 从 jg_firstOtherIdx(2) 开始递增
    /// - Returns: 创建的 UIAlertController 实例
    @discardableResult @objc public
    func jg_actionSheet(title: String? = nil, message: String? = nil, cancel: String? = nil, destructive: String? = nil, others: [String] = [], action: ((_ alert: UIAlertController, _ idx: Int) -> Void)? = nil) -> UIAlertController {
        return jg_showAlert(title: title, message: message, style: .actionSheet, cancel: cancel, destructive: destructive, others: others, action: action)
    }
    
    /// 显示系统 alert / actionSheet 弹窗，从当前控制器视图所在的 window 进行展示
    /// iOS 26 开始 actionSheet 在 iPhone 与 iPad 上表现一致，均为居中弹窗
    /// - Parameters:
    ///   - title: 弹窗标题，默认 nil
    ///   - message: 弹窗提示内容，默认 nil
    ///   - style: 弹窗风格，.alert 或 .actionSheet，默认 .alert
    ///   - cancel: 取消按钮标题，默认 nil（不传则不显示取消按钮）
    ///   - destructive: 红色警告按钮标题，默认 nil（不传则不显示警告按钮）
    ///   - others: 其他按钮标题数组，默认空数组（不传则不显示其他按钮）
    ///   - action: 按钮点击回调，idx 参数对应按钮索引：cancel 为 jg_cancelIdx(0)，destructive 为 jg_destructiveIdx(1)，others 从 jg_firstOtherIdx(2) 开始递增
    /// - Returns: 创建的 UIAlertController 实例
    @discardableResult @objc public
    func jg_showAlert(title: String? = nil, message: String? = nil, style: UIAlertController.Style = .alert, cancel: String? = nil, destructive: String? = nil, others: [String] = [], action: ((_ alert: UIAlertController, _ idx: Int) -> Void)? = nil) -> UIAlertController {
        return self.view.jg_showAlert(title: title, message: message, style: style, cancel: cancel, destructive: destructive, others: others, action: action)
    }
    
    /// 隐藏当前控制器视图所在 window 上展示的所有 Alert 弹窗
    /// - Parameter animated: 是否执行消失动画，默认 true
    /// - Returns: 是否有需要隐藏的弹窗（true 表示有弹窗被隐藏，false 表示当前没有展示的弹窗）
    @discardableResult @objc public
    func jg_hideAllAlert(_ animated: Bool = true) -> Bool {
        return self.view.jg_hideAllAlert(animated)
    }
    
    /// 隐藏当前控制器视图所在 window 上展示的最后一个 Alert 弹窗
    /// - Parameter animated: 是否执行消失动画，默认 true
    /// - Returns: 是否有需要隐藏的弹窗（true 表示有弹窗被隐藏，false 表示当前没有展示的弹窗）
    @discardableResult @objc public
    func jg_hideCurrentAlert(_ animated: Bool = true) -> Bool {
        return self.view.jg_hideCurrentAlert(animated)
    }
}
