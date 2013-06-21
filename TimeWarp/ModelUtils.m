//
//  ModelUtils.m
//  TimeWarp
//
//  Created by pat on 20.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "ModelUtils.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "TimeUtils.h"


@implementation ModelUtils

+ (NSArray*) fetchAllProjects
{
    NSManagedObjectContext* managedObjectContext = [ModelUtils context];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error = nil;
    NSArray* result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if ([ModelUtils logError:error withMessage:@"fetch all projects"]) {
        return nil;
    }
    else {
        return result;
    }
}

+ (NSArray*) fetchAllActivities
{
    NSLog(@"Fetch all activities");
    
    NSManagedObjectContext* managedObjectContext = [ModelUtils context];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error = nil;
    NSArray* result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if ([ModelUtils logError:error withMessage:@"fetch all activities"]) {
        return nil;
    }
    else {
        return result;
    }
}

+ (NSArray*) fetchActivitiesForDate:(NSDate*) date
{
    NSLog(@"Fetch activities for %@", date);
    
    NSManagedObjectContext* managedObjectContext = [ModelUtils context];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSDate* day      = [TimeUtils dayForDate:date];
    NSDate* dayAfter = [day dateByAddingTimeInterval:3600*24];
    // TODO perhaps not the most efficient query
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ANY self.timeslots.start >= %@ AND ANY self.timeslots.start < %@", day, dayAfter];
    [fetchRequest setPredicate:predicate];
    
    NSError* error = nil;
    NSArray* result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([ModelUtils logError:error withMessage:@"fetch all activities"]) {
        return nil;
    }
    else {
        return result;
    }
}

+ (Project*) newProject
{
    NSManagedObjectContext* managedObjectContext = [ModelUtils context];
    return [NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:managedObjectContext];
}

+ (Activity*) newActivity
{
    NSManagedObjectContext* managedObjectContext = [ModelUtils context];
    return [NSEntityDescription insertNewObjectForEntityForName:@"Activity" inManagedObjectContext:managedObjectContext];
}

+ (TimeSlot*) newTimeSlot
{
    NSManagedObjectContext* managedObjectContext = [ModelUtils context];
    return [NSEntityDescription insertNewObjectForEntityForName:@"TimeSlot" inManagedObjectContext:managedObjectContext];
}

+ (void) saveContext
{
    NSError* error = nil;
    if (![[ModelUtils context] save:&error]) {
        NSLog(@"Error happened while creating project: %@", [error localizedDescription]);
    }
    
}

+ (NSManagedObjectContext*) context
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

+ (BOOL) logError:(NSError*)error withMessage:(NSString*)msg {
    if (error != nil) {
        NSLog(@"Error - %@: %@, %@", msg, [error localizedDescription], [error userInfo]);
        return YES;
    }
    else {
        return NO;
    }
}
@end
