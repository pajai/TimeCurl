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
    return [NSString stringWithFormat:@"%02.0f:%02.0f", hours, mins];
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

+ (NSDate*) dateFromCurrentDate:(NSDate*)currentDate andDoubleHour:(double)hDouble
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:currentDate];
    [components setHour:[TimeUtils hourFromDouble:hDouble]];
    [components setMinute:[TimeUtils minuteFromDouble:hDouble]];
    return [cal dateFromComponents:components];
}

@end
