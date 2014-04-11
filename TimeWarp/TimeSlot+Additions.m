//
//  TimeSlot+Additions.m
//  TimeWarp
//
//  Created by pat on 11.04.2014.
//  Copyright (c) 2014 zuehlke. All rights reserved.
//

#import "TimeSlot+Additions.h"

@implementation TimeSlot (TimeSlotAdditions)

// in hours
- (double)duration
{
    return [self.end doubleValue] - [self.start doubleValue];
}

@end
