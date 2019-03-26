//
//  JGSourceBase.h
//  JGSourceBase
//
//  Created by Mei Jigao on 2017/11/24.
//  Copyright © 2017年 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Availability.h>

// 最低版本限制处理
#if __ENVIRONMENT_IPHONE_OS_VERSION_MIN_REQUIRED__ < __IPHONE_9_0
#error "JGSourceBase uses features only available in iOS SDK 9.0 and later."
#endif

//! Project version number for JGSourceBase.
FOUNDATION_EXPORT double JGSourceBaseVersionNumber;

//! Project version string for JGSourceBase.
FOUNDATION_EXPORT const unsigned char JGSourceBaseVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JGSourceBase/PublicHeader.h>

// JGS 缩写说明
// JG: 作者
// S: SourceCode

#if __has_include(<JGSourceBase/JGSourceBase.h>)

#import <JGSourceBase/JGSBase.h>
#ifdef JGS_AlertController
#import <JGSourceBase/JGSAlertController.h> // JGSAlertController
#endif
#ifdef JGS_Reachability
#import <JGSourceBase/JGSReachability.h> // JGSReachability
#endif
#ifdef JGS_LoadingHUD
#import <JGSourceBase/JGSLoadingHUD.h> // JGSLoadingHUD
#endif
#ifdef JGS_Toast
#import <JGSourceBase/JGSToast.h> // JGSToast
#endif

#else

#import "JGSBase.h"
#ifdef JGS_AlertController
#import "JGSAlertController.h" // JGSAlertController
#endif
#ifdef JGS_Reachability
#import "JGSReachability.h" // JGSReachability
#endif
#ifdef JGS_LoadingHUD
#import "JGSLoadingHUD.h" // JGSLoadingHUD
#endif
#ifdef JGS_Toast
#import "JGSToast.h" // JGSToast
#endif

#endif
