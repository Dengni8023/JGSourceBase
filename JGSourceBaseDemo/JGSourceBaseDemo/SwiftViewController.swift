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
        
        var opt: String?
        opt = "Optional"
        JGSLog(opt)
        print(opt)
        opt = "Test Optional"
        JGSLog(opt)
        print(opt)
        
        JGSLog("Test", "Test1")
        JGSLog(format: "%@, %@", "Test", "Test1")
        JGSLog(nil)
        JGSLog(format: "%@ %@, %@", "Test", nil, "Test1")
        
        var optStr: String?
        print(optStr)
        JGSLog(optStr)

        optStr = "Test optStr"
        print(optStr)
        JGSLog(optStr)

        optStr = "{\"Key\":\"Value\"}"
        print(optStr)
        JGSLog(optStr)

        let nonOptStr = "Test optStr"
        print(nonOptStr)
        JGSLog(nonOptStr)

        var testArr: [Any]? = nil
        JGSLog(testArr)
        testArr = ["String1", "String2", ["String1", "String2"], ["Key": "Value"]]
        JGSLog(testArr)

        var optDict: [String: Any]?
        //var optDict: Dictionary?
        print(optDict)
        JGSLog(optDict)
        optDict = nil
        print(optDict)
        JGSLog(optDict)
        optDict = ["TestOpt": "Test"]
        print(optDict)
        JGSLog(optDict)
        let testDict: [String: Any] = ["TestOpt": "Test"]
        print(testDict)
        JGSLog(testDict, level: .debug + 1)
        JGSLog("Test", nil, UIView())
        let dict: [String : Any] = ["Key1": "value1","Key2": "value2", "Key3": ["Key1": "value1","Key2": "value2"], "Key4": ["value1", "value2", "value3", "JGS测试", ["value1", "value2", "value3", "JGS测试"]], "Key5": "JGS测试"]
        JGSLog("TestDict", dict)
        print(dict)
        let arr: Any = ["value1", "value2", "value3", ["value1", "value2", "value3", "JGS测试"], ["Key3": ["Key1": "value1","Key2": "value2"]]]
        JGSLog("TestArray", arr)
        print(arr)
        JGSLog("测试", "\\u6d4b\\u8bd5", "\\U6d4b\\U8bd5")
        JGSLogD("测试", "\\u6d4b\\u8bd5", "\\U6d4b\\U8bd5")
        JGSLogI("测试", "\\u6d4b\\u8bd5", "\\U6d4b\\U8bd5")
        JGSLogW("测试", "\\u6d4b\\u8bd5", "\\U6d4b\\U8bd5")
        JGSLogE("测试", "\\u6d4b\\u8bd5", "\\U6d4b\\U8bd5")
        JGSLog("测试")
        
        JGSLog(13, 13.0, 14.0, 0xff, nil)
        JGSLog()
        
        
        JGSLog(#file)
        JGSLog(#fileID)
        JGSLog(#filePath)
        print(#file)
        print(#fileID)
        print(#filePath)
    }
}
