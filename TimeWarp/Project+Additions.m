//
//  Project+Additions.m
//  TimeWarp
//
//  Created by pat on 30.03.2014.
//  Copyright (c) 2014 zuehlke. All rights reserved.
//

#import "Project+Additions.h"

@implementation Project (ProjectAdditions)

- (NSString*) label
{
    if (self.subname.length == 0) {
        return self.name;
    }
    else {
        return [NSString stringWithFormat:@"%@, %@", self.name, self.subname];
    }
}

- (UIImage*)  imageWithDefaultName:(NSString*)defaultName
{
    if (self.icon) {
        return [UIImage imageNamed:self.icon];
    }
    else {
        return [UIImage imageNamed:defaultName];
    }

}

- (NSString*) projectId
{
    return [[[self objectID] URIRepresentation] absoluteString];
}

@end
