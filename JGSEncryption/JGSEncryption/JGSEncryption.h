//
//  JGSEncryption.h
//  JGSEncryption
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for JGSEncryption.
FOUNDATION_EXPORT double JGSEncryptionVersionNumber;

//! Project version string for JGSEncryption.
FOUNDATION_EXPORT const unsigned char JGSEncryptionVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JGSEncryption/PublicHeader.h>

#ifndef JGS_Encryption
#define JGS_Encryption

#if __has_include(<JGSEncryption/JGSEncryption.h>)
#import <JGSEncryption/JGSAESEncryption.h>
#import <JGSEncryption/JGSCommonEncryption.h>
#import <JGSEncryption/JGSRSAEncryption.h>
#else
#import "JGSAESEncryption.h"
#import "JGSCommonEncryption.h"
#import "JGSRSAEncryption.h"
#endif

#endif
