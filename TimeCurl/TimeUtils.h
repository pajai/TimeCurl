/*
 
 Copyright (C) 2013-2015, Patrick Jayet
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
*/

#import <Foundation/Foundation.h>

@interface TimeUtils : NSObject
+ (NSString*)timeStringFromDouble:(double)hDouble;
+ (int)hourFromDouble:(double)hDouble;
+ (int)minuteFromDouble:(double)hDouble;

// return a date for the current date, where the time is set to hDouble
+ (NSDate*) dateForDate:(NSDate*)date andHour:(double)hDouble;

// return a date for the given date, where the time is set to midnight
+ (NSDate*) dayForDate:(NSDate*) date;

// return a month start date for the given date, where the time is set to midnight
+ (NSDate*) monthForDate:(NSDate*) date;

+ (NSDate*) decrementMonthForDate:(NSDate*) date;
+ (NSDate*) incrementMonthForDate:(NSDate*) date;
+ (NSDate*) decrementYearForDate:(NSDate*) date;
+ (NSDate*) incrementYearForDate:(NSDate*) date;

+ (NSDate*) decrementDate:(NSDate*)date forUnitString:(NSString*)unitString andNb:(NSInteger)nb;
+ (NSDate*) incrementDate:(NSDate*)date forUnitString:(NSString*)unitString andNb:(NSInteger)nb;
+ (NSDateComponents*)dateComponentForUnitString:(NSString*)unitString withNb:(NSInteger)nb;

@end
