//
//  SwiftViewController.swift
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/12/12.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

import UIKit

class SwiftViewController: JGSDViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "JGSBaseDemo"
        self.title = bundleName.appending("-Swift");
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "";
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "";
        self.subTitle = "\(version) (\(build))"
        
        let logo = JGSBaseUtils.image(inResourceBundle: "source_logo-29")
        if #available(iOS 14.0, *) {

            let toSwiftDemoAction = UIAction(title: "Objecive-C Demo", image:logo, identifier:nil) { [weak self] action in
                self?.jumpToOCDemo(action)
            }
            let menu = UIMenu(title:"页面导航", children: [toSwiftDemoAction])
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:logo, menu:menu)
        } else {
            // Fallback on earlier versions
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "ToOC", style:.plain, target:self, action: #selector(jumpToOCDemo))
        }
    }
    
    override func tableSectionData() -> [JGSDemoTableSectionData] {
         return [
            //JGSDemoTableSectionMake("Section1", [
            //    JGSDemoTableRowMake("Row1", self, #selector(jumpToOCDemo))
            //]),
            //JGSDemoTableSectionMake("Section2", []),
            //JGSDemoTableSectionMake("Section3", []),
            //JGSDemoTableSectionMake("Section4", []),
            //JGSDemoTableSectionMake("Section5", []),
        ]
    }
    
    // MARK: Action
    @objc func jumpToOCDemo(_ sender: Any? = nil) {
        
        self.navigationController?.popViewController(animated: true);
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let intV: Int = 12
        let dicT: [String: Any] = ["Key": "value", "number": NSNumber(1), "Int": 1, "Float": 1.2, "Int12": intV, "True": true, "False": false, "Dict": ["1": 2], "Array": ["value1", "value2"]]
        JGSLog(dicT.jg_string(forKey: "Key"))
        JGSLog(dicT.jg_string(forKey: "number"))
        JGSLog(dicT.jg_string(forKey: "Int"))
        JGSLog(dicT.jg_string(forKey: "Float"))
        JGSLog(dicT.jg_string(forKey: "Int12"))
        JGSLog(dicT.jg_string(forKey: "True"))
        JGSLog(dicT.jg_string(forKey: "False"))
        JGSLog(dicT.jg_string(forKey: "Dict"))
        JGSLog(dicT.jg_string(forKey: "DictT", default: "default"))
        JGSLog(dicT.jg_array(forKey: "Array", default: ["default"]))
    }
}
