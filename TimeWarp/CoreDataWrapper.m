//
//  ModelUtils.m
//  TimeWarp
//
//  Created by pat on 20.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "CoreDataWrapper.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "TimeUtils.h"

NSString * const DPModelName        = @"ItemModel";
NSString * const DPStoreName        = @"TimeCurl.sqlite";
NSString * const DPUbiquitousName   = @"com~timecurl~coredataicloud";


@interface CoreDataWrapper ()

@end


@implementation CoreDataWrapper

+ (instancetype)shared
{
    static CoreDataWrapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (sharedInstance == nil){
            sharedInstance = [[CoreDataWrapper alloc] init];
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
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel*) managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    // new
    //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:DPModelName withExtension:@"momd"];
    //_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    // old
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator*) persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:DPStoreName];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES,
                               NSInferMappingModelAutomaticallyOption : @YES,
                               NSPersistentStoreUbiquitousContentNameKey : DPUbiquitousName
                               };
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(persistentStoreDidImportUbiquitiousContentChanges:)
                                                 name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                               object:_persistentStoreCoordinator];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storesWillChange:)
                                                 name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                                               object:_persistentStoreCoordinator];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storesDidChange:)
                                                 name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                                               object:_persistentStoreCoordinator];
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

# pragma iCloud Support

- (void)persistentStoreDidImportUbiquitiousContentChanges:(NSNotification *)changeNotification
{
    NSLog(@">>>> MERGE CANDIDATE");

    NSManagedObjectContext *moc = [self managedObjectContext];
    [moc performBlock:^{
        NSDictionary *userInfo = [changeNotification userInfo];
        NSLog(@">>>> BEGIN");
        NSLog(@"%@", userInfo);
        NSLog(@">>>> END");
        if (([userInfo objectForKey:NSInsertedObjectsKey] > 0) &&
            ([userInfo objectForKey:NSUpdatedObjectsKey] > 0) &&
            ([userInfo objectForKey:NSDeletedObjectsKey] > 0))
        {
            NSLog(@">>>> MERGE");
            [moc mergeChangesFromContextDidSaveNotification:changeNotification];
            [self.storeChangeDelegate storeDidChange];
        }
    }];
}

- (void)storesWillChange:(NSNotification *)n
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    [moc performBlockAndWait:^{
        NSError *error = nil;
        if ([moc hasChanges]) {
            [moc save:&error];
        }
        [moc reset];
    }];
    //reset user interface
    
    NSLog(@">>>> Stores Will Change, TODO update UI");
    NSLog(@">>>> BEGIN");
    NSDictionary *userInfo = [n userInfo];
    NSLog(@"%@", userInfo);
    NSLog(@">>>> END");

}

- (void)storesDidChange:(NSNotification *)n
{
    //refresh user interface
    
    NSLog(@">>>> Stores Did Change, TODO update UI");
    NSLog(@">>>> BEGIN");
    NSDictionary *userInfo = [n userInfo];
    NSLog(@"%@", userInfo);
    NSLog(@">>>> END");

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
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];

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

- (NSArray*) fetchAllActivitiesByDay
{
    NSArray* allActivities = [self fetchAllActivities];
    return [self groupActivitiesByDay:allActivities];
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

    return [self groupActivitiesByDay:result];
}

- (NSArray*) groupActivitiesByDay:(NSArray*)activities
{
    NSMutableArray* activitiesByDay = [NSMutableArray array];
    NSDate* currentDay = nil;
    NSMutableArray* activitiesForSingleDay = nil;
    for (Activity* activity in activities) {
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
