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

#import "Activity+Additions.h"
#import "TimeSlot+Additions.h"

@implementation Activity (ActivityAdditions)

// in hours
- (double)duration
{
    double d = 0.0;
    for (TimeSlot* timeSlot in self.timeslots) {
        d += timeSlot.duration;
    }
    return d;
}

- (NSString*)formattedDuration
{
    return [NSString stringWithFormat:@"%.2f", [self duration]];
}

@end
