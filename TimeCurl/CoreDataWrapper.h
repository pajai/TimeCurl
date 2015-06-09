/*
 
 Copyright (C) 2013-2015, Patrick Jayet
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
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
