//
//  JGSCategory.h
//  JGSCategory
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#ifndef JGSCategory_h
#define JGSCategory_h

#import <Foundation/Foundation.h>

#if __has_include(<JGSourceBase/JGSCategory.h>)
#import <JGSourceBase/JGSCategory+NSArray.h> // NSArray
#import <JGSourceBase/JGSCategory+NSData.h> // NSData
#import <JGSourceBase/JGSCategory+NSDate.h> // NSDate
#import <JGSourceBase/JGSCategory+NSDictionary.h> // NSDictionary
#import <JGSourceBase/JGSCategory+NSObject.h> // NSObject
#import <JGSourceBase/JGSCategory+NSString.h> // NSString
#import <JGSourceBase/JGSCategory+NSURL.h> // NSURL
#import <JGSourceBase/JGSCategory+UIAlertController.h> // UIAlertController
#import <JGSourceBase/JGSCategory+UIApplication.h> // UIApplication
#import <JGSourceBase/JGSCategory+UIColor.h> // UIColor
#import <JGSourceBase/JGSCategory+UIImage.h> // UIImage
#else
#import "JGSCategory+NSArray.h" // NSArray
#import "JGSCategory+NSData.h" // NSData
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

#endif /* JGSCategory_h */
