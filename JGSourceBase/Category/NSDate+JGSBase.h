//
//  NSDate+JGSBase.h
//  
//
//  Created by 梅继高 on 2019/6/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (JGSBase)

@property (nonatomic, assign, readonly) NSInteger jg_year; // 年
@property (nonatomic, assign, readonly) NSInteger jg_month; // 月 1~12
@property (nonatomic, assign, readonly) NSInteger jg_day; // 日 1~31
@property (nonatomic, assign, readonly) NSInteger jg_hour; // 时 0~23
@property (nonatomic, assign, readonly) NSInteger jg_minute; // 分 0~59
@property (nonatomic, assign, readonly) NSInteger jg_second; // 秒 0~59
@property (nonatomic, assign, readonly) NSInteger jg_nanosecond; // 纳秒
@property (nonatomic, assign, readonly) NSInteger jg_weekday; // 周几 1~7，第一天根据系统设置确定
@property (nonatomic, assign, readonly) NSInteger jg_weekdayOrdinal; // 工作日序号
@property (nonatomic, assign, readonly) NSInteger jg_weekOfMonth; // 月的第几周 1~5
@property (nonatomic, assign, readonly) NSInteger jg_weekOfYear; // 年的第几周 1~53
@property (nonatomic, assign, readonly) NSInteger jg_yearForWeekOfYear; //
@property (nonatomic, assign, readonly) NSInteger jg_quarter; // 季度
@property (nonatomic, assign, readonly) BOOL jg_isLeapMonth; // 闰月
@property (nonatomic, assign, readonly) BOOL jg_isLeapYear; // 闰年
@property (nonatomic, assign, readonly) BOOL jg_isToday; // 今天
@property (nonatomic, assign, readonly) BOOL jg_isYesterday; // 昨天
@property (nonatomic, assign, readonly) BOOL jg_isTomorrow; // 明天

#pragma mark - Modify
- (nullable NSDate *)jg_dateByAddingYears:(NSInteger)years;
- (nullable NSDate *)jg_dateByAddingMonths:(NSInteger)months;
- (nullable NSDate *)jg_dateByAddingWeeks:(NSInteger)weeks;
- (nullable NSDate *)jg_dateByAddingDays:(NSInteger)days;
- (nullable NSDate *)jg_dateByAddingHours:(NSInteger)hours;
- (nullable NSDate *)jg_dateByAddingMinutes:(NSInteger)minutes;
- (nullable NSDate *)jg_dateByAddingSeconds:(NSInteger)seconds;

- (nullable NSDate *)jg_dateByAdding:(NSInteger)value unit:(NSCalendarUnit)unit;

#pragma mark - Format
+ (nullable instancetype)jg_dateWithString:(NSString *)dateString format:(NSString *)format;
+ (nullable instancetype)jg_dateWithString:(NSString *)dateString format:(NSString *)format timeZone:(nullable NSTimeZone *)timeZone local:(nullable NSLocale *)locale;

- (nullable NSString *)jg_stringWithFormat:(NSString *)format;
- (nullable NSString *)jg_stringWithFormat:(NSString *)format timeZone:(nullable NSTimeZone *)timeZone local:(nullable NSLocale *)locale;

@end

NS_ASSUME_NONNULL_END
