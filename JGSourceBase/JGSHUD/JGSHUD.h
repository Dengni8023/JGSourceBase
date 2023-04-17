//
//  JGSHUD.h
//  JGSHUD
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#ifndef JGSHUD_h
#define JGSHUD_h

// Loading
#if __has_include(<JGSourceBase/JGSLoadingHUD.h>)
#import <JGSourceBase/JGSLoadingHUD.h>
#elif __has_include("JGSLoadingHUD.h")
#import "JGSLoadingHUD.h"
#endif

// HUD
#if __has_include(<JGSourceBase/JGSToast.h>)
#import <JGSourceBase/JGSToast.h>
#elif __has_include("JGSToast.h")
#import "JGSToast.h"
#endif

#endif /* JGSHUD_h */
