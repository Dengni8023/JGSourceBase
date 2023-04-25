//
//  NSDate+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/6/14.
//  Copyright © 2019 MeiJiGao. All rights reserved.
//

#import "NSDate+JGSBase.h"

@implementation NSDate (JGSBase)

- (NSCalendar *)jg_calendar {
    return [NSCalendar currentCalendar];
}

- (NSDateComponents *)jg_dateComponentsWithUnit:(NSCalendarUnit)unit {
    return [[self jg_calendar] components:unit fromDate:self];
}

- (NSInteger)jg_year {
    return [self jg_dateComponentsWithUnit:NSCalendarUnitYear].year;
}

- (NSInteger)jg_month {
    return [self jg_dateComponentsWithUnit:NSCalendarUnitMonth].month;
}

- (NSInteger)jg_day {
    return [self jg_dateComponentsWithUnit:NSCalendarUnitDay].day;
}

- (NSInteger)jg_hour {
    return [self jg_dateComponentsWithUnit:NSCalendarUnitHour].hour;
}

- (NSInteger)jg_minute {
    return [self jg_dateComponentsWithUnit:NSCalendarUnitMinute].minute;
}

- (NSInteger)jg_second {
    return [self jg_dateComponentsWithUnit:NSCalendarUnitSecond].second;
}

- (NSInteger)jg_nanosecond {
    return [self jg_dateComponentsWithUnit:NSCalendarUnitNanosecond].nanosecond;
}

- (NSInteger)jg_weekday {
    return [self jg_dateComponentsWithUnit:NSCalendarUnitWeekday].weekday;
}

- (NSInteger)jg_weekdayOrdinal {
    return [self jg_dateComponentsWithUnit:NSCalendarUnitWeekdayOrdinal].weekdayOrdinal;
}

- (NSInteger)jg_weekOfMonth {
    return [self jg_dateComponentsWithUnit:NSCalendarUnitWeekOfMonth].weekOfMonth;
}

- (NSInteger)jg_weekOfYear {
    return [self jg_dateComponentsWithUnit:NSCalendarUnitWeekOfYear].weekOfYear;
}

- (NSInteger)jg_yearForWeekOfYear {
    return [self jg_dateComponentsWithUnit:NSCalendarUnitYearForWeekOfYear].yearForWeekOfYear;
}

- (NSInteger)jg_quarter {
    return [self jg_dateComponentsWithUnit:NSCalendarUnitQuarter].quarter;
}

- (BOOL)jg_isLeapMonth {
    return [self jg_dateComponentsWithUnit:NSCalendarUnitMonth].isLeapMonth;
}

- (BOOL)jg_isLeapYear {
    NSInteger year = self.jg_year;
    // 4年一闰，百年不闰，400又闰
    return ((year % 400 == 0) || ((year % 100 != 0) && (year % 4 == 0)));
}

- (BOOL)jg_isToday {
    return [[self jg_calendar] isDateInToday:self];
}

- (BOOL)jg_isYesterday {
    return [[self jg_calendar] isDateInYesterday:self];
}

- (BOOL)jg_isTomorrow {
    return [[self jg_calendar] isDateInTomorrow:self];
}

#pragma mark - Modify
- (NSDate *)jg_dateByAddingYears:(NSInteger)years {
    return [self jg_dateByAdding:years unit:NSCalendarUnitYear];
}

- (NSDate *)jg_dateByAddingMonths:(NSInteger)months {
    return [self jg_dateByAdding:months unit:NSCalendarUnitMonth];
}

- (NSDate *)jg_dateByAddingWeeks:(NSInteger)weeks {
    return [self jg_dateByAdding:weeks unit:NSCalendarUnitWeekday];
}

- (NSDate *)jg_dateByAddingDays:(NSInteger)days {
    return [self jg_dateByAdding:days unit:NSCalendarUnitDay];
}

- (NSDate *)jg_dateByAddingHours:(NSInteger)hours {
    return [self jg_dateByAdding:hours unit:NSCalendarUnitHour];
}

- (NSDate *)jg_dateByAddingMinutes:(NSInteger)minutes {
    return [self jg_dateByAdding:minutes unit:NSCalendarUnitMinute];
}

- (NSDate *)jg_dateByAddingSeconds:(NSInteger)seconds {
    return [self jg_dateByAdding:seconds unit:NSCalendarUnitSecond];
}

- (NSDate *)jg_dateByAdding:(NSInteger)value unit:(NSCalendarUnit)unit {
    return [[self jg_calendar] dateByAddingUnit:unit value:value toDate:self options:kNilOptions];
}

#pragma mark - End

@end
