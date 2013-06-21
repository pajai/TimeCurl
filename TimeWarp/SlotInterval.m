//
//  DoublePair.m
//  TimeWarp
//
//  Created by pat on 20.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "SlotInterval.h"
#import "TimeUtils.h"

@implementation SlotInterval

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@-%@",
                     [TimeUtils timeStringFromDouble:self.begin],
                     [TimeUtils timeStringFromDouble:self.end]];

}

@end
