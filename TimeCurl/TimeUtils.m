/*
 
 Copyright 2013-2015 Patrick Jayet
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
*/

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
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    [components setHour:[TimeUtils hourFromDouble:hDouble]];
    [components setMinute:[TimeUtils minuteFromDouble:hDouble]];
    return [cal dateFromComponents:components];
}

// return a date for the given date, where the time is set to midnight
+ (NSDate*) dayForDate:(NSDate*) date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    return [cal dateFromComponents:components];
}

// return a month start date for the given date, where the time is set to midnight
+ (NSDate*) monthForDate:(NSDate*) date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth) fromDate:date];
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

+ (NSDate*) decrementDate:(NSDate*)date forUnitString:(NSString*)unitString andNb:(NSInteger)nb
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents* dateComponents = [self dateComponentForUnitString:unitString withNb:-1 * nb];
    return [cal dateByAddingComponents:dateComponents toDate:date options:0];
}

+ (NSDate*) incrementDate:(NSDate*)date forUnitString:(NSString*)unitString andNb:(NSInteger)nb
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents* dateComponents = [self dateComponentForUnitString:unitString withNb:nb];
    return [cal dateByAddingComponents:dateComponents toDate:date options:0];
}

+ (NSDateComponents*)dateComponentForUnitString:(NSString*)unitString withNb:(NSInteger)nb
{
    NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    
    if ([unitString isEqualToString:@"day"]) {
        [dateComponents setDay:nb];
    }
    else if ([unitString isEqualToString:@"week"]) {
        [dateComponents setWeekOfYear:nb];
    }
    else /* month */ {
        [dateComponents setMonth:nb];
    }
    return dateComponents;
}

@end
