//
//  JGSHUD.h
//  JGSHUD
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for JGSHUD.
FOUNDATION_EXPORT double JGSHUDVersionNumber;

//! Project version string for JGSHUD.
FOUNDATION_EXPORT const unsigned char JGSHUDVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JGSHUD/PublicHeader.h>

#ifndef JGS_HUD
#define JGS_HUD

#if __has_include(<JGSHUD/JGSHUD.h>)
#import <JGSHUD/JGSLoadingHUD.h>
#import <JGSHUD/JGSToast.h>
#else
#import "JGSLoadingHUD.h"
#import "JGSToast.h"
#endif

#endif