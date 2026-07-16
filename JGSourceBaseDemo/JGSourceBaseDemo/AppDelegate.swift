//
//  AppDelegate.swift
//  JGSourceBaseDemo
//
//  Created by Mei JiGao on 2026/6/15.
//

import UIKit
import JGSourceBase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
#if DEBUG
        JGSLogger.enableDebug = true // 开启JGSourceBase内部调试日志
        JGSLogger.enableLog(mode: .func, level: .debug, useNSLog: UIDevice.current.systemVersion < "15.0")
#endif
        JGSLog("JGSourceBaseVersion:", JGSourceBaseVersion);
        JGSLog("JGSourceBaseVersion:", JGSourceBaseVersion());
        JGSLog("JGSourceBaseVersion:", JGSBaseUtils.version);
        
        sleep(3)
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

