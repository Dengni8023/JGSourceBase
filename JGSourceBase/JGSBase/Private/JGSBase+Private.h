//
//  JGSBase+Private.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/6/7.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#if __has_include(<JGSourceBase/JGSBase.h>)
#import <JGSourceBase/JGSBase.h>
#import <JGSourceBase/JGSourceBase-Swift.h>
#import <JGSourceBase/JGSLogger+Private.h>
#else
#import "JGSBase.h"
#import "JGSourceBase-Swift"
#import "JGSLogger+Private.h"
#endif

NS_ASSUME_NONNULL_BEGIN

// 临时存储文件路径文件夹
FOUNDATION_EXTERN NSString * const JGSTemporaryFileSavedDirectory(void);
// 永久存储文件路径文件夹
FOUNDATION_EXTERN NSString * const JGSPermanentFileSavedDirectory(void);

NS_ASSUME_NONNULL_END
