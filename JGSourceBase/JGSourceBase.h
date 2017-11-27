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

#if __has_include(<JGSourceBase/JGSourceCommon.h>)
#import <JGSourceBase/JGSourceCommon.h>
#import <JGSourceBase/JGSourceResource.h>
#else
#import "JGSourceCommon.h"
#import "JGSourceResource.h"
#endif
