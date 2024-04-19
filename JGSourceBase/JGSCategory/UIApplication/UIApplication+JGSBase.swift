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
        // delegate、keyWindow、rootViewController均需在主线程获取
        if #available(iOS 13.0, *) {
            return connectedScenes.filter { scene in
                scene.activationState == .foregroundActive
            }.compactMap { scene in // compactMap 会剔除结果中的 nil 值
                scene as? UIWindowScene
            }.flatMap { scene in // flatMap 将所有结果集合并成一个，数组将维
                scene.windows
            }.filter { window in
                window.isKeyWindow
            }.first ?? windows.filter { win in
                win.isKeyWindow
            }.first ?? (delegate?.window as? UIWindow)
        }
        return keyWindow ?? windows.filter { win in
            win.isKeyWindow
        }.first ?? (delegate?.window as? UIWindow) ?? windows.first
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

    /// 应用页面层最顶层显示的ViewController
    @objc var jg_topViewController: UIViewController? {
        return topMostViewController((delegate?.window ?? windows.first)?.rootViewController)
    }
    
    /// root最顶层显示的ViewController
    /// 包含UIAlertController、UIAlertView、UIActionSheet等系统弹窗、键盘输入窗对应的页面
    @objc func jg_topViewController(_ root: UIViewController) -> UIViewController? {
        return topMostViewController(root)
    }
}
