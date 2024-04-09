//
//  UIApplication+JGSBase.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/7.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

public extension UIApplication {
    /// 应用的当前KeyWindow
    /// 可能为UIAlertController、UIAlertView、UIActionSheet等系统弹窗弹窗、键盘输入窗
    /// 以及应用自定义Window窗口
    @objc var jg_keyWindow: UIWindow? {
        // UIAlertController、UIAlertView、UIActionSheet弹出后
        // 这些View 出现生成了一个新的window，加在了界面上面
        // keyWindow就会变成UIAlertControllerShimPresenterWindow这个类
        // delegate、keyWindow、rootViewController均需在主线程获取
        if #available(iOS 13.0, *) {
            return connectedScenes.filter { scene in
                scene.activationState == .foregroundActive
            }.compactMap { scene in
                scene as? UIWindowScene
            }.flatMap { scene in
                scene.windows
            }.filter { window in
                window.isKeyWindow
            }.first ?? (UIApplication.shared.delegate?.window as? UIWindow)
        }
        return keyWindow ?? windows.filter { win in
            win.isKeyWindow
        }.first ?? (UIApplication.shared.delegate?.window as? UIWindow)
    }
    
    /// 应用界面视图window
    /// 不包含UIAlertController、UIAlertView、UIActionSheet等系统弹窗、键盘输入窗
    /// 以及应用自定义Window窗口
    @objc var jg_appWindow: UIWindow? {
        // UIAlertController、UIAlertView、UIActionSheet弹出后
        // 这些View 出现生成了一个新的window，加在了界面上面
        // keyWindow就会变成UIAlertControllerShimPresenterWindow这个类
        // delegate、keyWindow、rootViewController均需在主线程获取
        if #available(iOS 13.0, *) {
            return connectedScenes.filter { scene in
                scene.activationState == .foregroundActive
            }.compactMap { scene in
                scene as? UIWindowScene
            }.flatMap { scene in
                scene.windows
            }.first ?? (UIApplication.shared.delegate?.window as? UIWindow)
        }
        return (delegate?.window as? UIWindow) ?? windows.first
    }

    /// vcT对应的最顶层显示的ViewController
    /// vcT为空则内部使用jg_appWindow获取应用rootViewController
    /// 内部使用jg_appWindow获取应用rootViewController
    /// 因此不包含UIAlertController、UIAlertView、UIActionSheet等系统弹窗、键盘输入窗对应的页面
    /// 以及应用自定义Window窗口对应的页面
    fileprivate func topMostViewController(_ vcT: UIViewController? = nil, visible: Bool) -> UIViewController? {
        let curCtr = vcT ?? (visible ? jg_keyWindow : jg_appWindow)?.rootViewController
        if let rootCtr = (curCtr as? UITabBarController)?.selectedViewController {
            // UITabBarController
            return topMostViewController(rootCtr, visible: visible)
        } else if let rootCtr = curCtr as? UINavigationController {
            // UINavigationController
            // visibleViewController: Return modal view controller if it exists. Otherwise the top view controller.
            return topMostViewController(rootCtr.topViewController, visible: visible)
        } else if let rootCtr = curCtr?.presentedViewController {
            return topMostViewController(rootCtr, visible: visible)
        }
        return curCtr
    }

    /// 应用页面层最顶层显示的ViewController
    /// 内部使用jg_appWindow获取应用rootViewController
    /// 因此不包含UIAlertController、UIAlertView、UIActionSheet等系统弹窗、键盘输入窗对应的页面
    /// 以及应用自定义Window窗口对应的页面
    @objc var jg_topViewController: UIViewController? {
        return topMostViewController(visible: false)
    }
    
    /// root最顶层显示的ViewController
    /// 包含UIAlertController、UIAlertView、UIActionSheet等系统弹窗、键盘输入窗对应的页面
    @objc func jg_topViewController(_ root: UIViewController) -> UIViewController? {
        return topMostViewController(root, visible: true)
    }
    
    /// 应用层最顶层显示的ViewController
    /// 内部使用jg_keyWindow获取应用rootViewController
    /// 因此包含UIAlertController、UIAlertView、UIActionSheet等系统弹窗、键盘输入窗对应的页面
    /// 以及应用自定义Window窗口对应的页面
    @objc var jg_visibleViewController: UIViewController? {
        return topMostViewController(visible: true)
    }
}
