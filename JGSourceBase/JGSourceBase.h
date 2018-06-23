//
//  JGSourceBase.h
//  JGSourceBase
//
//  Created by Mei Jigao on 2017/11/24.
//  Copyright © 2017年 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for JGSourceBase.
FOUNDATION_EXPORT double JGSourceBaseVersionNumber;

//! Project version string for JGSourceBase.
FOUNDATION_EXPORT const unsigned char JGSourceBaseVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JGSourceBase/PublicHeader.h>

// JGSC 缩写说明
// JG: 作者
// SC: Source Code

#if __has_include(<JGSourceBase/JGSourceBase.h>)

// Common
#import <JGSourceBase/JGSCCommon.h>
#import <JGSourceBase/NSDictionary+JGSCEasyUse.h>
#import <JGSourceBase/NSString+JGSCURL.h>
#import <JGSourceBase/NSURL+JGSCURLQuery.h>

// NSObject
#ifdef JGSC_NSObject
#import <JGSourceBase/NSObject+JGSCJSON.h>
#import <JGSourceBase/NSObject+JGSCObject2Dict.h>
#endif

#else

// Common
#import "JGSCCommon.h"
#import "NSDictionary+JGSCEasyUse.h"
#import "NSString+JGSCURL.h"
#import "NSURL+JGSCURLQuery.h"

// NSObject
#ifdef JGSC_NSObject
#import "NSObject+JGSCJSON.h"
#import "NSObject+JGSCObject2Dict.h"
#endif

#endif
