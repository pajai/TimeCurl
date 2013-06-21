//
//  TimeUtils.m
//  TimeWarp
//
//  Created by pat on 20.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "TimeUtils.h"
#import <tgmath.h>


@implementation TimeUtils

+ (NSString*)timeStringFromDouble:(double)hDouble
{
    double hours = floor(hDouble);
    double mins  = (hDouble - hours) * 60;
    return [NSString stringWithFormat:@"%.0f:%02.0f", hours, mins];
}

+ (int)hourFromDouble:(double)hDouble
{
    return (int)floor(hDouble);
}

+ (int)minuteFromDouble:(double)hDouble
{
    double hours = floor(hDouble);
    double mins  = (hDouble - hours) * 60;
    return (int)mins;
}

// return a date for the current date, where the time is set to hDouble
+ (NSDate*) dateForDate:(NSDate*)date andHour:(double)hDouble
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    [components setHour:[TimeUtils hourFromDouble:hDouble]];
    [components setMinute:[TimeUtils minuteFromDouble:hDouble]];
    return [cal dateFromComponents:components];
}

// return a date for the given date, where the time is set to midnight
+ (NSDate*) dayForDate:(NSDate*) date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    return [cal dateFromComponents:components];
}

@end
