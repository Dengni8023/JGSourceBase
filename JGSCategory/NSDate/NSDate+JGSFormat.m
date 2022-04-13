//
//  NSDate+JGSFormat.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/12/2.
//  Copyright © 2021 MeiJiGao. All rights reserved.
//

#import "NSDate+JGSFormat.h"

@implementation NSDate (JGSFormat)

#pragma mark - Format
+ (NSDateFormatter *)jg_dateFormatter {
    
    static NSDateFormatter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSDateFormatter alloc] init];
    });
    return instance;
}

+ (instancetype)jg_dateWithString:(NSString *)dateString format:(NSString *)format {
    return [self jg_dateWithString:dateString format:format timeZone:nil local:nil];
}

+ (instancetype)jg_dateWithString:(NSString *)dateString format:(NSString *)format timeZone:(NSTimeZone *)timeZone local:(NSLocale *)locale {
    
    NSDateFormatter *formatter = [self jg_dateFormatter];
    [formatter setDateFormat:format];
    [formatter setTimeZone:timeZone];
    [formatter setLocale:locale];
    
    return [formatter dateFromString:dateString];
}

- (NSString *)jg_stringWithFormat:(NSString *)format {
    return [self jg_stringWithFormat:format timeZone:nil local:nil];
}

- (NSString *)jg_stringWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone local:(NSLocale *)locale {
    
    NSDateFormatter *formatter = [self.class jg_dateFormatter];
    [formatter setDateFormat:format];
    [formatter setTimeZone:timeZone];
    [formatter setLocale:locale];
    
    return [formatter stringFromDate:self];
}

#pragma mark - End

@end
