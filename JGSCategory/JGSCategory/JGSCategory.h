//
//  JGSCategory.h
//  JGSCategory
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for JGSCategory.
FOUNDATION_EXPORT double JGSCategoryVersionNumber;

//! Project version string for JGSCategory.
FOUNDATION_EXPORT const unsigned char JGSCategoryVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JGSCategory/PublicHeader.h>

#ifndef JGS_Category
#define JGS_Category

#if __has_include(<JGSCategory/JGSCategory.h>)
#import <JGSCategory/JGSCategory+NSDate.h> // NSDate
#import <JGSCategory/JGSCategory+NSDictionary.h> // NSDictionary
#import <JGSCategory/JGSCategory+NSObject.h> // NSObject
#import <JGSCategory/JGSCategory+NSString.h> // NSString
#import <JGSCategory/JGSCategory+NSURL.h> // NSURL
#import <JGSCategory/JGSCategory+UIAlertController.h> // UIAlertController
#import <JGSCategory/JGSCategory+UIApplication.h> // UIApplication
#import <JGSCategory/JGSCategory+UIColor.h> // UIColor
#import <JGSCategory/JGSCategory+UIImage.h> // UIImage
#else
#import "JGSCategory+NSDate.h" // NSDate
#import "JGSCategory+NSDictionary.h" // NSDictionary
#import "JGSCategory+NSObject.h" // NSObject
#import "JGSCategory+NSString.h" // NSString
#import "JGSCategory+NSURL.h" // NSURL
#import "JGSCategory+UIAlertController.h" // UIAlertController
#import "JGSCategory+UIApplication.h" // UIApplication
#import "JGSCategory+UIColor.h" // UIColor
#import "JGSCategory+UIImage.h" // UIImage
#endif

#endif
