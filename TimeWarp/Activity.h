//
//  Activity.h
//  TimeWarp
//
//  Created by pat on 17.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Project, TimeSlot;

@interface Activity : NSManagedObject

@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) Project *project;
@property (nonatomic, retain) NSSet *timeslots;
@end

@interface Activity (CoreDataGeneratedAccessors)

- (void)addTimeslotsObject:(TimeSlot *)value;
- (void)removeTimeslotsObject:(TimeSlot *)value;
- (void)addTimeslots:(NSSet *)values;
- (void)removeTimeslots:(NSSet *)values;

- (double)duration;

@end
