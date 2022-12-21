//
//  JGSBase.h
//  JGSBase
//
//  Created by 梅继高 on 2022/1/17.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Availability.h>

// 最低版本限制处理
#if __ENVIRONMENT_IPHONE_OS_VERSION_MIN_REQUIRED__ < __IPHONE_11_0
#error "JGSourceBase uses features only available in iOS 11.0 and later."
#endif

// Xcode最低版本要求
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 150000
#error "JGSourceBase needs Xcode 13 (support for iOS 15.0) or later."
#endif

#ifndef JGSBase_h
#define JGSBase_h

#if __has_include(<JGSourceBase/JGSBase.h>)
#import <JGSourceBase/JGSBaseUtils.h>
#import <JGSourceBase/JGSFileUtils.h>
#import <JGSourceBase/JGSLogFunction.h>
#import <JGSourceBase/JGSWeakStrong.h>
#else
#import "JGSBaseUtils.h"
#import "JGSFileUtils.h"
#import "JGSLogFunction.h"
#import "JGSWeakStrong.h"
#endif

#endif /* JGSBase_h */
