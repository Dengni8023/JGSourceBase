//
//  JGSourceBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2019/7/30.
//  Copyright © 2019 MeiJigao. All rights reserved.
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
#elif __has_include("JGSBase.h")
#import "JGSBase.h"
#endif

// Category
#pragma mark - Category
#if __has_include(<JGSourceBase/JGSCategory.h>)
#import <JGSourceBase/JGSCategory.h>
#elif __has_include("JGSCategory.h")
#import "JGSCategory.h"
#else

// JGSCategory存在subspec，部分直接引入subspec方式可能导致未引入JGSCategory.h
// NSDate
#if __has_include(<JGSourceBase/JGSCategory+NSDate.h>)
#import <JGSourceBase/JGSCategory+NSDate.h>
#elif __has_include("JGSCategory+NSDate.h")
#import "JGSCategory+NSDate.h"
#endif

// NSDictionary
#if __has_include(<JGSourceBase/JGSCategory+NSDictionary.h>)
#import <JGSourceBase/JGSCategory+NSDictionary.h>
#elif __has_include("JGSCategory+NSDictionary.h")
#import "JGSCategory+NSDictionary.h"
#endif

// NSObject
#if __has_include(<JGSourceBase/JGSCategory+NSObject.h>)
#import <JGSourceBase/JGSCategory+NSObject.h>
#elif __has_include("JGSCategory+NSObject.h")
#import "JGSCategory+NSObject.h"
#endif

// NSString
#if __has_include(<JGSourceBase/JGSCategory+NSString.h>)
#import <JGSourceBase/JGSCategory+NSString.h>
#elif __has_include("JGSCategory+NSString.h")
#import "JGSCategory+NSString.h"
#endif

// NSURL
#if __has_include(<JGSourceBase/JGSCategory+NSURL.h>)
#import <JGSourceBase/JGSCategory+NSURL.h>
#elif __has_include("JGSCategory+NSURL.h")
#import "JGSCategory+NSURL.h"
#endif

// UIAlertController
#if __has_include(<JGSourceBase/JGSCategory+UIAlertController.h>)
#import <JGSourceBase/JGSCategory+UIAlertController.h>
#elif __has_include("JGSCategory+UIAlertController.h")
#import "JGSCategory+UIAlertController.h"
#endif

// UIApplication
#if __has_include(<JGSourceBase/JGSCategory+UIApplication.h>)
#import <JGSourceBase/JGSCategory+UIApplication.h>
#elif __has_include("JGSCategory+UIApplication.h")
#import "JGSCategory+UIApplication.h"
#endif

// UIColor
#if __has_include(<JGSourceBase/JGSCategory+UIColor.h>)
#import <JGSourceBase/JGSCategory+UIColor.h>
#elif __has_include("JGSCategory+UIColor.h")
#import "JGSCategory+UIColor.h"
#endif

// UIImage
#if __has_include(<JGSourceBase/JGSCategory+UIImage.h>)
#import <JGSourceBase/JGSCategory+UIImage.h>
#elif __has_include("JGSCategory+UIImage.h")
#import "JGSCategory+UIImage.h"
#endif

#endif

// DataStorage
#pragma mark - DataStorage
#if __has_include(<JGSourceBase/JGSDataStorage.h>)
#import <JGSourceBase/JGSDataStorage.h>
#elif __has_include("JGSDataStorage.h")
#import "JGSDataStorage.h"
#endif

// Device
#pragma mark - Device
#if __has_include(<JGSourceBase/JGSDevice.h>)
#import <JGSourceBase/JGSDevice.h>
#elif __has_include("JGSDevice.h")
#import "JGSDevice.h"
#endif

// Encryption
#pragma mark - Encryption
#if __has_include(<JGSourceBase/JGSEncryption.h>)
#import <JGSourceBase/JGSEncryption.h>
#elif __has_include("JGSEncryption.h")
#import "JGSEncryption.h"
#endif

// JGSHUD
#pragma mark - JGSHUD
#if __has_include(<JGSourceBase/JGSHUD.h>)
#import <JGSourceBase/JGSHUD.h>
#elif __has_include("JGSHUD.h")
#import "JGSHUD.h"
#else

// JGSHUD存在subspec，部分直接引入subspec方式可能导致未引入JGSHUD.h
// JGSLoadingHUD
#if __has_include(<JGSourceBase/JGSLoadingHUD.h>)
#import <JGSourceBase/JGSLoadingHUD.h>
#elif __has_include("JGSLoadingHUD.h")
#import "JGSLoadingHUD.h"
#endif

// JGSToast
#if __has_include(<JGSourceBase/JGSToast.h>)
#import <JGSourceBase/JGSToast.h>
#elif __has_include("JGSToast.h")
#import "JGSToast.h"
#endif

#endif

// JGSReachability
#pragma mark - JGSReachability
#if __has_include(<JGSourceBase/JGSReachability.h>)
#import <JGSourceBase/JGSReachability.h>
#elif __has_include("JGSReachability.h")
#import "JGSReachability.h"
#endif

// JGSSecurityKeyboard
#pragma mark - JGSSecurityKeyboard
#if __has_include(<JGSourceBase/JGSSecurityKeyboard.h>)
#import <JGSourceBase/JGSSecurityKeyboard.h>
#elif __has_include("JGSSecurityKeyboard.h")
#import "JGSSecurityKeyboard.h"
#endif
