//
//  NSDate+NSString.h
//  OU_iPad
//
//  Created by runs on 2017/8/4.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (NSString)

- (BOOL)isToday;

/**
 获取系统当前时间戳

 @return 单位：秒
 */
- (NSTimeInterval)secondSystemTime;

/**
 获取系统当前时间戳

 @return 单位：毫秒
 */
- (NSTimeInterval)millisecondSystemTime;

/**
 *  从时间戳生成格式化的时间字符串
 *
 *  @param format yyyy-MM-dd HH:mm:ss
 *  @param iValue 1970~now
 *
 *  @return 格式化后的时间字符串
 */

+ (NSString*)timeWithFormat:(NSString*)format timeValue1970:(unsigned long long)iValue;

/**
 将可读时间字符串转成时间戳

 @param format yyyy-MM-dd HH:mm:ss
 @param iValue 2016-08-31 09:46:18
 @return 时间戳
 */
+ (UInt64)dateTimeWithFormat:(NSString*)format timeValue1970:(NSString*)iValue;

/**
 特殊需求 比如聊天两条消息之间的间隔显示

 @param iValue 时间戳
 @return 时间字符串
 */
+ (NSString *)messageIntervalWithTime:(unsigned long long)iValue;

/**
 特殊需求 比如聊天两条消息之间的间隔显示

 @return 时间字符串
 */
- (NSString *)messageInterval;



@end

NS_ASSUME_NONNULL_END
