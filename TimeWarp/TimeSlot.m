//
//  TimeSlot.m
//  TimeWarp
//
//  Created by pat on 17.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "TimeSlot.h"
#import "Activity.h"


@implementation TimeSlot

@dynamic start;
@dynamic end;
@dynamic activity;

// in hours
- (double)duration
{
    return [self.end timeIntervalSinceDate:self.start] / 3600;
}

@end
