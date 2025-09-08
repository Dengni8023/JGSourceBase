//
//  JGSBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/1/17.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Availability.h>

// 防止重复导入头文件
#ifndef JGSBase_h
#define JGSBase_h

#if __has_include(<JGSourceBase/JGSBase.h>)
#import <JGSourceBase/JGSBaseUtils.h>
#import <JGSourceBase/JGSFileUtils.h>
#import <JGSourceBase/JGSLogger.h>
#import <JGSourceBase/JGSWeakStrong.h>
#else
#import "JGSBaseUtils.h"
#import "JGSFileUtils.h"
#import "JGSLogger.h"
#import "JGSWeakStrong.h"
#endif

#endif /* JGSBase_h */
