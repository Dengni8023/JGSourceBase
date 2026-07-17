//
//  JGSDAboutViewController.swift
//  JGSourceBaseDemo
//
//  Created by Mei JiGao on 2026/7/13.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import UIKit
import SnapKit
import JGSourceBase

class JGSDAboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - View
    private func setupViews() {
        
        view.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.width.lessThanOrEqualToSuperview().multipliedBy(1.0 / 3.0)
            make.width.greaterThanOrEqualTo(375.0 * 1.0 / 3.0)
            make.height.equalTo(logo.snp.width)
            make.center.equalToSuperview()
        }
        
        view.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { make in
            make.left.greaterThanOrEqualToSuperview().inset(18)
            make.bottom.equalToSuperview().inset(24)
        }
    }
    
    private lazy var logo = {
        
        let imgV = UIImageView()
        if let name = [
            // "AppIcon",
            "icon_29",
            "assest_icon_29",
            "bundle_icon_29",
            "bundle_assest_icon_29",
        ].randomElement() {
            JGSLog("About logo name:", name)
            imgV.image = JGSBaseUtils.imageInResourceBundle(named: name)
        }

        return imgV
    }()
    
    private lazy var versionLabel = {
        let lab = UILabel()
        lab.textAlignment = .left
        lab.textColor = .lightGray
        lab.numberOfLines = 0
        lab.lineBreakMode = .byCharWrapping
        
        var labText = {
            // JGSourceBase
            let baseBundle = JGSBaseUtils.classBundle
            if let version = baseBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
               let build = baseBundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
               let resDate = baseBundle.object(forInfoDictionaryKey: "JGSResourceDate") as? String {
                return "\(baseBundle.executableURL?.lastPathComponent ?? "")：\n\t\(version)_\(build)_Res_\(resDate)"
            }
            return ""
        }()
        
        let mainBundle = Bundle.main
        if let version = mainBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString"),
           let build = mainBundle.object(forInfoDictionaryKey: "CFBundleVersion"),
           let resDate = mainBundle.object(forInfoDictionaryKey: "JGSDResourceDate"),
           let buildDate = mainBundle.object(forInfoDictionaryKey: "JGSDBuildDate") {
            labText.append("\n")
            labText.append("""
            
            \(mainBundle.executableURL?.lastPathComponent ?? "")：\n\t\(version)_\(build)_Res.\(resDate)
            
            构建时间：\n\t\(buildDate)
            """)
        }
        lab.text = labText
        return lab
    }()
}
