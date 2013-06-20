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
+ (NSDate*) dateFromCurrentDate:(NSDate*)currentDate andDoubleHour:(double)hDouble;
@end
