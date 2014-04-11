//
//  Activity+Additions.h
//  TimeWarp
//
//  Created by pat on 11.04.2014.
//  Copyright (c) 2014 zuehlke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Activity.h"

@interface Activity (ActivityAdditions)

- (double)duration;
- (NSString*)formattedDuration;

@end
