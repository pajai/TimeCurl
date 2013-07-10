//
//  ModelUtils.h
//  TimeWarp
//
//  Created by pat on 20.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Project.h"
#import "Activity.h"
#import "TimeSlot.h"

@interface ModelUtils : NSObject

+ (NSArray*) fetchAllProjects;
+ (NSArray*) fetchAllActivities;
+ (NSArray*) fetchActivitiesForDate:(NSDate*) date;
+ (NSArray*) fetchActivitiesByDayForMonth:(NSDate*) date;

+ (Project*) newProject;
+ (Activity*) newActivity;
+ (TimeSlot*) newTimeSlot;

+ (void) saveContext;
+ (void) deleteObject:(id)obj;

+ (NSManagedObjectContext*) context;
+ (BOOL) logError:(NSError*)error withMessage:(NSString*)msg;

@end
