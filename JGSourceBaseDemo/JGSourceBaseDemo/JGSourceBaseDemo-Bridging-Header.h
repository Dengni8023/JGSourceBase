//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Availability.h>

// 最低版本限制处理
#if __ENVIRONMENT_IPHONE_OS_VERSION_MIN_REQUIRED__ < __IPHONE_11_0
#error "JGSourceBase uses features only available in iOS SDK 11.0 and later."
#endif

// Xcode最低版本要求
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 150000
#error "JGSourceBase needs Xcode 13 (support for iOS 15.0) or later."
#endif

// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.

#if __has_include(<JGSourceBase/JGSourceBase.h>)
#import <JGSourceBase/JGSourceBase.h>
#elif __has_include("JGSourceBase.h")
#import "JGSourceBase.h"
#else

// Base
#if __has_include(<JGSourceBase/JGSBase.h>)
#import <JGSourceBase/JGSBase.h>
#elif __has_include("JGSBase.h")
#import "JGSBase.h"
#endif

// Category
#if __has_include(<JGSourceBase/JGSCategory.h>)
#import <JGSourceBase/JGSCategory.h>
#elif __has_include("JGSCategory.h")
#import "JGSCategory.h"
#else

#if __has_include(<JGSourceBase/JGSCategory+NSDate.h>)
#import <JGSourceBase/JGSCategory+NSDate.h>
#elif __has_include("JGSCategory+NSDate.h")
#import "JGSCategory+NSDate.h"
#endif

#if __has_include(<JGSourceBase/JGSCategory+NSDictionary.h>)
#import <JGSourceBase/JGSCategory+NSDictionary.h>
#elif __has_include("JGSCategory+NSDictionary.h")
#import "JGSCategory+NSDictionary.h"
#endif

#if __has_include(<JGSourceBase/JGSCategory+NSObject.h>)
#import <JGSourceBase/JGSCategory+NSObject.h>
#elif __has_include("JGSCategory+NSObject.h")
#import "JGSCategory+NSObject.h"
#endif

#if __has_include(<JGSourceBase/JGSCategory+NSString.h>)
#import <JGSourceBase/JGSCategory+NSString.h>
#elif __has_include("JGSCategory+NSString.h")
#import "JGSCategory+NSString.h"
#endif

#if __has_include(<JGSourceBase/JGSCategory+NSURL.h>)
#import <JGSourceBase/JGSCategory+NSURL.h>
#elif __has_include("JGSCategory+NSURL.h")
#import "JGSCategory+NSURL.h"
#endif

#if __has_include(<JGSourceBase/JGSCategory+UIAlertController.h>)
#import <JGSourceBase/JGSCategory+UIAlertController.h>
#elif __has_include("JGSCategory+UIAlertController.h")
#import "JGSCategory+UIAlertController.h"
#endif

#if __has_include(<JGSourceBase/JGSCategory+UIApplication.h>)
#import <JGSourceBase/JGSCategory+UIApplication.h>
#elif __has_include("JGSCategory+UIApplication.h")
#import "JGSCategory+UIApplication.h"
#endif

#if __has_include(<JGSourceBase/JGSCategory+UIColor.h>)
#import <JGSourceBase/JGSCategory+UIColor.h>
#elif __has_include("JGSCategory+UIColor.h")
#import "JGSCategory+UIColor.h"
#endif

#if __has_include(<JGSourceBase/JGSCategory+UIImage.h>)
#import <JGSourceBase/JGSCategory+UIImage.h>
#elif __has_include("JGSCategory+UIImage.h")
#import "JGSCategory+UIImage.h"
#endif

#endif

// DataStorage
#if __has_include(<JGSourceBase/JGSDataStorage.h>)
#import <JGSourceBase/JGSDataStorage.h>
#elif __has_include("JGSDataStorage.h")
#import "JGSDataStorage.h"
#endif

// Device
#if __has_include(<JGSourceBase/JGSDevice.h>)
#import <JGSourceBase/JGSDevice.h>
#elif __has_include("JGSDevice.h")
#import "JGSDevice.h"
#endif

// Encryption
#if __has_include(<JGSourceBase/JGSEncryption.h>)
#import <JGSourceBase/JGSEncryption.h>
#elif __has_include("JGSEncryption.h")
#import "JGSEncryption.h"
#endif

// JGSHUD
#if __has_include(<JGSourceBase/JGSHUD.h>)
#import <JGSourceBase/JGSHUD.h>
#elif __has_include("JGSHUD.h")
#import "JGSHUD.h"
#else

#if __has_include(<JGSourceBase/JGSLoadingHUD.h>)
#import <JGSourceBase/JGSLoadingHUD.h>
#elif __has_include("JGSLoadingHUD.h")
#import "JGSLoadingHUD.h"
#endif

#if __has_include(<JGSourceBase/JGSToast.h>)
#import <JGSourceBase/JGSToast.h>
#elif __has_include("JGSToast.h")
#import "JGSToast.h"
#endif

#endif

// JGSIntegrityCheck
#if __has_include(<JGSourceBase/JGSIntegrityCheck.h>)
#import <JGSourceBase/JGSIntegrityCheck.h>
#elif __has_include("JGSIntegrityCheck.h")
#import "JGSIntegrityCheck.h"
#endif

// JGSReachability
#if __has_include(<JGSourceBase/JGSReachability.h>)
#import <JGSourceBase/JGSReachability.h>
#elif __has_include("JGSReachability.h")
#import "JGSReachability.h"
#endif

// JGSSecurityKeyboard
#if __has_include(<JGSourceBase/JGSSecurityKeyboard.h>)
#import <JGSourceBase/JGSSecurityKeyboard.h>
#elif __has_include("JGSSecurityKeyboard.h")
#import "JGSSecurityKeyboard.h"
#endif

#endif

#ifdef JGSCategory_UIColor_h
#define JGSDemoNavigationBarColor JGSColorHexA(0x0B5CDA, 0.82)
#define JGSDemoRadiusGradientCenter JGSColorHex(0xFF3737) // 径向渐变圆心颜色
#define JGSDemoRadiusGradientEnd JGSColorHex(0xFEC054) // 径向渐变结束颜色
#else
#define JGSDemoNavigationBarColor [UIColor colorWithRed:0x0B / 255.f green:0x5C / 255.f blue:0xDA /255.f alpha:1.f]
#define JGSDemoRadiusGradientCenter [UIColor colorWithRed:0xFF / 255.f green:0x37 / 255.f blue:0x37 /255.f alpha:1.f]// 径向渐变圆心颜色
#define JGSDemoRadiusGradientEnd [UIColor colorWithRed:0xFE / 255.f green:0xC0 / 255.f blue:0x54 /255.f alpha:1.f] // 径向渐变结束颜色
#endif

#import "JGSDemoViewController.h"
