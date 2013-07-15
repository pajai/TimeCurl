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

+ (instancetype)shared
{
    static ModelUtils *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (sharedInstance == nil){
            sharedInstance = [[ModelUtils alloc] init];
        }
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // initialization
    }
    return self;
}

#pragma mark needed for CoreData

- (NSManagedObjectContext*) managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel*) managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator*) persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [[self applicationDocumentsDirectory]    URLByAppendingPathComponent:@"TimeWarp.sqlite"]; //actual SDK style for blank db
    NSLog(@"app dir: ---%@---", [self applicationDocumentsDirectory]);
    NSLog(@"store url: ---%@---", storeUrl);
    
    NSError* error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary* options = @{NSPersistentStoreUbiquitousContentNameKey: @"",
                              NSPersistentStoreUbiquitousContentURLKey:  @""};
    //(NSPersistentStoreUbiquitousContentNameKey,NSPersistentStoreUbiquitousContentURLKey)
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        NSLog(@"Error during store creation: %@, %@", [error localizedDescription], [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark utility methods

- (NSArray*) fetchAllProjects
{
    NSManagedObjectContext* managedObjectContext = [self managedObjectContext];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error = nil;
    NSArray* result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if ([self logError:error withMessage:@"fetch all projects"]) {
        return nil;
    }
    else {
        return result;
    }
}

- (NSArray*) fetchAllActivities
{
    NSLog(@"Fetch all activities");
    
    NSManagedObjectContext* managedObjectContext = [self managedObjectContext];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error = nil;
    NSArray* result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if ([self logError:error withMessage:@"fetch all activities"]) {
        return nil;
    }
    else {
        return result;
    }
}

- (NSArray*) fetchActivitiesForDate:(NSDate*) date
{
    NSLog(@"Fetch activities for %@", date);
    
    NSManagedObjectContext* managedObjectContext = [self managedObjectContext];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSDate* day      = [TimeUtils dayForDate:date];
    NSDate* dayAfter = [day dateByAddingTimeInterval:3600*24];
    // TODO perhaps not the most efficient query
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.date >= %@ AND self.date < %@", day, dayAfter];
    [fetchRequest setPredicate:predicate];
    
    NSError* error = nil;
    NSArray* result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([self logError:error withMessage:@"fetch all activities"]) {
        return nil;
    }
    else {
        return result;
    }
}

- (NSArray*) fetchActivitiesByDayForMonth:(NSDate*) date
{
    NSLog(@"Fetch activities by day for month %@", date);
    
    NSManagedObjectContext* managedObjectContext = [self managedObjectContext];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSDate* month      = [TimeUtils monthForDate:date];
    NSDate* monthAfter = [TimeUtils incrementMonthForMonth:month];
    // TODO perhaps not the most efficient query
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.date >= %@ AND self.date < %@", month, monthAfter];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError* error = nil;
    NSArray* result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([self logError:error withMessage:@"fetch all activities"]) {
        return nil;
    }

    NSMutableArray* activitiesByDay = [NSMutableArray array];
    NSDate* currentDay = nil;
    NSMutableArray* activitiesForSingleDay = nil;
    for (Activity* activity in result) {
        NSDate* actDay = [TimeUtils dayForDate:activity.date];
        
        if (![actDay isEqual:currentDay]) {
            activitiesForSingleDay = [NSMutableArray array];
            [activitiesByDay addObject:activitiesForSingleDay];
            currentDay = actDay;
        }
        
        [activitiesForSingleDay addObject:activity];
    }
    
    return activitiesByDay;

}

- (Project*) newProject
{
    NSManagedObjectContext* managedObjectContext = [self managedObjectContext];
    return [NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:managedObjectContext];
}

- (Activity*) newActivity
{
    NSManagedObjectContext* managedObjectContext = [self managedObjectContext];
    return [NSEntityDescription insertNewObjectForEntityForName:@"Activity" inManagedObjectContext:managedObjectContext];
}

- (TimeSlot*) newTimeSlot
{
    NSManagedObjectContext* managedObjectContext = [self managedObjectContext];
    return [NSEntityDescription insertNewObjectForEntityForName:@"TimeSlot" inManagedObjectContext:managedObjectContext];
}

- (void) saveContext
{
    NSError* error = nil;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Error happened while saving context: %@", [error localizedDescription]);
    }
    
}

- (void) deleteObject:(id)obj
{
    NSManagedObjectContext* managedObjectContext = [self managedObjectContext];
    [managedObjectContext deleteObject:obj];
}

- (BOOL) logError:(NSError*)error withMessage:(NSString*)msg {
    if (error != nil) {
        NSLog(@"Error - %@: %@, %@", msg, [error localizedDescription], [error userInfo]);
        return YES;
    }
    else {
        return NO;
    }
}
@end
