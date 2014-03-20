//
//  ModelSerializer.h
//  TimeWarp
//
//  Created by pat on 20.03.2014.
//  Copyright (c) 2014 zuehlke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelSerializer : NSObject

- (NSData*) serializeProjects:(NSArray*)projects;

@end
