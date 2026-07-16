//
//  JGSProxyDetector.h
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/25.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, JGSProxyOptions) {
    /// 网络配置：手动http代理配置
    JGSProxyOptionsHTTP = 1 << 0,
    /// 网络配置：手动https代理配置
    JGSProxyOptionsHTTPS = 1 << 1,
    /// 网络配置：手动socks代理配置
    JGSProxyOptionsSOCKS = 1 << 2,
    /// 网络配置：自动代理配置
    JGSProxyOptionsAuto = 1 << 3,
    /// VPN网络
    JGSProxyOptionsVPN = 1 << 4,
};

@interface JGSProxyDetector : NSObject

/// 系统层VPN、网络代理开启状态判断，无法针对特定域名判断
/// - Returns: 代理、VPN开启状态
+ (JGSProxyOptions)proxyEnabledTypes;

/// 系统层VPN开启状态判断（VPN状态无法针对特定URL）、特定URL的网络代理配置
/// iPhone无法配置例外，可通过模拟器运行，Mac 网络代理配置 http、https、socks、例外进行验证
/// - Parameter url: 指定url
/// - Returns: VPN、代理开启状态
+ (JGSProxyOptions)proxyEnabledTypesFor:(NSString *)url;

/// 系统层VPN开启状态判断（VPN状态无法针对特定URL）、特定URL的网络代理配置
/// iPhone无法配置例外，可通过模拟器运行，Mac 网络代理配置 http、https、socks、例外进行验证
/// - Parameter url 指定URL
/// - Returns: VPN、代理开启状态
+ (JGSProxyOptions)proxyEnabledTypesForURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
