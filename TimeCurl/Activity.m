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

#import "Activity.h"
#import "Project.h"
#import "TimeSlot.h"


@implementation Activity

@dynamic date;
@dynamic note;
@dynamic project;
@dynamic timeslots;

// transient property
- (NSString*)day
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    return [dateFormatter stringFromDate:self.date];
}

@end
