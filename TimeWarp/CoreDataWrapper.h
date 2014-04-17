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
#import "StoreChangeDelegate.h"

@interface CoreDataWrapper : NSObject

@property (strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

// TODO use the notification framework
@property (weak, nonatomic) id<StoreChangeDelegate> storeChangeDelegate;

+ (instancetype)shared;

- (NSURL *)applicationDocumentsDirectory;

- (void)persistentStoreDidImportUbiquitiousContentChanges:(NSNotification *)changeNotification;
- (void)storesWillChange:(NSNotification *)n;
- (void)storesDidChange:(NSNotification *)n;

- (NSArray*) fetchAllProjects;
- (void) setProjectSortOrder:(NSArray*)projects;

- (NSArray*) fetchAllActivities;
- (NSArray*) fetchActivitiesBetweenDate:(NSDate*)fromDate andExclusiveDate:(NSDate*)toDate;
- (NSArray*) fetchActivitiesForMonth:(NSDate*) date;
- (NSArray*) fetchActivitiesForDate:(NSDate*) date;
- (NSArray*) fetchActivitiesByDayForMonth:(NSDate*) date;

- (NSArray*) groupActivitiesByDay:(NSArray*)activities;

- (Project*) newProject;
- (Activity*) newActivity;
- (TimeSlot*) newTimeSlot;

- (void) saveContext;
- (void) deleteObject:(id)obj;

- (BOOL) logError:(NSError*)error withMessage:(NSString*)msg;


@end
