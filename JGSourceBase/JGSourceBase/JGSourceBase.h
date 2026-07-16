//
//  JGSourceBase.h
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/17.
//  Copyright © 2026 ByMountains. All rights reserved.
//

// JGS 缩写说明
// JG: 作者
// S: SourceCode
// 本文件作为公有header，外部使用时可直接import本文件而不需要引入其他头文件即可使用所有引入的subspec功能
// 因此各subspec头文件的引入均使用的头文件能否引用的判断

#import <Availability.h>

// 最低iOS版本限制
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_13_0
#error "JGSourceBase uses features only available in iOS SDK 13.0 and later."
#endif

// Xcode最低版本要求
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_26_0
#error "JGSourceBase needs Xcode 26.0 or later."
#endif

#ifndef JGSourceBase_h
#define JGSourceBase_h

// Base
#if __has_include(<JGSourceBase/JGSBase.h>)
#import <JGSourceBase/JGSBase.h>
#elif __has_include("JGSBase.h")
//#else
#import "JGSBase.h"
#endif

// Category
#if __has_include(<JGSourceBase/JGSCategory.h>)
#import <JGSourceBase/JGSCategory.h>
#elif __has_include("JGSCategory.h")
//#else
#import "JGSCategory.h"
#endif

// Device

// Reachability
#if __has_include(<JGSourceBase/JGSReachability.h>)
#import <JGSourceBase/JGSReachability.h>
#elif __has_include("JGSReachability.h")
//#else
#import "JGSReachability.h"
#endif

// Safe
#if __has_include(<JGSourceBase/JGSSafe.h>)
#import <JGSourceBase/JGSSafe.h>
#elif __has_include("JGSSafe.h")
//#else
#import "JGSSafe.h"
#endif

/// 获取组件版本
FOUNDATION_EXTERN NSString *JGSourceBaseVersion(void);

#endif /* JGSourceBase_h */
