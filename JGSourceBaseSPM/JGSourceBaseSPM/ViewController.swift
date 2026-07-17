//
//  ViewController.swift
//  JGSourceBaseDemo
//
//  Created by Mei JiGao on 2026/6/15.
//

import UIKit
import JGSourceBase
import SnapKit

class ViewController: UISplitViewController {
    
    convenience init() {
        if #available(iOS 14, *) {
            self.init(style: .doubleColumn)
            preferredDisplayMode = .automatic
            // preferredSplitBehavior = .tile
        } else {
            self.init(nibName: nil, bundle: nil)
            preferredDisplayMode = .allVisible
        }
        primaryBackgroundStyle = .none
        
        let primaryNav = JGSDNavigationController(rootViewController: primaryCtr)
        let detailNav = JGSDNavigationController(rootViewController: detailCtr)
        viewControllers = [primaryNav, detailNav]
        super.delegate = self
    }
    
    deinit {
        JGSLog("<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())> dealloc")
    }
    
    // UISplitViewController
    private lazy var primaryCtr = {
        let vcT = PrimaryViewController()
        return vcT
    }()
    private lazy var detailCtr = {
        let vcT = DetailViewController()
        return vcT
    }()
    
    // MARk: - Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(8)) { [weak self] in
            self?.networkReachabilityStatusTick()
        }
        DispatchQueue.jg_once("JGSReachability_startMonitor") {
             JGSReachability.shared/*sharedInstance()*/.startMonitor()
        }
        JGSReachability.shared/*sharedInstance()*/.addObserver(self) { status in
            JGSLog("Network status changed:", status, JGSReachability.shared/*shasharedInstance()*/.reachabilityStatusString)
        }
        JGSReachability.shared/*sharedInstance()*/.addObserver(self, selector: #selector(networkReachabilityStatusChanged))
        NotificationCenter.default.addObserver(forName: JGSReachabilityStatusChangedNotification/*JGSReachability.statusChangedNotification*/, object: nil, queue: nil) { notification in
            if let notiStatus = notification.userInfo?[JGSReachabilityNotificationStatusKey] as? Int,
               let status = JGSReachabilityStatus(rawValue: notiStatus) {
                JGSLog("Network status changed:", status, JGSReachability.shared/*sharedInstance()*/.reachabilityStatus, JGSReachability.shared/*sharedInstance()*/.reachabilityStatusString)
            } else {
                JGSLog("Network status changed:", JGSReachability.shared/*sharedInstance()*/.reachabilityStatus, JGSReachability.shared/*sharedInstance()*/.reachabilityStatusString)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        JGSLog(JGSourceBaseVersion())
        JGSLog(JGSBaseUtils.classBundle)
        JGSLog(JGSBaseUtils.resourceBundle)
        JGSLog(JGSBaseUtils.version);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: - Action
    func networkReachabilityStatusTick() {
        JGSDShowConsoleLog(primaryCtr, "Network status tick:", JGSReachability.shared/*sharedInstance()*/.reachabilityStatusString)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(8)) { [weak self] in
            self?.networkReachabilityStatusTick()
        }
    }
    
    @objc private
    func networkReachabilityStatusChanged(_ sender: JGSReachability? = nil) {
        let reachability = sender ?? JGSReachability.shared/*sharedInstance()*/
        JGSLog("Network status changed:", sender, reachability.reachabilityStatus, reachability.reachabilityStatusString)
        
        switch reachability.reachabilityStatus {
        case .unknown:
            break
        case .unreachable:
            break
        //case .viaWiFi:
        //    break
        case .WiFi:
            break
        case .WWAN,
             .WWANGPRS,
             .WWAN2G,
             .WWAN3G,
             .WWAN4G,
             .WWAN5G:
            break
        case .Wired:
            break
        @unknown default:
            break
        }
    }
}

// MARK: - Delegate
extension ViewController: UISplitViewControllerDelegate {
    
    private var jgsd_navigationController: UINavigationController? {
        return (isCollapsed ? primaryCtr : detailCtr).navigationController
    }
    
    // MARK: - UISplitViewControllerDelegate
    @available(iOS 14.0, *)
    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        return .primary
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    // MARK: - SplitPrimaryViewControllerAction
    func jumpToAlertControllerDemo(_ indexPath: IndexPath) {
        let vcT = JGSDAlertController()
        jgsd_navigationController?.jgsd_replaceViewController(vcT)
    }
}

// MARK: - PrimaryViewController
private
class PrimaryViewController: JGSDViewController {
    
    // MARK: - Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if #available(iOS 14, *) {
            let img: UIImage? = {
                guard let name = [
                    // "AppIcon",
                    "icon_29",
                    "assest_icon_29",
                    "bundle_icon_29",
                    "bundle_assest_icon_29",
                ].randomElement() else {
                    return nil
                }
                JGSLog("Logo name:", name)
                return JGSBaseUtils.imageInResourceBundle(named: name)
            }()
            let ocDemo = UIAction(title: "OC", image: img?.withRenderingMode(.alwaysOriginal)) { [weak self] action in
                self?.jump2OCDemo(action)
            }
            let menu = UIMenu(title: "跳转OC页面", children: [ocDemo])
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "OC"/*, image: img?.withRenderingMode(.alwaysOriginal)*/, menu: menu)
        } else {
            let ocDemo = UIBarButtonItem(title: "OC", style: .plain, target: self, action: #selector(jump2OCDemo))
            navigationItem.leftBarButtonItem = ocDemo
        }
        
        
        // iPhone
        if splitViewController?.isCollapsed == true {
            let about = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(toAbout))
            navigationItem.rightBarButtonItem = about
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showConsoleLog(Date())
    }
    
    // MARK: - Data
    override func loadData() {
        setupData(sections: [
            ("基础组件", [
                JGSDTableCellData(title: "调试日志控制", selector: (self, #selector(showLogModeList))),
                JGSDTableCellData(title: "UIAlertController", action: { [weak self] indexPath in
                    guard let split = self?.splitViewController as? ViewController else { return }
                    
                    split.jumpToAlertControllerDemo(indexPath)
                }),
            ]),
            ("安全组件", [
                JGSDTableCellData(title: "代理检测", selector: (self, #selector(checkProxyEnabled))),
            ])
        ])
    }
    
    // MARK: - Action
    @objc private
    func jump2OCDemo(_ sender: Any? = nil) {
        JGSDShowConsoleLog(self, sender)
        
        let vcT = OCViewController()
        vcT.modalPresentationStyle = .fullScreen
        present(vcT, animated: true) {
            
        }
    }
    
    @objc private
    func toAbout(_ sender: Any? = nil) {
        // 跳转关于页面
        let vcT = JGSDAboutViewController()
        navigationController?.pushViewController(vcT, animated: true)
    }
    
    @objc private
    func showLogModeList(_ indexPath: IndexPath) {
        JGSDShowConsoleLog(self, "indexPath:", indexPath)
        
        let types = ["Log disable", "Log only", "Log with function line", "Log with file function line"]
        UIAlertController.jg_showAlert(title: "选择日志类型", style: Bool.random() ? .alert : .actionSheet, cancel: "取消", others: types) { [weak self] alert, idx in
            guard let `self` = self else { return }
            
            JGSDShowConsoleLog(self, "<\(type(of: alert)): \(Unmanaged.passUnretained(alert).toOpaque())> \(idx)")
            if idx == alert.jg_cancelIdx {
                return
            }
            
            // 日志输出 mode 修改
            let selIdx = idx - alert.jg_firstOtherIdx
            JGSLogger.enableLog(mode: .none + selIdx)
            self.tableView.reloadData()
            
            // 提示日志mode
            UIAlertController.jg_showAlert(title: "日志输出设置", message: types[selIdx], cancel: "确定") { [weak self] alert, idx in
                JGSDShowConsoleLog(self, "<\(type(of: alert)): \(Unmanaged.passUnretained(alert).toOpaque())> \(idx)")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                 UIAlertController.jg_hideCurrent()
            }
        }
    }
    
    @objc private
    func checkProxyEnabled(_ indexPath: IndexPath) {
        
        let options = JGSProxyDetector.proxyEnabledTypes()
        guard options != [] else {
            jg_alert(message: "未设置网络代理", cancel: "确定")
            return
        }
        
        jg_alert(title: "安全警告", message: "已设置网络代理，请注意使用安全", cancel: "确定")
        DispatchQueue.global().async {
            ["https://m.baidu.com", "http://m.baidu.com", "https://jd.com"].forEach { domain in
                if Bool.random() {
                    guard let url = URL(string: domain) else { return }
                    JGSDShowConsoleLog(self, "isProxyEnabled for \(url):", JGSProxyDetector.proxyEnabledTypes(for: url).rawValue)
                } else {
                    JGSDShowConsoleLog(self, "isProxyEnabled for \(domain):", JGSProxyDetector.proxyEnabledTypes(for: domain).rawValue)
                }
            }
        }
    }
    
    // MARK: - Table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let rowData = {
            sections.count > 0 ? sections[indexPath.section].rows[indexPath.row] : rows[indexPath.row]
        }()
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                // 日志
                let modeMap: [JGSLogMode: String] = [
                    .none: "none - 不打印日志",
                    .log: "log - 仅日志",
                    .func: "func - 方法名、行号、日志",
                    .file: "file - 文件名、方法名、行号、日志",
                ]
                cell.textLabel?.text = "\(rowData.title): \(modeMap[JGSLogger.mode] ?? "")"
            default:
                break
            }
        default:
            break
        }
        
        return cell
    }
}

// MARK: - DetailViewController
private
class DetailViewController: JGSDViewController {
    
    // MARK: - Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 非iPhone
        if splitViewController?.isCollapsed == false {
            let about = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(toAbout))
            navigationItem.rightBarButtonItem = about
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showConsoleLog(Date())
    }
    
    // MARK: - Split
    func split(primaryViewController: JGSDViewController, didSelectRowAt indexPath: IndexPath) {
        
        JGSLog("primaryViewController didSelectRowAt indexPath:", indexPath)
    }
    
    // MARK: - Action
    @objc private
    func toAbout(_ sender: Any? = nil) {
        // 跳转关于页面
        let vcT = JGSDAboutViewController()
        navigationController?.pushViewController(vcT, animated: true)
    }
}
