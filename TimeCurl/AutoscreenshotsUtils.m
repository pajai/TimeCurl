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
