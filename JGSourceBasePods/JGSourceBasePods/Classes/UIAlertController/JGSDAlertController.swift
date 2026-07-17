//
//  JGSDAlertController.swift
//  JGSourceBaseDemo
//
//  Created by Mei JiGao on 2026/7/14.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import UIKit

class JGSDAlertController: JGSDViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Data
    override func loadData() {
        let alertTitle = "提示"
        let actionTitle = "选项"
        let cancel = "取消"
        let destructive = "警告"
        setupData(sections: [
            ("Alert", [
                JGSDTableCellData(title: "无按钮", action: { [weak self] indexPath in
                    let message = "无按钮提示"
                    if Bool.random() {
                        self?.jg_alert(title: alertTitle, message: message) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_alert(title: alertTitle, message: message) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "单取消", action: { [weak self] indexPath in
                    let message = "单取消按钮提示"
                    if Bool.random() {
                        self?.jg_alert(title: alertTitle, message: message, cancel: cancel) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_alert(title: alertTitle, message: message, cancel: cancel) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "单警告", action: { [weak self] indexPath in
                    let message = "单警告按钮提示"
                    if Bool.random() {
                        self?.jg_alert(title: alertTitle, message: message, destructive: destructive) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_alert(title: alertTitle, message: message, destructive: destructive) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "取消+单其他", action: { [weak self] indexPath in
                    let message = "取消+单其他按钮提示"
                    if Bool.random() {
                        self?.jg_alert(title: alertTitle, message: message, cancel: cancel, others: ["其他"]) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_alert(title: alertTitle, message: message, cancel: cancel, others: ["其他"]) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "警告+单其他", action: { [weak self] indexPath in
                    let message = "警告+单其他按钮提示"
                    if Bool.random() {
                        self?.jg_alert(title: alertTitle, message: message, destructive: destructive, others: ["其他"]) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_alert(title: alertTitle, message: message, destructive: destructive, others: ["其他"]) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "取消+其他", action: { [weak self] indexPath in
                    let message = "取消+其他按钮提示"
                    let others = ["其他-1", "其他-2", "其他-3"]
                    if Bool.random() {
                        self?.jg_alert(title: alertTitle, message: message, cancel: cancel, others: others) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_alert(title: alertTitle, message: message, cancel: cancel, others: others) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "警告+其他", action: { [weak self] indexPath in
                    let message = "警告+其他按钮提示"
                    let others = ["其他-1", "其他-2", "其他-3"]
                    if Bool.random() {
                        self?.jg_alert(title: alertTitle, message: message, destructive: destructive, others: others) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_alert(title: alertTitle, message: message, destructive: destructive, others: others) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "取消+警告", action: { [weak self] indexPath in
                    let message = "取消+警告按钮提示"
                    if Bool.random() {
                        self?.jg_alert(title: alertTitle, message: message, cancel: cancel, destructive: destructive) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_alert(title: alertTitle, message: message, cancel: cancel, destructive: destructive) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "取消+警告+其他", action: { [weak self] indexPath in
                    let message = "取消+警告+其他按钮提示"
                    let others = ["其他-1", "其他-2", "其他-3", "其他-4", "其他-5", "其他-6", "其他-7", "其他-8", "其他-9", "其他-10", "其他-11", "其他-12", "其他-13", "其他-14", "其他-15", "其他-16", "其他-17", "其他-18", "其他-19", "其他-20"]
                    if Bool.random() {
                        self?.jg_alert(title: alertTitle, message: message, cancel: cancel, destructive: destructive, others: others) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_alert(title: alertTitle, message: message, cancel: cancel, destructive: destructive, others: others) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
            ]),
            ("ActionSheet - iOS26开始Phone屏幕居中弹窗", [
                JGSDTableCellData(title: "无按钮", action: { [weak self] indexPath in
                    let message = "无按钮选择"
                    if Bool.random() {
                        self?.jg_actionSheet(title: actionTitle, message: message) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_actionSheet(title: actionTitle, message: message) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "单取消", action: { [weak self] indexPath in
                    let message = "单取消按钮选择"
                    if Bool.random() {
                        self?.jg_actionSheet(title: actionTitle, message: message, cancel: cancel) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_actionSheet(title: actionTitle, message: message, cancel: cancel) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "单警告", action: { [weak self] indexPath in
                    let message = "单警告按钮选择"
                    if Bool.random() {
                        self?.jg_actionSheet(title: actionTitle, message: message, destructive: destructive) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_actionSheet(title: actionTitle, message: message, destructive: destructive) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "取消+单其他", action: { [weak self] indexPath in
                    let message = "取消+单其他按钮选择"
                    if Bool.random() {
                        self?.jg_actionSheet(title: actionTitle, message: message, cancel: cancel, others: ["其他"]) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_actionSheet(title: actionTitle, message: message, cancel: cancel, others: ["其他"]) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "警告+单其他", action: { [weak self] indexPath in
                    let message = "警告+单其他按钮选择"
                    if Bool.random() {
                        self?.jg_actionSheet(title: actionTitle, message: message, destructive: destructive, others: ["其他"]) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_actionSheet(title: actionTitle, message: message, destructive: destructive, others: ["其他"]) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "取消+其他", action: { [weak self] indexPath in
                    let message = "取消+其他按钮选择"
                    let others = ["其他-1", "其他-2", "其他-3"]
                    if Bool.random() {
                        self?.jg_actionSheet(title: actionTitle, message: message, cancel: cancel, others: others) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_actionSheet(title: actionTitle, message: message, cancel: cancel, others: others) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "警告+其他", action: { [weak self] indexPath in
                    let message = "警告+其他按钮选择"
                    let others = ["其他-1", "其他-2", "其他-3"]
                    if Bool.random() {
                        self?.jg_actionSheet(title: actionTitle, message: message, destructive: destructive, others: others) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_actionSheet(title: actionTitle, message: message, destructive: destructive, others: others) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "取消+警告", action: { [weak self] indexPath in
                    let message = "取消+警告按钮选择"
                    if Bool.random() {
                        self?.jg_actionSheet(title: actionTitle, message: message, cancel: cancel, destructive: destructive) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_actionSheet(title: actionTitle, message: message, cancel: cancel, destructive: destructive) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
                JGSDTableCellData(title: "取消+警告+其他", action: { [weak self] indexPath in
                    let message = "取消+警告+其他按钮选择"
                    let others = ["其他-1", "其他-2", "其他-3", "其他-4", "其他-5", "其他-6", "其他-7", "其他-8", "其他-9", "其他-10", "其他-11", "其他-12", "其他-13", "其他-14", "其他-15", "其他-16", "其他-17", "其他-18", "其他-19", "其他-20"]
                    if Bool.random() {
                        self?.jg_actionSheet(title: actionTitle, message: message, cancel: cancel, destructive: destructive, others: others) { alert, idx in
                            JGSLog("\(alert): \(idx)")
                        }
                        return
                    }
                    UIAlertController.jg_actionSheet(title: actionTitle, message: message, cancel: cancel, destructive: destructive, others: others) { alert, idx in
                        JGSLog("\(alert): \(idx)")
                    }
                }),
            ])
        ])
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: false)
//        
//        showConsoleLog("indexPath:", indexPath)
//        
//        let actionTitle = "选项"
//        let message = "无按钮选择"
////        if Bool.random() {
////            jg_actionSheet(title: actionTitle, message: message) { alert, idx in
////                JGSLog("\(alert): \(idx)")
////            }
////            return
////        }
////        UIAlertController.jg_actionSheet(title: actionTitle, message: message) { alert, idx in
////            JGSLog("\(alert): \(idx)")
////        }
//        
//        let vcT = UIAlertController(title: actionTitle, message: message, preferredStyle: .actionSheet)
//        let cancel = UIAlertAction(title: "取消", style: .cancel)
//        vcT.addAction(cancel)
//        self.present(vcT, animated: true)
//    }
}
