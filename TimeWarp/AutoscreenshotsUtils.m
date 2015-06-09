//
//  AutoscreenshotsUtils.m
//  TimeWarp
//
//  Created by Patrick Jayet on 05/06/15.
//  Copyright (c) 2015 zuehlke. All rights reserved.
//

#import "AutoscreenshotsUtils.h"
#import "TimeUtils.h"

#define SCREENSHOT_DATE @"30-04-2014"


@implementation AutoscreenshotsUtils

+ (NSDate*)dateForScreenshots
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd-MM-yyyy";
    return [formatter dateFromString:SCREENSHOT_DATE];
}

+ (NSDate*)monthlyDateForScreenshots
{
    NSDate *date = [self dateForScreenshots];
    return [TimeUtils monthForDate:date];
}

@end
