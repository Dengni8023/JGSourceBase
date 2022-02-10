//
//  JGSDataStorage.h
//  JGSDataStorage
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for JGSDataStorage.
FOUNDATION_EXPORT double JGSDataStorageVersionNumber;

//! Project version string for JGSDataStorage.
FOUNDATION_EXPORT const unsigned char JGSDataStorageVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JGSDataStorage/PublicHeader.h>

#ifndef JGS_DataStorage
#define JGS_DataStorage

#if __has_include(<JGSDataStorage/JGSDataStorage.h>)
#import <JGSDataStorage/JGSKeychainUtils.h>
#import <JGSDataStorage/JGSUserDefaults.h>
#else
#import "JGSKeychainUtils.h"
#import "JGSUserDefaults.h"
#endif

#endif
