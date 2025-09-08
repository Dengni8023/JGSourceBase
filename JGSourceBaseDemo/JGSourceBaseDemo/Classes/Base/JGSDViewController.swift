//
//  JGSDemoViewController.swift
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/12/9.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

import UIKit

func JGSDemoShowConsoleLog(vcT: JGSDViewController, format: String, _ args: CVarArg?...) {
    JGSLog(args)
    vcT.showConsoleLog(format: format, args)
}

func JGSDemoShowConsoleLog(_ vcT: JGSDViewController, _ args: Any?...) {
    JGSLog(args)
    vcT.showConsoleLog(args)
}

class JGSDViewController: JGSDemoViewController {

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableSectionData = self.tableSectionData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        JGSEnableLogWithMode(.func + 1 ?? .none)
        JGSLogFunction.enableLog(true)
        JGSLog("Test lv", mode: .file + 1, level: .debug + 1)
    }
    
    open func tableSectionData() -> [JGSDemoTableSectionData] {
        return []
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Console
    func showConsoleLog(format: String, _ args: CVarArg?...) {
        
        var tmpArgs: [CVarArg] = []
        for arg in args {
            tmpArgs.append(arg ?? "nil")
        }
        let msg = String(format: format, arguments: tmpArgs)
        showConsoleLog(msg)
    }
    
    func showConsoleLog(_ args: Any?...) {
        
    }
}
