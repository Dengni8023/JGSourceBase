//
//  JGSDNavigationController.swift
//  JGSourceBaseDemo
//
//  Created by Mei JiGao on 2026/6/16.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import UIKit
import JGSourceBase

class JGSDNavigationController: UINavigationController {

    deinit {
        JGSLog("<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())> dealloc")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        JGSLog()
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


extension UINavigationController {
    
    @objc
    internal func jgsd_pushViewController(_ viewController: UIViewController) {
        jgsd_pushViewController(viewController, animated: true)
    }
    
    @objc
    internal func jgsd_pushViewController(_ viewController: UIViewController, animated: Bool = true) {
        pushViewController(viewController, animated: animated)
    }
    
    @objc
    internal func jgsd_replaceViewController(_ viewController: UIViewController) {
        jgsd_replaceViewController(viewController, animated: true)
    }
    
    @objc
    internal func jgsd_replaceViewController(_ viewController: UIViewController, animated: Bool = true) {
        
        var ctrs = viewControllers
        if let _ = splitViewController {
            if ctrs.count > 1 {
                ctrs.removeLast()
            }
        } else {
            ctrs.removeLast()
        }
        ctrs.append(viewController)
        setViewControllers(ctrs, animated: animated)
    }
}
