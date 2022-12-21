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

// Xcode最低版本要求
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_16_0
#error "JGSourceBase needs Xcode 13.0 or later."
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

#if __has_include(<JGSourceBase/JGSourceBase.h>)
#import <JGSourceBase/JGSBase.h> // Base
#import <JGSourceBase/JGSCategory.h> // Category
#import <JGSourceBase/JGSDataStorage.h> // DataStorage
#import <JGSourceBase/JGSDevice.h> // Device
#import <JGSourceBase/JGSEncryption.h> // Encryption
#import <JGSourceBase/JGSIntegrityCheck.h> // IntegrityCheck
#import <JGSourceBase/JGSReachability.h> // Reachability
#import <JGSourceBase/JGSSecurityKeyboard.h> // SecurityKeyboard
#else
#import "JGSBase.h" // Base
#import "JGSCategory.h" // Category
#import "JGSDataStorage.h" // DataStorage
#import "JGSDevice.h" // Device
#import "JGSEncryption.h" // Encryption
#import "JGSIntegrityCheck.h" // IntegrityCheck
#import "JGSReachability.h" // Reachability
#import "JGSSecurityKeyboard.h" // SecurityKeyboard
#endif

// HUD
#if __has_include(<JGSourceBase/JGSHUD.h>)
#import <JGSourceBase/JGSHUD.h>
#elif __has_include("JGSHUD.h")
#import "JGSHUD.h"
#endif
