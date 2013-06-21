//
//  TimeUtils.h
//  TimeWarp
//
//  Created by pat on 20.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeUtils : NSObject
+ (NSString*)timeStringFromDouble:(double)hDouble;
+ (int)hourFromDouble:(double)hDouble;
+ (int)minuteFromDouble:(double)hDouble;

// return a date for the current date, where the time is set to hDouble
+ (NSDate*) dateForDate:(NSDate*)date andHour:(double)hDouble;

// return a date for the given date, where the time is set to midnight
+ (NSDate*) dayForDate:(NSDate*) date;
@end
