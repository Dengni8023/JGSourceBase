//
//  JGSDevice.h
//  JGSourceBase
//
//  Created by 梅继高 on 2021/3/16.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(uint, JGSDeviceJailbroken) {
    JGSDeviceJailbrokenNone = 'None',
    JGSDeviceJailbrokenIsBroken = 'Brok',
};

@interface JGSDevice : NSObject

#pragma mark - APP
/** 获取APP信息， 示例：
 {
     "bundleId": com.xxxx.xxxx,
     "appVersion": 1.0.0,
     "buildNumber": 20210813
 }
 */
+ (NSDictionary *)appInfo;
/// 应用Bundle ID
+ (NSString *)bundleId;
/// 应用version版本号，对应Android VersionName
+ (NSString *)appVersion;
/// 应用build构建号，对应Android VersionCode
+ (NSString *)buildNumber;

/// 系统默认的UserAgent，请勿在应用启动直接调用，启动时调用请注意增加适当延时，约大于0.2秒
+ (NSString *)sysUserAgent;
/// 包含APP版本信息的自定义UserAgent内容，不包含系统UserAgent
+ (NSString *)appUserAgent;

#pragma mark - Device
/**
 * 应用设备相关信息，示例
 {
     "device":  {
             "id": xxxxxxxxxxxxxx,
     },
     "edgeInsets": {
             "top": 20,
             "left": 0,
             "bottom": 34,
             "right": 0,
     },
     "constant": @{
             "navigationBarHeight": 44,
             "tabBarHeight": 49,
     },
 }
 */
+ (NSDictionary<NSString *, id> *)deviceInfo;

/// 获取IDFA广告标示
/// 如在Info中设置了 NSUserTrackingUsageDescription 字段，请不要在应用启动 application:didFinishLaunchingWithOptions 方法中直接调用，以免跟踪弹窗无法弹出导致卡死
/// 如必须在应用启动 application:didFinishLaunchingWithOptions 方法中直接调用，请使用异步/或延时处理（延时可为0）
+ (nullable NSString *)idfa;
/// 获取iphone手机的设备编号
+ (NSString *)deviceId;
/// 获取iphone手机的操作系统名称
+ (NSString *)systemName;
/// 获取iphone手机的系统版本号
+ (NSString *)systemVersion;
/// 获取iphone手机的localizedModel
+ (NSString *)localizedModel;
/// 获取iphone手机的自定义名称
+ (NSString *)deviceName;
/// 获取设备信息（设备类型及版本号）
+ (NSString *)deviceMachine;
/// 获取iphone手机的Model
+ (NSString *)deviceModel;

+ (NSString *)ipAddress:(BOOL)preferIPv4; // 获取设备IP地址
+ (NSString *)macAddress DEPRECATED_MSG_ATTRIBUTE("iOS 7之后禁止获取设备Mac地址，所有设备返回相同值");

+ (UIEdgeInsets)safeAreaInsets; // safeAreaInsets
+ (BOOL)isFullScreen; // 刘海屏（全面屏）判断
+ (BOOL)systemVersionBelow:(NSString *)cmp; // 判断手机系统版本是否低于某个版本

#pragma mark - 越狱检测
+ (BOOL)isSimulator;

/// 判断APP是否重签名，可用于企业包检测防止重签名
/// APP Store生产环境必定会重签名，请勿使用
+ (BOOL)isAPPResigned:(NSArray<NSString *> *)teamIDs;

/// 防止方法拦截，与常规越狱方法名区别命名，返回值不使用true/false、YES/NO、0/1
/// 写成Bool 方式去检查 ，容易被攻击者hook
+ (JGSDeviceJailbroken)isDeviceJailbroken;

@end

NS_ASSUME_NONNULL_END
