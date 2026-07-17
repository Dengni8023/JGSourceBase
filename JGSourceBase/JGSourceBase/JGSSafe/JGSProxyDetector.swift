//
//  JGSProxyDetector.swift
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/23.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import CFNetwork

public
struct JGSProxyOptions: OptionSet, @unchecked Sendable {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// 网络配置：手动http代理配置
    public static var http: JGSProxyOptions { JGSProxyOptions(rawValue: 1 << 0) }
    /// 网络配置：手动https代理配置
    public static var https: JGSProxyOptions { JGSProxyOptions(rawValue: 1 << 1) }
    /// 网络配置：手动socks代理配置
    public static var socks: JGSProxyOptions { JGSProxyOptions(rawValue: 1 << 2) }
    /// 网络配置：自动代理配置/
    public static var auto: JGSProxyOptions { JGSProxyOptions(rawValue: 1 << 3) }
    /// VPN网络
    public static var vpn: JGSProxyOptions { JGSProxyOptions(rawValue: 1 << 4) }
}

public final
class JGSProxyDetector: JGSSwiftClass<NSObject> {
    
    /// 系统层VPN、网络代理开启状态判断，无法针对特定域名判断
    /// - Returns: 代理、VPN开启状态
    public static
    func proxyEnabledTypes() -> JGSProxyOptions {
        // 系统代理设置
        guard let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else {
            return []
        }
        JGSDebugLog("settings:", settings)
        
        // 网络代理设置
        let proxyTypes: [String: JGSProxyOptions] = [
            "HTTPEnable" : .http,
            "HTTPSEnable": .https,
            "SOCKSEnable": .socks,
            "ProxyAutoConfigEnable": .auto,
        ]
        var options: [JGSProxyOptions] = proxyTypes.compactMap({ (key: String, value: JGSProxyOptions) in
            // 测试验证发现存在以下情况：
            // 1. iPhone真机无代理设置，则不返回相关enable字段
            // 2. 模拟器无代理设置，返回相关enable字段可能为0
            // 因此，需要判断enable值
            if let enable = settings[key] as? Bool, enable {
                return value
            } else if let enable = settings[key] as? NSNumber, enable.isEqual(to: NSNumber(value: 0)) {
                return value
            }
            return nil
        })
        
        // VPN设置
        // 当 VPN 连接时，系统会创建一个虚拟网络接口（如 tun0、utun1），这个接口信息会出现在 __SCOPED__ 字典中
        if let scopeKeys = (settings["__SCOPED__"] as? [String: Any])?.keys {
            // VPN 接口关键词：VPN 连接会创建虚拟网络接口，其名称通常包含以下关键词
            // tap / tun：最常见的 VPN 隧道接口
            // ppp：点对点协议，用于某些 VPN 类型
            // ipsec：IPsec VPN 协议
            // utun：用户态 tun 接口，在较新的 iOS 系统中被广泛使用
            let vpnTypes = ["tap", "tun", "ppp", "ipsec", "utun"].filter { vpnKey in
                for scopeKey in scopeKeys {
                    // 接口名称通常带有数字后缀（如 tun0、utun1）
                    // 使用 starts 进行模糊匹配能更准确地识别
                    if scopeKey.starts(with: vpnKey) {
                        return true
                    }
                }
                return false
            }
            if vpnTypes.count > 0 {
                options.append(.vpn)
            }
        }
        
        let enableTypes = JGSProxyOptions(options)
        JGSDebugLog(format: "enableTypes: %@", enableTypes)
        
        return enableTypes
    }
    
    /// 系统层VPN开启状态判断（VPN状态无法针对特定URL）、特定URL的网络代理配置
    /// iPhone无法配置例外，可通过模拟器运行，Mac 网络代理配置 http、https、socks、例外进行验证
    /// - Parameter url: 指定url
    /// - Returns: VPN、代理开启状态
    public static
    func proxyEnabledTypes(for url: String) -> JGSProxyOptions {
        guard let URL = URL(string: url) else {
            return proxyEnabledTypes()
        }
        return proxyEnabledTypes(for: URL)
    }
    
    /// 系统层VPN开启状态判断（VPN状态无法针对特定URL）、特定URL的网络代理配置
    /// iPhone无法配置例外，可通过模拟器运行，Mac 网络代理配置 http、https、socks、例外进行验证
    /// - Parameter url 指定URL
    /// - Returns: VPN、代理开启状态
    public static
    func proxyEnabledTypes(for url: URL) -> JGSProxyOptions {
        // 系统代理设置
        guard let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue(),
              let proxies = CFNetworkCopyProxiesForURL(url as CFURL, settings).takeRetainedValue() as? [[CFString: Any]]
        else {
            return []
        }
        JGSDebugLog("settings:", settings)
        JGSDebugLog("proxies for \(url) :", proxies)
        
        let urlProxies = proxies.compactMap({ dict in
            return dict[kCFProxyTypeKey]
        }) as? [CFString] ?? []
        
        // 网络代理设置
        let proxyTypes: [CFString: JGSProxyOptions] = [
            kCFProxyTypeHTTP : .http,
            kCFProxyTypeHTTPS: .https,
            kCFProxyTypeSOCKS: .socks,
            kCFProxyTypeAutoConfigurationURL: .auto,
        ]
        var options: [JGSProxyOptions] = proxyTypes.compactMap({ (key: CFString, value: JGSProxyOptions) in
            if urlProxies.contains(key) {
                return value
            }
            return nil
        })
        
        // VPN设置
        // 当 VPN 连接时，系统会创建一个虚拟网络接口（如 tun0、utun1），这个接口信息会出现在 __SCOPED__ 字典中
        if let scopeKeys = ((settings as? [String: Any])?["__SCOPED__"] as? [String: Any])?.keys {
            // VPN 接口关键词：VPN 连接会创建虚拟网络接口，其名称通常包含以下关键词
            // tap / tun：最常见的 VPN 隧道接口
            // ppp：点对点协议，用于某些 VPN 类型
            // ipsec：IPsec VPN 协议
            // utun：用户态 tun 接口，在较新的 iOS 系统中被广泛使用
            let vpnTypes = ["tap", "tun", "ppp", "ipsec", "utun"].filter { vpnKey in
                for scopeKey in scopeKeys {
                    // 接口名称通常带有数字后缀（如 tun0、utun1）
                    // 使用 starts 进行模糊匹配能更准确地识别
                    if scopeKey.starts(with: vpnKey) {
                        return true
                    }
                }
                return false
            }
            if vpnTypes.count > 0 {
                options.append(.vpn)
            }
        }
        
        let enableTypes = JGSProxyOptions(options)
        JGSDebugLog("enableTypes for \(url):", enableTypes.rawValue)
        
        return enableTypes
    }
}
