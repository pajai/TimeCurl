/*
 
 Copyright 2013-2015 Patrick Jayet
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
*/

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
- (NSArray*) fetchActivitiesBetweenDate:(NSDate*)fromDate andExclusiveDate:(NSDate*)toDate forProjects:(NSArray*)projects;
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
