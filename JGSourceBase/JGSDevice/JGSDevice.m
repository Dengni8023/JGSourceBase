//
//  JGSDevice.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSDevice.h"
#import "JGSBase+JGSPrivate.h"
#import "JGSCategory+NSData.h"
#import <WebKit/WebKit.h>
#import <AdSupport/ASIdentifierManager.h>
#import <AppTrackingTransparency/ATTrackingManager.h>
#import <sys/utsname.h>
#import <sys/stat.h>
#import <dlfcn.h>

// IP地址
#import <arpa/inet.h>
#import <net/if.h>
#import <ifaddrs.h>

#define JGS_IOS_NET_CELLULAR    @"pdp_ip0"
#define JGS_IOS_NET_WIFI        @"en0"
#define JGS_IOS_NET_VPN         @"utun0"
#define JGS_IP_ADDR_IPv4        @"ipv4"
#define JGS_IP_ADDR_IPv6        @"ipv6"

@implementation JGSDevice

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadSystemUserAgen:nil];
    });
}

#pragma mark - APP
+ (NSDictionary *)appInfo {
    
    static NSDictionary *appInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appInfo = @{
            @"bundleId": [self bundleId],
            @"appVersion": [self appVersion],
            @"buildNumber": [self buildNumber]
        };
    });
    return appInfo;
}

+ (NSString *)bundleId {
    
    static NSString *bundleId = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    });
    return bundleId;
}

+ (NSString *)appVersion {
    
    static NSString *appVersion = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"1.0.0";
    });
    return appVersion;
}

+ (NSString *)buildNumber {
    
    static NSString *buildNumber = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] ?: @"1";
    });
    return buildNumber;
}

#pragma mark - UA
+ (void)loadSystemUserAgen:(void (^ _Nullable)(NSString * _Nullable sysUA, NSError * _Nullable error))completion {
    
    // 异步获取系统UA
    static NSString *fakeUserAgent = nil;
    static NSString *sysUserAgent = nil;
    static WKWebView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 为了避免没有获取到oldAgent，所以设置一个默认的userAgent
        // Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148
        // Mozilla/5.0 (iPhone; CPU iPhone OS 14_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148
        // Mozilla/5.0 (iPad; CPU OS 14_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148
        NSString *model = [[UIDevice currentDevice] model];
        NSString *os = [model isEqualToString:@"iPhone"] ? @"CPU iPhone OS" : @"CPU OS";
        NSString *osVersion = [[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        fakeUserAgent = [NSString stringWithFormat:@"Mozilla/5.0 (%@; %@ %@ like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", model, os, osVersion];
        // 去除开头结尾的空格、换行
        fakeUserAgent = [fakeUserAgent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        // 去除多空格
        fakeUserAgent = [fakeUserAgent stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        
        // 三种方式系统采用的优先级：customUserAgent > UserDefault > applicationNameForUserAgent
        // 左侧优先级高于右侧
        // 如果设置了customUserAgent或UserDefaults方法，则applicationNameForUserAgent将被忽略。
        // applicationNameForUserAgent仅添加到了webview具有的默认UserAgent中。
        // https://www.jianshu.com/p/50246a8aaddb
        
        JGSPrivateLog(@"默认 UserAgent Load");
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.allowsInlineMediaPlayback = YES;
        config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
        instance = instance ?: [[WKWebView alloc] initWithFrame:CGRectZero configuration:config]; // 此处必须使用存储属性，否则JS执行可能失败
        [instance evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
            JGSPrivateLog(@"默认 UserAgent: %@, %@", result, error);
            if ([result isKindOfClass:[NSString class]] && [(NSString *)result length] > 0) {
                sysUserAgent = (NSString *)result;
                
                // 去除开头结尾的空格、换行
                sysUserAgent = [sysUserAgent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                // 去除多空格
                sysUserAgent = [sysUserAgent stringByReplacingOccurrencesOfString:@"  " withString:@" "];
            }
            
            if (sysUserAgent.length == 0) {
                onceToken = 0;
            } else {
                // 释放内存，避免获取成功后占用内存，可通过Safari开发调试工具检查内存是否释放
                instance = nil;
            }
            
            JGSPrivateLog(@"fakeUA: %@", fakeUserAgent);
            JGSPrivateLog(@"sys UA: %@", sysUserAgent);
        }];
    });
    
    if (completion) {
        completion(sysUserAgent ?: fakeUserAgent, nil);
    }
}

+ (NSString *)sysUserAgent {
    
    __block NSString *sysUserAgent = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    [self loadSystemUserAgen:^(NSString * _Nullable sysUA, NSError * _Nullable error) {
        dispatch_semaphore_signal(semaphore);   //发送信号
        sysUserAgent = sysUA;
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);  //等待
    
    return sysUserAgent;
}

+ (NSString *)appUserAgent {
    
    static NSString *appUA = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *bids = [[self bundleId] componentsSeparatedByString:@"."];
        NSString *org = bids.count > 1 ? bids[1] : bids.firstObject;
        NSString *processName = [NSProcessInfo processInfo].processName;
        appUA = [NSString stringWithFormat:@"%@/%@ (Version %@; Build %@)", org.uppercaseString, processName, [self appVersion], [self buildNumber]];
        appUA = [NSString stringWithFormat:@"%@ %s", appUA, JGSUserAgent];
        
        // 去除开头结尾的空格、换行
        appUA = [appUA stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        // 去除多空格
        appUA = [appUA stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    });
    return appUA;
}

#pragma mark - Device
+ (NSDictionary<NSString *,id> *)deviceInfo {
    
    static NSDictionary *deviceInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL isFullScreen = [self isFullScreen];
        UIEdgeInsets insets = [self safeAreaInsets];
        deviceInfo = @{
            @"device": @{
                @"id": [self deviceId],
            },
            @"edgeInsets": @{
                @"top": @(isFullScreen ? MAX(MAX(insets.top, insets.bottom), MAX(insets.left, insets.right)) : 20),
                @"left": @(0),
                @"bottom": @(isFullScreen ? 34 : 0),
                @"right": @(0),
            },
            @"constant": @{
                @"navigationBarHeight": @(44),
                @"tabBarHeight": @(49),
            },
        };
    });
    
    return deviceInfo;
}

+ (UIEdgeInsets)safeAreaInsets {
    
    static UIEdgeInsets instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (@available(iOS 11.0, *)) {
            // keyWindow有时候会获取不到
            instance = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets;
        } else {
            instance = UIEdgeInsetsZero;
        }
    });
    return instance;
}

+ (NSString *)idfa {
    
    if ([self isSimulator]) {
        return nil;
    }
    
    static NSString *deviceIDFA = nil;
    if (deviceIDFA.length > 0) {
        return deviceIDFA;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        deviceIDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        
        // iOS14获取idfa需要申请权限，否则其他系统权限发生变化时，获取的idfa也会变化
        if (@available(iOS 14.0, *)) {
            // Privacy - Tracking Usage Description
            NSString *trackDes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSUserTrackingUsageDescription"];
            if (trackDes.length > 0 && [ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusNotDetermined) {
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); // 创建信号量
                // iOS 15及以后在applicationDidBecomeActive之前，request弹窗不显示
                [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                    deviceIDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
                    dispatch_semaphore_signal(semaphore); // 发送信号
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);  // 等待
            }
        }
        
        if ([deviceIDFA hasPrefix:@"00000000"]) {
            // 在 iOS 10.0 以后，当用户开启限制广告跟踪，advertisingIdentifier 的值将是全零
            // 00000000-0000-0000-0000-000000000000
            deviceIDFA = nil;
        }
    });
    
    if (deviceIDFA.length == 0) {
        if (@available(iOS 14.0, *)) {
            NSString *trackDes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSUserTrackingUsageDescription"];
            if (trackDes.length > 0 && [ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusNotDetermined) {
                // idfa无效时保证下次能够再次进入request弹窗逻辑
                // 因iOS 15及以后在applicationDidBecomeActive之前，request弹窗不显示
                onceToken = 0;
            }
        }
    }
    
    return deviceIDFA;
}

+ (NSString *)deviceId {
    
    static NSString *deviceId = nil;
    if (deviceId.length > 0) {
        JGSPrivateLog(@"getDeviceId DeviceId Cached: %@", deviceId);
        return deviceId;
    }
    
    // 业务系统规则要求多样，此处不再读取存储内容
    // iOS14其他权限变化时会导致idfa变化，因此做存储
    //NSString *keychainDeviceIdKey = @"JGSourceBaseDeviceId";
    //deviceId = [JGSKeychainUtils readFromKeychain:keychainDeviceIdKey];
    //if (deviceId.length > 0) {
    //    JGSPrivateLog(@"getDeviceId DeviceId Stored: %@", deviceId);
    //    return deviceId;
    //}
    
    // 获取idfa，idfa获取失败则使用idfv，idfv也获取失败，则使用随机UUID
    deviceId = [self idfa];
    JGSPrivateLog(@"getDeviceId DeviceId idfa: %@", deviceId);
    
    if (deviceId.length == 0) {
        // idfv
        deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        JGSPrivateLog(@"getDeviceId DeviceId idfv: %@", deviceId);
    }
    
    if (deviceId.length == 0) {
        
        // 如果idfa、idfv均未取到，则使用随机UUID，随机UUID获取一次后存储KeyChain
        deviceId = [[NSUUID UUID] UUIDString];
        JGSPrivateLog(@"getDeviceId DeviceId uuid: %@", deviceId);
    }
    
    // 业务系统规则要求多样，此处不再存储
    //[JGSKeychainUtils saveToKeychain:deviceId forKey:keychainDeviceIdKey];
    return deviceId;
}

+ (NSString *)systemName {
    // 获取iphone手机的操作系统名称
    return [[UIDevice currentDevice] systemName];
}

+ (NSString *)systemVersion {
    // 获取iphone手机的系统版本号
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)localizedModel {
    // 获取iphone手机的localizedModel
    return ([[UIDevice currentDevice] localizedModel]);
}

+ (NSString *)deviceName {
    // 获取iphone手机的自定义名称
    return ([[UIDevice currentDevice] name]);
}


+ (NSString *)deviceMachine {
    
    static NSString *machine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 获取设备信息（设备类型及版本号）
        struct utsname systemInfo;
        uname( &systemInfo );
        
        machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        if ([self isSimulator] || [machine isEqualToString:@"i386"] || [machine isEqualToString: @"x86_64"]) {
            
            NSString *deviceType = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"iPad" : @"iPhone";
            machine = [NSString stringWithFormat:@"%@ Simulator (%@)", deviceType, machine];
        }
    });
    
    return machine;
}

+ (NSDictionary<NSString *, NSString *> *)decryptedJGSDeviceListFile:(NSData *)fileData fileName:(NSString *)fileName {
    
    if (fileData.length == 0) {
        return nil;
    }
    
    NSDictionary *deviceNamesByCode = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:fileData options:kNilOptions error:nil];
    if (![deviceNamesByCode isKindOfClass:[NSDictionary class]] || deviceNamesByCode.count == 0) {
        
        // AES 256 解密, 解密方式, key, iv 与 JGCommandLineDemo/main.m 文件 - aes256EncryptData:fileName: 保持一致
        size_t keyLen = kCCKeySizeAES256;
        size_t blockSize = kCCBlockSizeAES128;
        
        NSString *key = fileName;
        while (key.length < keyLen) {
            key = [key stringByAppendingString:key];
        }
        
        NSString *iv = [key substringFromIndex:key.length - blockSize];
        key = [key substringToIndex:keyLen];
        
        fileData = [fileData jg_AES256DecryptWithKey:key iv:iv];
        deviceNamesByCode = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:fileData options:kNilOptions error:nil];
    }
    
    // 当前运行设备信息，参考 JGSiOSDeviceList.json
    NSDictionary *deviceInfo = [deviceNamesByCode isKindOfClass:[NSDictionary class]] ? [deviceNamesByCode objectForKey:[self deviceMachine]] : nil;
    return deviceInfo;
}

+ (NSString *)deviceModel {
    
    static NSDictionary<NSString *, NSString *> *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *fileName = @"JGSiOSDeviceList.json.sec";
        NSString *savedPath = [JGSPermanentFileSavedDirectory() stringByAppendingPathComponent:fileName];
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:[JGSBaseUtils fileInResourceBundle:fileName] ofType:nil];
        NSString *path = [[NSFileManager defaultManager] fileExistsAtPath:savedPath] ? savedPath : bundlePath;
        
        // 当前运行设备信息，参考 JGSiOSDeviceList.json
        NSData *jsonData = [NSData dataWithContentsOfFile:path];
        NSDictionary *deviceInfo = [self decryptedJGSDeviceListFile:jsonData fileName:fileName];
        instance = [deviceInfo isKindOfClass:[NSDictionary class]] ? deviceInfo : nil;
        JGSPrivateLog(@"device info: %@", instance);
    });
    
    NSString *deviceModel = instance ? [instance objectForKey:@"Generation"] : [self deviceMachine];
    
    return deviceModel;
}

+ (NSString *)ipAddress:(BOOL)preferIPv4 {
    
    NSMutableDictionary *addressesInfo = @{}.mutableCopy;
    struct ifaddrs *interfaces;
    if (!getifaddrs(&interfaces)) {
        struct ifaddrs *interface;
        for (interface = interfaces; interface; interface = interface->ifa_next) {
            if (!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN)];
            if (addr && (addr->sin_family == AF_INET || addr->sin_family == AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if (addr->sin_family == AF_INET) {
                    if (inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = JGS_IP_ADDR_IPv4;
                    }
                }
                else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if (inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = JGS_IP_ADDR_IPv6;
                    }
                }
                if (type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addressesInfo[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        freeifaddrs(interfaces);
    }
    
    NSArray<NSString *> *netType = @[JGS_IOS_NET_WIFI, JGS_IOS_NET_CELLULAR, JGS_IOS_NET_VPN];
    NSArray<NSString *> *ipType = preferIPv4 ? @[JGS_IP_ADDR_IPv4] : @[JGS_IP_ADDR_IPv6, JGS_IP_ADDR_IPv4];
    NSMutableArray *searchArray = @[].mutableCopy;
    [netType enumerateObjectsUsingBlock:^(NSString * _Nonnull net, NSUInteger idx, BOOL * _Nonnull stop) {
        [ipType enumerateObjectsUsingBlock:^(NSString * _Nonnull ip, NSUInteger idx, BOOL * _Nonnull stop) {
            [searchArray addObject:[NSString stringWithFormat:@"%@/%@", net, ip]];
        }];
    }];
    
    //JGSPrivateLog(@"addresses: %@", addressesInfo);
    NSString *ipAddress = nil;
    for (NSString *key in searchArray) {
        ipAddress = addressesInfo[key];
        if (ipAddress.length > 0) {
            break;
        }
    }
    
    return ipAddress ?: @"127.0.0.1";
}

+ (NSString *)macAddress {
    return @"02:00:00:00:00:00";
}

+ (BOOL)isFullScreen {
    
    static BOOL isFull = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        UIEdgeInsets insets = [self safeAreaInsets];
        isFull = ((insets.top > 0 && insets.bottom > 0) || (insets.left > 0 && insets.right > 0));
    });
    return isFull;
}

+ (BOOL)systemVersionBelow:(NSString *)cmp {
    
    NSProcessInfo *processInfo = NSProcessInfo.processInfo;
    if ([processInfo respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        
        NSArray<NSString *> *cmpVersionStr = [cmp componentsSeparatedByString:@"."];
        NSOperatingSystemVersion cmpInfo = {0, 0, 0};
        cmpInfo.majorVersion = [[cmpVersionStr firstObject] integerValue];
        if (cmpVersionStr.count > 1) {
            
            cmpInfo.minorVersion = [[cmpVersionStr objectAtIndex:1] integerValue];
        }
        else if (cmpVersionStr.count > 2) {
            
            cmpInfo.patchVersion = [[cmpVersionStr objectAtIndex:2] integerValue];
        }
        
        BOOL result = [NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:cmpInfo];
        return !result;
    }
    else {
        
        BOOL result = ([[[UIDevice currentDevice] systemVersion] compare:cmp options:NSNumericSearch] == NSOrderedAscending);
        return result;
    }
}

#pragma mark - NetworkStatus
+ (BOOL)networkReachable {
    return [[JGSReachability sharedInstance] reachable];
}

+ (JGSReachabilityStatus)reachabilityStatus {
    return [[JGSReachability sharedInstance] reachabilityStatus];
}

+ (NSString *)reachabilityStatusString {
    return [[JGSReachability sharedInstance] reachabilityStatusString];
}

#pragma mark - 越狱检测
+ (BOOL)isSimulator {
#if TARGET_OS_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

+ (BOOL)isAPPResigned:(NSArray<NSString *> *)teamIDs {
    
    // 检测plist文件
    NSDictionary *plistDict = [[NSBundle mainBundle] infoDictionary];
    if ([plistDict objectForKey: @"SignerIdentity"] != nil) {
        // 存在这个key，则说明被二次打包了
        return YES;
    }
    
    // 重签名检测
    NSString *embeddedPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"]; // 描述文件路径
    if (![[NSFileManager defaultManager] fileExistsAtPath:embeddedPath]) {
        return YES;
    }
    
    // 读取application-identifier
    NSString *embeddedProvisioning = [NSString stringWithContentsOfFile:embeddedPath encoding:NSASCIIStringEncoding error:nil];
    NSArray<NSString *> *provisioningLines = [embeddedProvisioning componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSInteger fullIdentifierLine = NSNotFound;
    for (NSInteger i = 0; i < provisioningLines.count; i++) {
        NSString *lineStr = [[provisioningLines objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([lineStr isEqualToString:@"<key>application-identifier</key>"]) {
            fullIdentifierLine =  i + 1;
            break;
        }
    }
    
    if (fullIdentifierLine == NSNotFound || fullIdentifierLine >= provisioningLines.count) {
        return YES;
    }
    
    NSString *fullIdentifier = [provisioningLines objectAtIndex:fullIdentifierLine];
    fullIdentifier = [fullIdentifier stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    fullIdentifier = [fullIdentifier stringByReplacingOccurrencesOfString:@"<string>" withString:@""];
    fullIdentifier = [fullIdentifier stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
    
    JGSPrivateLog(@"%@", fullIdentifier);
    NSString *teamId = [fullIdentifier componentsSeparatedByString:@"."].firstObject;
    if (![teamIDs containsObject:teamId]) {
        return YES;
    }
    
    if (teamId.length + 1 >= fullIdentifier.length) {
        return YES;
    }
    
    NSString *bundleId = [fullIdentifier substringFromIndex:teamId.length + 1];
    if (![bundleId isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
        if (![bundleId isEqualToString:@"*"]) {
            return YES;
        }
    }
    return NO;
}

+ (JGSDeviceJailbroken)isDeviceJailbroken {
    
    /*
     参考：https://www.jianshu.com/p/a3fc10c70a29
     上述越狱检查总结如下：
     不要用NSFileManager，这是最容易被hook掉的。
     检测方法中所用到的函数尽可能用底层的C，如文件检测用stat函数(iPod7.0，越狱机检测越狱常见的会安装的文件只能检测到此步骤，下面的检测不出来)
     再进一步，就是检测stat是否出自系统库
     再进一步，就是检测链接动态库(尽量不要，appStore可能审核不过)
     再进一步，检测程序运行的环境变量
     链接：https://www.jianshu.com/p/a3fc10c70a29
     */
    
    // 可执行文件路径
    NSString *execPath = [[NSBundle mainBundle] executablePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:execPath]) {
        return JGSDeviceJailbrokenIsBroken;
    }
    
    // 目录是否有写入权限
    @try {
        CFUUIDRef puuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, puuid);
        NSString *deviceId = (NSString *)CFBridgingRelease(uuidString);
        CFRelease(puuid);
        NSString *path = [NSString stringWithFormat:@"/private/%@", deviceId];
        if ([@"Write Test" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            return JGSDeviceJailbrokenIsBroken;
        }
    }
    @catch (NSException *exception) {
        JGSPrivateLogE(@"%@", exception);
    }
    
    // 检测plist文件
    NSDictionary *plistDict = [[NSBundle mainBundle] infoDictionary];
    if (plistDict.count == 0) {
        return JGSDeviceJailbrokenIsBroken;
    }
    
    // 使用NSFileManager判断设备是否安装了如下越狱常用工具
    NSArray<NSString *> *checkPath = @[
        @"/Applications/Cydia.app",
        @"/Applications/Icy.app",
        @"/Applications/IntelliScreen.app",
        @"/Applications/RockApp.app",
        @"/Applications/SBSettings.app",
        @"/Applications/MxTube.app",
        @"/Applications/WinterBoard.app",
        @"/bin/bash",
        @"/etc/apt",
        @"/etc/clutch.conf",
        @"/etc/clutch_cracked.plist",
        @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
        @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/private/var/lib/apt",
        @"/private/var/lib/apt/",
        @"/private/var/lib/cydia",
        @"/private/var/stash",
        @"/private/var/tmp/cydia.log",
        @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
        @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
        @"/usr/bin/sshd",
        @"/usr/libexec/sftp-server",
        @"/usr/sbin/sshd",
        @"/var/cache/clutch.plist",
        @"/var/cache/clutch_cracked.plist",
        @"/var/lib/clutch/overdrive.dylib",
        @"/var/root/Documents/Cracked/"
    ];
    for (NSString *path in checkPath) {
        //if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        //    return JGSDeviceJailbrokenIsBroken;
        //}
        
        // 攻击者可能会hook NSFileManager 的方法
        // 回避 NSFileManager，使用stat系列函数检测Cydia等工具
        @try {
            struct stat stat_info;
            if (stat(path.UTF8String, &stat_info) == 0) {
                return JGSDeviceJailbrokenIsBroken;
            }
        } @catch (NSException *exception) {
            JGSPrivateLogE(@"%@", exception);
        }
    }
    
    // Symbolic Link Check
    // 尝试读取下应用列表，看看有无权限获取
    @try {
        // See if the Applications folder is a symbolic link
        struct stat stat_info;
        if (lstat("/Applications", &stat_info) != 0 && stat_info.st_mode & S_IFLNK) {
            return JGSDeviceJailbrokenIsBroken;
        }
    }
    @catch (NSException *exception) {
        JGSPrivateLogE(@"%@", exception);
    }
    
    // 看看stat是不是出自系统库，有没有被攻击者换掉
    @try {
        int statCheck;
        Dl_info dylib_info;
        int (*func_stat)(const char *, struct stat *) = stat;
        if ((statCheck = dladdr(func_stat, &dylib_info))) {
            NSString *path = [NSString stringWithUTF8String:dylib_info.dli_fname];
            if (![path isEqualToString:@"/usr/lib/system/libsystem_kernel.dylib"]) {
                return JGSDeviceJailbrokenIsBroken;
            }
        }
    } @catch (NSException *exception) {
        JGSPrivateLogE(@"%@", exception);
    }
    
    // 检测当前程序运行的环境变量
    // Xcode13开始，在使用部分系统库/三方库/SDK时，调试状态该接口获取到的环境变量可能不为空
    // 因此此处屏蔽检测，不同项目根据实际情况自行处理
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (@available(iOS 15.0, *)) {
#ifndef DEBUG
        if (env != NULL) {
            return JGSDeviceJailbrokenIsBroken;
        }
#endif
    } else if (env != NULL) {
        return JGSDeviceJailbrokenIsBroken;
    }
    
    return JGSDeviceJailbrokenNone;
}

#pragma mark - End

@end
