//
//  JGSBaseUtils.swift
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/29.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import UIKit

/// JGSourceBase框架的bundle名称
internal let JGSourceBaseFrameworkBundleName = {
    "JGSourceBase.framework"
}()

/// JGSourceBase资源bundle名称
/// TODO: ⚠️ 注意与 podspec 文件中 resource_bundles 名称保持一致
internal let JGSourceBaseResourceBundleName = {
    "JGSourceBase.bundle"
}()

@objcMembers public
class JGSBaseUtils: NSObject {
    
    /// 获取JGSourceBase.framework的bundle
    public static let classBundle: Bundle = {
        return Bundle(for: JGSBaseUtils.self)
    }()
    
    /// 获取JGSourceBase.bundle的bundle
    /// 
    /// 查找顺序：
    /// 1. JGSourceBase.framework 内部
    /// 2. 主应用 Bundle 内部
    /// 3. 递归搜索所有已加载的 bundle
    public static let resourceBundle: Bundle? = {
        // 优先查找框架内部的资源bundle
        if let resInUrl = classBundle.url(forResource: JGSourceBaseResourceBundleName, withExtension: nil),
           let bundle = Bundle(url: resInUrl) {
            return bundle
        }
        // 其次查找主应用中的资源bundle
        if let resMainUrl = Bundle.main.url(forResource: JGSourceBaseResourceBundleName, withExtension: nil),
           let bundle = Bundle(url: resMainUrl) {
            return bundle
        }
        // 最后通过递归搜索查找
        return bundle(named: JGSourceBaseResourceBundleName, extension: nil)
    }()
    
    /// 获取资源文件相对主应用bundle的相对路径
    /// - Parameter name: 资源文件名，含扩展名的文件全名
    /// - Returns: String
    @objc(fileInResourceBundle:)
    public static func fileInResourceBundle(named name: String) -> String {
        let mainPath = Bundle.main.bundlePath
        if let bundle = bundle(named: name, extension: nil) {
            let relativePath = bundle.bundlePath.replacingOccurrences(of: mainPath, with: "")
            if !relativePath.isEmpty {
                return relativePath;
            }
        }
        return name;
    }
    
    /// 获取资源文件所在bundle，查找到就返回，不检查是否loaded
    /// - Parameters:
    ///   - name: 资源文件全名，name和ext扩展名组合为文件全名，无法获取Assets.car中的资源
    ///   - ext: 文件扩展名
    /// - Returns: Bundle
    public static func bundle(named name: String, extension ext: String?) -> Bundle? {
        return bundle(named: name, extension: ext, check: false)
    }
    
    /// 获取资源文件所在bundle
    /// 
    /// 使用广度优先搜索（BFS）算法，从主应用bundle开始逐级查找所有子目录中的bundle
    /// 广度优先搜索可以保证先找到层级较浅的bundle，提高查找效率
    /// 
    /// - Parameters:
    ///   - name: 资源文件全名，name和ext扩展名组合为文件全名，无法获取Assets.car中的资源
    ///   - ext: 文件扩展名
    ///   - loaded: 是否检查必须加载。不检查时查找到一个就返回；检查时找到包含资源文件的bundle时，bundle必须是loaded，否则继续查找，不存在loaded的bundle时返回nil
    /// - Returns: 包含目标资源文件的Bundle，如果未找到则返回nil
    /// 
    /// 搜索流程：
    /// 1. 初始化搜索队列，将主应用bundle路径作为起始点
    /// 2. 从队列头部取出路径，尝试创建bundle并检查是否包含目标资源
    /// 3. 如果找到且满足loaded条件，直接返回该bundle
    /// 4. 如果未找到或不满足条件，获取当前目录下的所有子目录
    /// 5. 将子目录路径加入搜索队列尾部
    /// 6. 重复步骤2-5，直到队列为空或找到目标bundle
    @objc(bundleWithName:extension:checkLoaded:)
    public static func bundle(named name: String, extension ext: String?, check loaded: Bool = false) -> Bundle? {
        // 使用广度优先搜索，从主应用bundle开始
        var searchQueue: [String] = [Bundle.main.bundlePath]
        
        while !searchQueue.isEmpty {
            let curPath = searchQueue.removeFirst()
            
            // 尝试创建bundle并检查是否包含目标资源文件
            // 这里需要两次创建bundle：第一次检查资源是否存在，第二次返回实际的bundle对象
            if let found = Bundle(path: curPath)?.path(forResource: name, ofType: ext),
               let foundBundle = Bundle(path: found) {
                // 根据loaded参数决定是否需要检查bundle已加载
                // 如果loaded为true，只有当bundle已经加载时才返回
                if !loaded || foundBundle.isLoaded {
                    return foundBundle
                }
            }

            // 获取当前目录下的所有子目录，加入搜索队列
            // 使用 try? 处理可能的权限或路径错误，遇到错误时跳过当前目录继续搜索
            guard let contents = try? FileManager.default.contentsOfDirectory(atPath: curPath)
            else {
                continue
            }

            // 遍历当前目录下的所有项目，只将子目录加入搜索队列
            contents.forEach { item in
                let fullPath = URL(fileURLWithPath: curPath).appendingPathComponent(item).path
                var isDir: ObjCBool = false
                if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir), isDir.boolValue {
                    searchQueue.append(fullPath)
                }
            }
        }

        return nil
    }
    
    /// 返回资源图片
    /// 
    /// 注意：如果资源图片在assets中，需要使用XcodeTarget以进行资源处理，最终在bundle资源内生成对应的Assets.car文件，否则assets资源无法加载
    /// 
    /// 查找顺序：
    /// 1. JGSourceBase.bundle 在主应用中
    /// 2. JGSourceBase.bundle 在 JGSourceBase.framework 根目录
    /// 3. 图片直接在 JGSourceBase.framework 根目录
    /// 4. 递归搜索查找 JGSourceBase.bundle
    /// 
    /// - Parameter name: 图片资源文件名，不需要 @x及png后缀
    /// - Returns: UIImage?
    @objc(imageInResourceBundle:)
    public static func imageInResourceBundle(named name: String) -> UIImage? {
        
        // UIImage(named:, in:, with: ) 根据配置返回对应的图片
        // 配置 nil，会根据 APP 当前的主题设置查找对应配置的图片，未查找到则回退 Any
        
        // 查找顺序1：JGSourceBase.bundle 在主应用中
        if let bundleUrl = Bundle.main.url(forResource: JGSourceBaseResourceBundleName, withExtension: nil),
           let bundle = Bundle(url: bundleUrl), let img = UIImage(named: name, in: bundle, with: nil) {
            return img
        }
        // 查找顺序2：JGSourceBase.bundle 在 JGSourceBase.framework 根目录
        if let bundleUrl = classBundle.url(forResource: JGSourceBaseResourceBundleName, withExtension: nil),
           let bundle = Bundle(url: bundleUrl), let img = UIImage(named: name, in: bundle, with: nil) {
            return img
        }
        // 查找顺序3：图片直接在 JGSourceBase.framework 根目录
        if let img = UIImage(named: name, in: classBundle, with: nil) {
            return img
        }
        // 查找顺序4：递归搜索查找 JGSourceBase.bundle（确保bundle已加载）
        if let bundle = bundle(named: JGSourceBaseResourceBundleName, extension: nil, check: true),
           let img = UIImage(named: name, in: bundle, with: nil) {
            return img
        }
        return nil
    }
    
    /// 获取组件版本
    // @available(*, deprecated, message: "Use JGSourceBaseVersion/JGSourceBaseVersion() instead!")
    @objc(sdkVersion)
    public static let version = {
        let version = classBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        let build = classBundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        let ret = "JGSourceBase_V\(version).\(build)"
        return ret
    }()
}
