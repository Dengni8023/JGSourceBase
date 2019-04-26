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

// In this header, you should import all the public headers of your framework using statements like #import <JGSourceBase/PublicHeader.h>

// JGS 缩写说明
// JG: 作者
// S: SourceCode

#if __has_include(<JGSourceBase/JGSourceBase.h>)

#import <JGSourceBase/JGSBase.h>
#import <JGSourceBase/JGSAlertController.h>
#import <JGSourceBase/JGSCategory.h>
// JGSReachability
#ifdef JGS_Reachability
#import <JGSourceBase/JGSReachability.h>
#endif
// JGSHUD
#ifdef JGS_HUD
#import <JGSourceBase/JGSHUD.h>
#endif

#else

#import "JGSBase.h"
#import "JGSAlertController.h"
#import "JGSCategory.h"
// JGSReachability
#ifdef JGS_Reachability
#import "JGSReachability.h"
#endif
// JGSToast
#ifdef JGS_HUD
#import "JGSHUD.h"
#endif

#endif
