//
//  SwiftViewController.swift
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/12/12.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

import UIKit
import JGSourceBase

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
            // 基础组件
            JGSDemoTableSectionMake(" 基础组件",
            [
                JGSDemoTableRowMake("调试日志控制-Alert扩展", nil, #selector(showLogModeList))
            ]),
            JGSDemoTableSectionMake(" 功能组件",
            [
                
            ])
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
    
    @objc func showLogModeList(_ indexPath: NSIndexPath) {
        
        print("JGSCategory_UIAlertController")
        JGSDemoShowConsoleLog(self)
    #if JGSCategory_UIAlertController_h
        print("JGSCategory_UIAlertController_h")
        let types = ["Log disable", "Log only", "Log with function line", "Log with file function line"]
        UIAlertController.jg_actionSheet(withTitle: "选择日志类型", cancel: "取消", others: types) { [weak self] alert, idx in
            
            JGSDemoShowConsoleLog(self, type(of: alert), alert, idx)
            if (idx == alert.jg_cancelIdx) {
                return
            }
            
            let selIdx = idx - alert.jg_firstOtherIdx;
            JGSEnableLogWithMode(JGSLogModeNone + selIdx)
            self?.tableView.reloadData()
            
            UIAlertController.jg_alert(title: "日志输出设置", message:types[selIdx], cancel:"确定") { [weak self] alert, idx in
                
                JGSDemoShowConsoleLog(self, type(of: alert), alert, idx)
                
    #if JGSCategory_UIApplication_h
                JGSDemoShowConsoleLog(self, "top:", UIApplication.shared.jg_topViewController)
                
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    JGSDemoShowConsoleLog(self, @"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
//                });
    #endif
            }
            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                
//                JGSStrongSelf
//                JGSDemoShowConsoleLog(self, @"key: %p", [UIApplication sharedApplication].keyWindow);
//                JGSDemoShowConsoleLog(self, @"window: %p", [UIApplication sharedApplication].delegate.window);
//                
//    #ifdef JGSCategory_UIApplication_h
//                JGSDemoShowConsoleLog(self, @"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
//    #endif
//            });
        }
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            JGSDemoShowConsoleLog(self, @"");
//            JGSDemoShowConsoleLog(self, @"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
//        });
    #endif
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        JGSLog(String.jg_transform(from: ["key":"value", "number": 0] as [String: Any]) as Any);
        JGSLog(NSString.jg_transform(from: ["key":"value", "number": 0] as [String : Any]) as Any);
        
        let _set: Set<AnyHashable> = Set([1, "2", ["3": "4"]])
        JGSLog(Array<Any>.jg_transform(from: _set))
        
        let intV: Int = 12
        let dicT: [String: Any] = [
            "Key": "T",
            "number": NSNumber(1),
            "Int": 1,
            "Float": 1.2,
            "Int12": intV,
            "True": true,
            "False": false,
            "Dict": ["1": 2,
                     "dict": [
                        "key": "value",
                        "array": [
                            "vallue1", "value2",
                            ["key": "value"]] as [Any]
                     ] as [String : Any],
                     "array": ["vallue1", "value2", ["key": "value"]] as [Any],
            ] as [String: Any],
            "Array": ["value1", "value2", "value1", "value2",
                      ["key": "value"],
                      ["key", "value"],
                      ["key": ["key": "value"]],
                      ["1": "2",
                       "dict": ["key": "value"],
                       "array": ["vallue1", "value2"],
                      ] as [String : Any],
            ] as [Any],
            "Double": 103.1236547,
            "Double2": "103.1236547",
            "Double3": ".01",
            "url": "https://m.baidu.com&key=value&key1=你 好",
        ]
        
        JGSLog(Dictionary<String, Any>.jg_transform(from: dicT))
        JGSLog()
        JGSLog(Dictionary<String, Any>.jg_transform(from: try? JSONSerialization.data(withJSONObject: dicT)))
        
        dicT.forEach { (key: String, value: Any) in
            
            JGSLog("Set: ", Set<AnyHashable>.jg_transform(from: value))
            
            JGSLog("\n{\(key): <\(type(of: dicT[key]))>\(dicT[key] ?? "nil")}", "\n",
                   "string:", dicT.jg_string(forKey: key), "\n",
                   "number:", dicT.jg_number(forKey: key), "\n",
                   "int:", dicT.jg_int(forKey: key), "\n",
                   "float:", dicT.jg_float(forKey: key), "\n",
                   "double:", dicT.jg_double(forKey: key), "\n",
                   "bool:", dicT.jg_bool(forKey: key), "\n",
                   "dict:", dicT.jg_dictionary(forKey: key), "\n",
                   "array:", dicT.jg_array(forKey: key), "\n",
                   ""
            )
            if let value = dicT[key] as? JGSJSON {
                JGSLog("\n{\(key): <\(type(of: dicT[key]))>\(dicT[key] ?? "nil")}", "\n",
                       "string:", value.jg_string, "\n",
                       "number:", value.jg_number, "\n",
                       "number:", value.jg_numberValue, "\n",
                       "url:", value.jg_URL, "\n",
                       "int:", value.jg_int, "\n",
                       "float:", value.jg_float, "\n",
                       "double:", value.jg_double, "\n",
                       "bool:", value.jg_bool, "\n",
                       "dict:", value.jg_dictionary, "\n",
                       "array:", value.jg_array, "\n",
                       ""
                )
            }
        }
        let en = PersonIntType.jg_transform(from: "0")
        JGSLog("Enum:", en)
        let json = """
        {"name":"struct","age":12,"type":"student","adminPerson":[{"name":"class","age":37,"type":"teacher","adminPerson":[{}]}]}
        """
        JGSLog("PersonStruct:", PersonStruct.jg_transform(from: json))
        JGSLog("PersonClass:", PersonClass.jg_transform(from: json))
    }
}

enum PersonStrType: String, JGSJSONEnum {
    case teacher = "teacher"
    case student = "student"
    case other = "other"
}

struct PersonStruct: JGSJSON {
    var name: String?
    var age: Int = 0
    var type: PersonStrType = .other
    var adminPerson: [PersonClass]?
}

enum PersonIntType: Int, JGSJSONEnum {
    case other = 0
    case teacher = 1
    case student = 2
}

struct PersonClass: JGSJSON {
    
    var name: String?
    var age: Int = 0
    var type: PersonIntType = .other
    var adminPerson: [PersonStruct]?
}
