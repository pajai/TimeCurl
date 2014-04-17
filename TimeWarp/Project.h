//
//  Project.h
//  TimeWarp
//
//  Created by pat on 17.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Activity;

@interface Project : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * subname;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSSet *activities;
@end

@interface Project (CoreDataGeneratedAccessors)

- (void)addActivitiesObject:(Activity *)value;
- (void)removeActivitiesObject:(Activity *)value;
- (void)addActivities:(NSSet *)values;
- (void)removeActivities:(NSSet *)values;

@end
