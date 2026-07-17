//
//  JGSDViewController.swift
//  JGSourceBaseDemo
//
//  Created by Mei JiGao on 2026/6/16.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import UIKit
import JGSourceBase
import SnapKit

/// 定义一个不暴露的泛型基类
/// 由于 Objective-C 无法理解 Swift 的泛型，这个类及其子类对 Objective-C 不可见的
class JGSDSwiftViewController<T>: UIViewController {
    deinit {
        JGSLog("<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())> dealloc")
        NotificationCenter.default.removeObserver(self)
    }
}
class JGSDViewController: JGSDSwiftViewController<UIViewController>, JGDispatchQueueOnceUUID {
    
    override var title: String? {
        set {
            super.title = newValue
        }
        get {
            super.title
        }
    }
    /// 副标题，用于设置多行标题
    var subtitle: String?
    
    // 列表数据
    private(set) var sections: [(title: String, rows: [JGSDTableCellData])] = []
    private(set) var rows: [JGSDTableCellData] = []
    
    /// 子类重写该方法调用 setupData (sections: rows: ) 设置页面数据
    /// 不需要调用super
    func loadData() {
        
    }
    
    /// final 禁止子类重写，仅允许调用
    /// sections、rows 必须有一个不为空
    final func setupData(sections: [(title: String, rows: [JGSDTableCellData])]? = nil, rows: [JGSDTableCellData]? = nil) {
        if let sections = sections {
            self.sections = sections
        }
        if let rows = rows {
            self.rows = rows
        }
        
        let secRows = self.sections.flatMap({ (title: String, rows: [JGSDTableCellData]) in
            rows
        }) as? [JGSDTableCellData] ?? []
        tableView.isHidden = secRows.count + self.rows.count == 0
    }
    
    /// 测试入口列表，默认根据sections、rows数据情况控制显示、隐藏
    private(set) lazy var tableView = {
        let v = UITableView(frame: .zero, style: .insetGrouped)
        v.isHidden = true
        v.backgroundColor = view.backgroundColor
        v.alwaysBounceVertical = true
        v.contentInsetAdjustmentBehavior = .never
        
        v.sectionHeaderHeight = UITableView.automaticDimension
        v.rowHeight = UITableView.automaticDimension
        v.sectionFooterHeight = CGFLOAT_MIN
        
        v.dataSource = self
        v.delegate = self
        v.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return v
    }()
    /// 页面内容较多时，使用该容器展示页面元素，默认隐藏
    private(set) lazy var scrollView = {
        let v = UIScrollView()
        v.isHidden = true
        v.backgroundColor = view.backgroundColor
        v.alwaysBounceVertical = true
        
        // 撑开宽度
        let line = UIView()
        v.addSubview(line)
        line.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0)
            make.width.equalToSuperview()
        }
        
        return v
    }()
    /// 页面底部日志展示窗口，顶部接tableView、scrollView底部
    private(set) lazy var logTextView = {
        let v = UITextView()
        v.backgroundColor = .white
        v.isEditable = false
        v.textColor = .darkGray
        v.font = UIFont.systemFont(ofSize: 16)
        v.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        v.attributedText = NSAttributedString(string: "调试日志输出区域，内容可复制、不可编辑", attributes: [.foregroundColor: UIColor.lightGray])
        
        return v
    }()
    
    // MARK: - Controller
    deinit {
        DispatchQueue.jg_clearExecutedIdentifier(self.jg_uuid)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        edgesForExtendedLayout = []
        view.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        
        // title
        title = title ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "\(type(of: self))"
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString"),
           let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") {
            subtitle = "\(version) \(build)"
        }
        
        loadData()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showConsoleLog("<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())> viewWillAppear at:", Date())
        
        JGSLogFunction.enableLog(!JGSLogFunction.isLogEnabled)
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .blue
        if #available(iOS 15.0, *) {
            // standardAppearance
            let standardAppearance = navigationController?.navigationBar.standardAppearance ?? UINavigationBarAppearance()
            standardAppearance.backgroundColor = navigationController?.navigationBar.barTintColor ?? UIColor(white: 0.8, alpha: 0.82)
            standardAppearance.titleTextAttributes = navigationController?.navigationBar.titleTextAttributes ?? JGSDTitleTextAttributes
            standardAppearance.backgroundEffect = nil
            standardAppearance.shadowColor = .clear
            standardAppearance.shadowImage = navigationController?.navigationBar.shadowImage
            
            navigationController?.navigationBar.standardAppearance = standardAppearance
            
            // scrollEdgeAppearance
            let scrollEdgeAppearance = navigationController?.navigationBar.scrollEdgeAppearance ?? UINavigationBarAppearance()
            scrollEdgeAppearance.backgroundColor = navigationController?.navigationBar.barTintColor ?? UIColor(white: 0.8, alpha: 0.82)
            scrollEdgeAppearance.titleTextAttributes = navigationController?.navigationBar.titleTextAttributes ?? JGSDTitleTextAttributes
            scrollEdgeAppearance.backgroundEffect = nil
            scrollEdgeAppearance.shadowColor = .clear
            scrollEdgeAppearance.shadowImage = navigationController?.navigationBar.shadowImage
            
            navigationController?.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
        }
        
        DispatchQueue.jg_once(jg_uuid) { [weak self] in
            JGSLog("jg_once:", self?.jg_uuid)
        }
        
        // 刷新数据
        tableView.reloadData()
    }
    
    // MARK: - UI
    func setupViews() {
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        view.addSubview(logTextView)
        logTextView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.top.equalTo(scrollView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.25)
        }
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

// MARK: - Console
func JGSDShowConsoleLog(_ vcT: JGSDViewController? = nil, format: String? = nil, _ args: Any?..., file: String = #file, funcName: String = #function, lineNum : Int = #line) {
    guard let vcT = vcT else {
        JGSLog(format: format, args, file: file, funcName: funcName, lineNum: lineNum) // Xcode控制台日志
        return
    }
    vcT.showConsoleLog(format: format, args, file: file, funcName: funcName, lineNum: lineNum)
}

extension JGSDViewController {
    
    func showConsoleLog(format: String? = nil, _ args: Any?..., file: String = #file, funcName: String = #function, lineNum : Int = #line) {
        let message = JGSLogMessage(format: format, args)
        JGSLog(message, file: file, funcName: funcName, lineNum: lineNum) // Xcode控制台日志
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            // 执行输出日志方法所在文件、方法、行号
            // 对文件路径进行处理，获取文件名
            let file = URL(fileURLWithPath: file).lastPathComponent
            let fileFuncLine = "[\(file) \(funcName)] Line: \(lineNum)"
            
            // 页面日志展示框日志
            let log = "\(fileFuncLine) \(message)"
            if var text = logTextView.text {
                text.append("\n\(log)")
                logTextView.text = text
            } else {
                logTextView.text = log
            }
            
            // 滚动到最新日志
            logTextView.scrollRangeToVisible(NSMakeRange(logTextView.text.count - 1, 1))
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension JGSDViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count > 0 ? sections.count : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count > 0 ? sections[section].rows.count : rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        let rowData = {
            sections.count > 0 ? sections[indexPath.section].rows[indexPath.row] : rows[indexPath.row]
        }()
        cell.textLabel?.text = rowData.title
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sections.count > 0 {
            return sections[section].title.isEmpty ? CGFLOAT_MIN : UITableView.automaticDimension
        }
        return CGFLOAT_MIN
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sections.count > 0 {
            return sections[section].title
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        guard UIDevice.current.systemVersion < "26.0" else {
            return
        }
        
        // 设置原始文本，覆盖系统的大写文本
        headerView.textLabel?.text = self.tableView(tableView, titleForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let rowData = {
            sections.count > 0 ? sections[indexPath.section].rows[indexPath.row] : rows[indexPath.row]
        }()
        
        // action 响应
        rowData.action?(indexPath)
        
        // target-selector 响应
        if let sel = rowData.selector {
            let target = sel.target
            let selector = sel.selector
            
            // 1. 获取 IMP (方法实现指针)
            // 注意：target 需为 AnyObject 并遵循 NSObjectProtocol，或者直接使用 NSObject 子类
            guard let imp = target.method(for: selector) else { return }
            // guard let imp = class_getMethodImplementation(object_getClass(target), action) else { return }
            // 2. 定义对应的 C 函数类型签名，各参数为 @objc 或者继承自 NSObject，注意返回值类型必须必须与实际匹配
            typealias ObjCMethodFunc = @convention(c) (AnyObject, Selector, IndexPath) -> Void
            // 3. 将 IMP 指针强制转换为可调用的函数类型
            let function = unsafeBitCast(imp, to: ObjCMethodFunc.self)
            // 4. 调用该函数
            function(target, selector, indexPath)
            
            // 此方案不需要验证参数为 @objc 或者继承自 NSObject
            // if target.responds(to: action) {
            //    _ = target.perform(action, with: indexPath)
            // }
        }
    }
}
