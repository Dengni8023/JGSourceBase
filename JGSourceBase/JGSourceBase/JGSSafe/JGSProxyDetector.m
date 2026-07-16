//
//  JGSProxyDetector.m
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/25.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import "JGSProxyDetector.h"
#import <CFNetwork/CFNetwork.h>
#import "JGSLogger+Private.h"

@implementation JGSProxyDetector

/// 系统层VPN、网络代理开启状态判断，无法针对特定域名判断
+ (JGSProxyOptions)proxyEnabledTypes {
    // 系统代理设置
    NSDictionary *settings = (__bridge_transfer NSDictionary *)CFNetworkCopySystemProxySettings();
    if (!settings) {
        return kNilOptions;
    }
    JGSDebugLog(@"settings: %@", settings);

    // 网络代理设置
    NSDictionary *proxyTypes = @{
        @"HTTPEnable": @(JGSProxyOptionsHTTP),
        @"HTTPSEnable": @(JGSProxyOptionsHTTPS),
        @"SOCKSEnable": @(JGSProxyOptionsSOCKS),
        @"ProxyAutoConfigEnable": @(JGSProxyOptionsAuto),
    };
    JGSProxyOptions options = kNilOptions;
    for (NSString *key in proxyTypes) {
        id enable = settings[key];
        if ([enable isKindOfClass:[NSNumber class]] && [enable isEqual:@(1)]) {
            options |= [proxyTypes[key] integerValue];
        }
    }

    // VPN设置
    // 当 VPN 连接时，系统会创建一个虚拟网络接口（如 tun0、utun1），这个接口信息会出现在 __SCOPED__ 字典中
    NSDictionary *scopeSettings = settings[@"__SCOPED__"];
    if ([scopeSettings isKindOfClass:[NSDictionary class]]) {
        // VPN 接口关键词：VPN 连接会创建虚拟网络接口，其名称通常包含以下关键词
        // tap / tun：最常见的 VPN 隧道接口
        // ppp：点对点协议，用于某些 VPN 类型
        // ipsec：IPsec VPN 协议
        // utun：用户态 tun 接口，在较新的 iOS 系统中被广泛使用
        NSArray<NSString *> *vpnKeys = @[@"tap", @"tun", @"ppp", @"ipsec", @"utun"];
        BOOL vpnDetected = NO;
        for (NSString *vpnKey in vpnKeys) {
            for (NSString *scopeKey in scopeSettings.allKeys) {
                if ([scopeKey hasPrefix:vpnKey]) {
                    vpnDetected = YES;
                    break;
                }
            }
            if (vpnDetected) break;
        }
        if (vpnDetected) {
            options |= JGSProxyOptionsVPN;
        }
    }

    JGSDebugLog(@"enableTypes: %zd", options);
    return options;
}

/// 系统层VPN开启状态判断（不针对特定URL）、特定URL的网络代理配置
+ (JGSProxyOptions)proxyEnabledTypesFor:(NSString *)url {
    NSURL *URL = [NSURL URLWithString:url];
    if (!URL) {
        return [self proxyEnabledTypes];
    }
    return [self proxyEnabledTypesForURL:URL];
}

/// 系统层VPN开启状态判断（不针对特定URL）、特定URL的网络代理配置
+ (JGSProxyOptions)proxyEnabledTypesForURL:(NSURL *)url {
    // 系统代理设置
    CFDictionaryRef cfSettings = CFNetworkCopySystemProxySettings();
    if (!cfSettings) {
        return kNilOptions;
    }

    NSArray *proxies = (__bridge_transfer NSArray *)CFNetworkCopyProxiesForURL((__bridge CFURLRef)url, cfSettings);
    NSDictionary *settings = (__bridge_transfer NSDictionary *)cfSettings;
    JGSDebugLog(@"settings: %@", settings);
    JGSDebugLog(@"proxies for %@ : %@", url, proxies);
    
    // 提取代理类型
    NSMutableSet *urlProxyTypes = [NSMutableSet set];
    for (NSDictionary *proxy in proxies) {
        if ([proxy isKindOfClass:[NSDictionary class]]) {
            NSString *type = proxy[(__bridge NSString *)kCFProxyTypeKey];
            if (type) {
                [urlProxyTypes addObject:type];
            }
        }
    }

    // 网络代理设置
    NSDictionary *proxyTypes = @{
        (__bridge NSString *)kCFProxyTypeHTTP: @(JGSProxyOptionsHTTP),
        (__bridge NSString *)kCFProxyTypeHTTPS: @(JGSProxyOptionsHTTPS),
        (__bridge NSString *)kCFProxyTypeSOCKS: @(JGSProxyOptionsSOCKS),
        (__bridge NSString *)kCFProxyTypeAutoConfigurationURL: @(JGSProxyOptionsAuto),
    };
    JGSProxyOptions options = kNilOptions;
    for (NSString *key in proxyTypes) {
        if ([urlProxyTypes containsObject:key]) {
            options |= [proxyTypes[key] integerValue];
        }
    }

    // VPN设置
    // 当 VPN 连接时，系统会创建一个虚拟网络接口（如 tun0、utun1），这个接口信息会出现在 __SCOPED__ 字典中
    NSDictionary *scopeSettings = settings[@"__SCOPED__"];
    if ([scopeSettings isKindOfClass:[NSDictionary class]]) {
        // VPN 接口关键词
        NSArray<NSString *> *vpnKeys = @[@"tap", @"tun", @"ppp", @"ipsec", @"utun"];
        BOOL vpnDetected = NO;
        for (NSString *vpnKey in vpnKeys) {
            for (NSString *scopeKey in scopeSettings.allKeys) {
                if ([scopeKey hasPrefix:vpnKey]) {
                    vpnDetected = YES;
                    break;
                }
            }
            if (vpnDetected) break;
        }
        if (vpnDetected) {
            options |= JGSProxyOptionsVPN;
        }
    }

    JGSDebugLog(@"enableTypes for %@ : %zd", url, options);
    return options;
}

@end
