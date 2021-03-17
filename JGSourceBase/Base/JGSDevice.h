//
//  JGSDevice.h
//  JGSourceBase
//
//  Created by 梅继高 on 2021/3/16.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// SHA256(name) -> value
typedef NS_ENUM(uint, JGSDeviceJailbroken) {
    JGSDeviceJailbrokenNone = 'None',
    JGSDeviceJailbrokenIsBroken = 'Brok',
};

@interface JGSDevice : NSObject

#pragma mark - APP
+ (NSDictionary *)appInfo;
+ (NSString *)bundleId; // 商店版本
+ (NSString *)appVersion; // 商店版本
+ (NSString *)buildNumber; // iOS build
+ (NSString *)appUserAgent; // 携带了版本等信息的 UserAgent

#pragma mark - Device
+ (NSDictionary<NSString *, id> *)deviceInfo;

+ (NSString *)idfa; //获取IDFA广告标示
+ (NSString *)deviceId; //获取iphone手机的设备编号
+ (NSString *)systemName; //获取iphone手机的操作系统名称
+ (NSString *)systemVersion; //获取iphone手机的系统版本号
+ (NSString *)localizedModel; //获取iphone手机的localizedModel
+ (NSString *)deviceName; //获取iphone手机的自定义名称
+ (NSString *)deviceMachine; //获取设备信息（设备类型及版本号）
+ (NSString *)deviceModel; //获取iphone手机的Model

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
