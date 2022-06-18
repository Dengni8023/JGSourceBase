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
#error "JGSourceBase uses features only available in iOS SDK 11.0 and later."
#endif

#ifndef JGSBase_h
#define JGSBase_h

#if __has_include(<JGSourceBase/JGSBase.h>)
#import <JGSourceBase/JGSBaseUtils.h>
#import <JGSourceBase/JGSLogFunction.h>
#import <JGSourceBase/JGSWeakStrong.h>
#else
#import "JGSBaseUtils.h"
#import "JGSLogFunction.h"
#import "JGSWeakStrong.h"
#endif

#endif /* JGSBase_h */
