//
//  JGSBase.h
//  JGSBase
//
//  Created by 梅继高 on 2022/1/17.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Availability.h>

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
