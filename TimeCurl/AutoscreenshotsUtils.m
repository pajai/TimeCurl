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
