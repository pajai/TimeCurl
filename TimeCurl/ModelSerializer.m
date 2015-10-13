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

#import "ModelSerializer.h"
#import "Activity.h"
#import "Project.h"
#import "TimeSlot.h"
#import "CoreDataWrapper.h"
#import "NotificationConstants.h"


@interface ModelSerializer ()
@property (strong, nonatomic) NSDateFormatter* dateFormatter;
@end


@implementation ModelSerializer

- (id)init {
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    return self;
}

#pragma mark - export

- (NSData*) serializeProjects:(NSArray*)projects;
{
    NSMutableArray* convertedProjects = [NSMutableArray arrayWithCapacity:[projects count]];
    for (Project* project in projects) {
        NSDictionary* convertedProject = [self mapProject:project];
        [convertedProjects addObject:convertedProject];
    }
    
    NSDictionary* dict = @{@"name":@"TimeCurl",
                           @"version":@"1",
                           @"data":convertedProjects};
    
    NSError* error = nil;
    if (![NSJSONSerialization isValidJSONObject:convertedProjects]) {
        DDLogError(@"Projects are not valid JSON objects");
        return nil;
    }
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:&error];
    
    if (error) {
        DDLogError(@"Error while converting the projects to foundation objects, error: %@", [error localizedDescription]);
        return nil;
    }
    
    return data;
}

- (NSDictionary*) mapProject:(Project*)project
{
    NSMutableDictionary* projDict = [NSMutableDictionary dictionaryWithCapacity:4];
    projDict[@"name"] = project.name;
    projDict[@"subname"] = project.subname;
    if (project.note) {
        projDict[@"note"] = project.note;
    }
    if (project.icon) {
        projDict[@"icon"] = project.icon;
    }
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[project.activities count]];
    for (Activity* activity in project.activities) {
        NSDictionary* actDict = [self mapActivity:activity];
        if (!actDict) {
            continue;
        }
        [array addObject:actDict];
    }
    projDict[@"activities"] = array;
    return projDict;
}

- (NSDictionary*) mapActivity:(Activity*)activity
{
    /*
     * An activity without date cannot be found anymore -> skip
     */
    if (!activity.date) {
        return nil;
    }
    NSMutableDictionary* actDict = [NSMutableDictionary dictionaryWithCapacity:3];
    actDict[@"date"] = [self.dateFormatter stringFromDate:activity.date];
    if (activity.note) {
        actDict[@"note"] = activity.note;
    }
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[activity.timeslots count]];
    for (TimeSlot* timeslot in activity.timeslots) {
        NSDictionary* timeSlotDict = [self mapTimeSlot:timeslot];
        [array addObject:timeSlotDict];
    }
    actDict[@"timeslots"] = array;
    return actDict;
}

- (NSDictionary*) mapTimeSlot:(TimeSlot*)timeSlot
{
    NSMutableDictionary* timeSlotDict = [NSMutableDictionary dictionaryWithCapacity:2];
    timeSlotDict[@"start"] = timeSlot.start;
    timeSlotDict[@"end"]   = timeSlot.end;
    return timeSlotDict;
}


#pragma mark - import

- (void) importFileFromUrl:(NSURL*)url
{
    NSError* error = nil;
    NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
    if (error) {
        DDLogError(@"Failed reading the data from the url %@, error: %@", url, [error localizedDescription]);
        [self showError:[NSString stringWithFormat:@"An error occured while importing the file."]];
        return;
    }
    
    NSObject* object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        DDLogError(@"Failed to convert the data to JSON objects, error: %@", [error localizedDescription]);
        [self showError:[NSString stringWithFormat:@"An error occured while importing the file."]];
        return;
    }
    
    if (![object isKindOfClass:[NSDictionary class]]) {
        DDLogError(@"The imported JSON object is not of the right type, should be a dictionary, is %@", [object class]);
        [self showError:[NSString stringWithFormat:@"An error occured while importing the file."]];
        return;
    }
    
    NSDictionary* dict = (NSDictionary*)object;
    if (![self dataHasValidHeader:dict]) {
        DDLogError(@"The imported data is not compatible with TimeCurl format version 1");
        [self showError:[NSString stringWithFormat:@"The imported data is not compatible with the current TimeCurl format version. You can only import data with the same app version used to export it."]];
        return;
    }
    
    NSArray* projArray = dict[@"data"];
    [self mapToProjects:projArray];
    [[CoreDataWrapper shared] saveContext];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_REFRESH_AFTER_IMPORT object:nil];
    
}

- (void) showError:(NSString*)message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void) mapToProjects:(NSArray*)projArray
{
    NSInteger sortOrder = 0;
    for (NSDictionary* projDict in projArray) {
        Project* project = [[CoreDataWrapper shared] newProject];
        project.name = projDict[@"name"];
        project.subname = projDict[@"subname"];
        if (projDict[@"note"]) {
            project.note = projDict[@"note"];
        }
        if (projDict[@"icon"]) {
            project.icon = projDict[@"icon"];
        }
        project.sortOrder = [NSNumber numberWithInteger:sortOrder];
        [[CoreDataWrapper shared] saveContext];
        [self mapToActivities:projDict[@"activities"] forProject:project];
        sortOrder += 1;
    }
}

- (void) mapToActivities:(NSArray*)actArray forProject:(Project*)project
{
    for (NSDictionary* actDict in actArray) {
        Activity* activity = [[CoreDataWrapper shared] newActivity];
        activity.project = project;
        activity.note = actDict[@"note"];
        activity.date = [self.dateFormatter dateFromString:actDict[@"date"]];
        [self mapToTimeSlots:actDict[@"timeslots"] forActivity:activity];
        [[CoreDataWrapper shared] saveContext];
    }
}

- (void) mapToTimeSlots:(NSArray*)slotArray forActivity:(Activity*)activity
{
    NSMutableSet* timeSlots = [NSMutableSet setWithCapacity:[slotArray count]];
    for (NSDictionary* slotDict in slotArray) {
        TimeSlot* timeSlot = [[CoreDataWrapper shared] newTimeSlot];
        timeSlot.activity = activity;
        timeSlot.start = slotDict[@"start"];
        timeSlot.end   = slotDict[@"end"];
        [timeSlots addObject:timeSlot];
    }
    activity.timeslots = timeSlots;
}

- (BOOL) dataHasValidHeader:(NSDictionary*)dict
{
    return [dict[@"name"] isEqualToString:@"TimeCurl"]&&
           [dict[@"version"] isEqualToString:@"1"] &&
           dict[@"data"];
}


#pragma mark - delete

- (void) deleteAllData
{
    NSArray* projects = [[CoreDataWrapper shared] fetchAllProjects];
    for (Project *project in projects) {
        [[CoreDataWrapper shared] deleteObject:project];
    }
    [[CoreDataWrapper shared] saveContext];
}

@end

