//
//  JGSourceBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2019/7/30.
//  Copyright © 2019 MeiJiGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Availability.h>

// 最低版本限制处理
#if __ENVIRONMENT_IPHONE_OS_VERSION_MIN_REQUIRED__ < __IPHONE_11_0
#error "JGSourceBase uses features only available in iOS SDK 11.0 and later."
#endif

//! Project version number for JGSourceBase.
FOUNDATION_EXPORT double JGSourceBaseVersionNumber;

//! Project version string for JGSourceBase.
FOUNDATION_EXPORT const unsigned char JGSourceBaseVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JGSourceBase/PublicHeader.h>

// JGS 缩写说明
// JG: 作者
// S: SourceCode
// 本文件作为公有header，外部使用时可直接import本文件而不需要引入其他头文件即可使用所有引入的subspec功能
// 因此各subspec头文件的引入均使用的头文件能否引用的判断

// Base
#pragma mark - Base
#if __has_include(<JGSourceBase/JGSBase.h>)
#import <JGSourceBase/JGSBase.h>
#endif

// Category
#pragma mark - Category
#if __has_include(<JGSourceBase/JGSCategory.h>)
#import <JGSourceBase/JGSCategory.h>
#endif

// DataStorage
#pragma mark - DataStorage
#if __has_include(<JGSourceBase/JGSDataStorage.h>)
#import <JGSourceBase/JGSDataStorage.h>
#endif

// Device
#pragma mark - Device
#if __has_include(<JGSourceBase/JGSDevice.h>)
#import <JGSourceBase/JGSDevice.h>
#endif

// Encryption
#pragma mark - Encryption
#if __has_include(<JGSourceBase/JGSEncryption.h>)
#import <JGSourceBase/JGSEncryption.h>
#endif

// JGSHUD
#pragma mark - JGSHUD
#if __has_include(<JGSourceBase/JGSHUD.h>)
#import <JGSourceBase/JGSHUD.h>
#endif

// JGSIntegrityCheck.h
#pragma mark - JGSIntegrityCheck
#if __has_include(<JGSourceBase/JGSIntegrityCheck.h>)
#import <JGSourceBase/JGSIntegrityCheck.h>
#endif

// JGSReachability
#pragma mark - JGSReachability
#if __has_include(<JGSourceBase/JGSReachability.h>)
#import <JGSourceBase/JGSReachability.h>
#endif

// JGSSecurityKeyboard
#pragma mark - JGSSecurityKeyboard
#if __has_include(<JGSourceBase/JGSSecurityKeyboard.h>)
#import <JGSourceBase/JGSSecurityKeyboard.h>
#endif
