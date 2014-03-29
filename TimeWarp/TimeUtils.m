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

// return a month start date for the given date, where the time is set to midnight
+ (NSDate*) monthForDate:(NSDate*) date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
    return [cal dateFromComponents:components];
}

+ (NSDate*) decrementYearForDate:(NSDate*) date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents* minusOneMonth = [[NSDateComponents alloc] init];
    [minusOneMonth setYear:-1];
    
    return [cal dateByAddingComponents:minusOneMonth toDate:date options:0];
}

+ (NSDate*) incrementYearForDate:(NSDate*) date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents* minusOneMonth = [[NSDateComponents alloc] init];
    [minusOneMonth setYear:1];
    
    return [cal dateByAddingComponents:minusOneMonth toDate:date options:0];
}

+ (NSDate*) decrementMonthForDate:(NSDate*) date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents* minusOneMonth = [[NSDateComponents alloc] init];
    [minusOneMonth setMonth:-1];
    
    return [cal dateByAddingComponents:minusOneMonth toDate:date options:0];
}

+ (NSDate*) incrementMonthForDate:(NSDate*) date
{
    NSCalendar *cal = [NSCalendar currentCalendar];

    NSDateComponents* oneMonth = [[NSDateComponents alloc] init];
    [oneMonth setMonth:1];

    return [cal dateByAddingComponents:oneMonth toDate:date options:0];
}

@end
