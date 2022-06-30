//
//  NSDate+JGSFormat.h
//  JGSourceBase
//
//  Created by 梅继高 on 2021/12/2.
//  Copyright © 2021 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (JGSFormat)

+ (nullable instancetype)jg_dateWithString:(NSString *)dateString format:(NSString *)format;
+ (nullable instancetype)jg_dateWithString:(NSString *)dateString format:(NSString *)format timeZone:(nullable NSTimeZone *)timeZone local:(nullable NSLocale *)locale;

- (nullable NSString *)jg_stringWithFormat:(NSString *)format;
- (nullable NSString *)jg_stringWithFormat:(NSString *)format timeZone:(nullable NSTimeZone *)timeZone local:(nullable NSLocale *)locale;

@end

NS_ASSUME_NONNULL_END
