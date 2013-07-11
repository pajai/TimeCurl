//
//  Activity.m
//  TimeWarp
//
//  Created by pat on 17.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "Activity.h"
#import "Project.h"
#import "TimeSlot.h"


@implementation Activity

@dynamic date;
@dynamic note;
@dynamic project;
@dynamic timeslots;

// in hours
- (double)duration
{
    double d = 0.0;
    for (TimeSlot* timeSlot in self.timeslots) {
        d += timeSlot.duration;
    }
    return d;
}

@end
