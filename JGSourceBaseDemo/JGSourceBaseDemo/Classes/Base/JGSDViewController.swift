//
//  JGSDemoViewController.swift
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/12/9.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

import UIKit

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

}
