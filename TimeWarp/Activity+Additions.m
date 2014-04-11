//
//  Activity+Additions.m
//  TimeWarp
//
//  Created by pat on 11.04.2014.
//  Copyright (c) 2014 zuehlke. All rights reserved.
//

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
