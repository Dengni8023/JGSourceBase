//
//  UIApplication+JGSBase.swift
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/21.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import UIKit

public
extension UIApplication {
    
    /// 应用的当前活动窗口场景集合
    /// 可能为UIAlertController、UIAlertView、UIActionSheet等系统弹窗、键盘输入窗
    /// 以及应用自定义Window窗口
    @objc
    var jg_windowScenes: Set<UIWindowScene> {
        return Set(
            connectedScenes.compactMap { scene in
                // compactMap 会剔除结果中的 nil 值
                scene as? UIWindowScene
            }.filter { scene in
                scene.activationState == .foregroundActive
            }
        )
    }
    
    /// 应用的当前活动窗口场景，适用于单场景应用，多场景应用随机返回
    /// 可能为UIAlertController、UIAlertView、UIActionSheet等系统弹窗、键盘输入窗
    /// 以及应用自定义Window窗口
    @objc
    var jg_windowScene: UIWindowScene? {
        return connectedScenes.compactMap { scene in
            // compactMap 会剔除结果中的 nil 值
            scene as? UIWindowScene
        }.first { scene in
            scene.activationState == .foregroundActive
        }
    }
    
    /// 应用的当前KeyWindow，适用于单场景应用，多场景应用随机返回
    /// 可能为UIAlertController、UIAlertView、UIActionSheet等系统弹窗、键盘输入窗
    /// 以及应用自定义Window窗口
    @objc
    var jg_keyWindow: UIWindow? {
        return connectedScenes.compactMap { scene in
            // compactMap 会剔除结果中的 nil 值
            scene as? UIWindowScene
        }.filter { scene in
            scene.activationState == .foregroundActive
        }.flatMap { scene in // flatMap 将所有结果集合并成一个，数组降维
            scene.windows
        }.filter { window in
            window.isKeyWindow
        }.first ?? windows.filter { win in
            win.isKeyWindow
        }.first ?? (delegate?.window as? UIWindow)
    }
    
    /// vcT对应的最顶层显示的ViewController
    /// 包含UIAlertController、UIAlertView、UIActionSheet等系统弹窗、键盘输入窗对应的页面
    /// 以及应用自定义Window窗口对应的页面
    fileprivate func topMostViewController(_ vcT: UIViewController? = nil) -> UIViewController? {
        
        var curCtr = vcT
        while curCtr?.presentedViewController != nil {
            curCtr = curCtr?.presentedViewController
        }
        
        if let rootCtr = (curCtr as? UITabBarController)?.selectedViewController {
            // UITabBarController
            return topMostViewController(rootCtr)
        } else if let rootCtr = curCtr as? UINavigationController {
            // UINavigationController
            // visibleViewController: Return modal view controller if it exists. Otherwise the top view controller.
            return topMostViewController(rootCtr.visibleViewController)
        }
        return curCtr
    }

    /// 应用页面层最顶层显示的ViewController，适用于单场景应用，多场景应用随机返回
    @objc
    var jg_topViewController: UIViewController? {
        return topMostViewController(jg_keyWindow?.rootViewController)
    }
    
    /// 视图所属最顶层显示的ViewController，适用于单场景、多场景应用
    @objc
    func jg_topViewController(of view: UIView) -> UIViewController? {
        return topMostViewController(view.window?.rootViewController)
    }
    
    /// root 最顶层显示的ViewController
    /// 包含UIAlertController、UIAlertView、UIActionSheet等系统弹窗、键盘输入窗对应的页面
    @objc
    func jg_topViewController(_ root: UIViewController) -> UIViewController? {
        return topMostViewController(root)
    }
}

extension UIView {
    
    /// 最顶层显示的ViewController，适用于单场景、多场景应用
    @objc
    var jg_topViewController: UIViewController? {
        return UIApplication.shared.topMostViewController(window?.rootViewController)
    }
}

extension UIViewController {
    
    /// 最顶层显示的ViewController，适用于单场景、多场景应用
    @objc
    var jg_topViewController: UIViewController? {
        return UIApplication.shared.topMostViewController(self)
    }
}
