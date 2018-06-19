//
//  NSDate+NSString.m
//  OU_iPad
//
//  Created by runs on 2017/8/4.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "NSDate+NSString.h"

@implementation NSDate (NSString)

- (BOOL)isToday {
    NSString *today = [self.class timeWithFormat:@"yyyy-MM-dd" timeValue1970:NSDate.date.timeIntervalSince1970];
    NSString *selfDay = [self.class timeWithFormat:@"yyyy-MM-dd" timeValue1970:self.timeIntervalSince1970];
    return [today isEqualToString:selfDay];
}

+ (NSTimeInterval)secondSystemTime {
    return time(NULL);
}

- (NSTimeInterval)millisecondSystemTime {
    return self.timeIntervalSince1970 * 1000;
}

+ (NSDate *)buildDate {
    NSString *buildDate = [NSString stringWithFormat:@"%s %s",__DATE__, __TIME__];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"MM dd yyyy HH:mm:ss";
    NSDate *date = [dateFormatter dateFromString:buildDate];
    return date;
}

- (NSString *)timeWithFormat:(nonnull NSString*)format {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}

+ (nonnull NSString*)timeWithFormat:(nonnull NSString*)format timeValue1970:(unsigned long long)iValue {
    NSDate * detaildate = [NSDate dateWithTimeIntervalSince1970:iValue];
    return [detaildate timeWithFormat:format];
}

+ (UInt64)dateTimeWithFormat:(nonnull NSString*)format timeValue1970:(nonnull NSString*)iValue {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:iValue];
    return (UInt64)[date timeIntervalSince1970];
}

- (NSString *)messageInterval {
    NSDate *today = [NSDate date];
    NSDate * yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400];//24*60*60
    NSString * todayString = [today.description substringToIndex:10];
    NSString * yesterdayString = [yesterday.description substringToIndex:10];
    NSString * refDateString = [self.description substringToIndex:10];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if ([refDateString isEqualToString:todayString]) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    } else if ([refDateString isEqualToString:yesterdayString]) {
        [dateFormatter setDateFormat:@"昨天 HH:mm:ss"];
    }else {
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    }
    return [dateFormatter stringFromDate:self];
}

+ (NSString *)messageIntervalWithTime:(unsigned long long)iValue {
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:iValue];
    return [date messageInterval];
}
@end
