//
//  main.swift
//  JGSourceBaseCMD
//
//  Created by Mei JiGao on 2026/6/30.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import Foundation

print("Hello, World!")

JGSLogger.enableDebug = true
JGSLogger.enableLog(mode: .func)

// Swift示例方法
JGSCommandLine.shared.sortPlistFiles()
JGSCommandLine.shared.sortJSONFiles()
JGSCommandLine.shared.sortAndAESEncryptionDeviceList()
