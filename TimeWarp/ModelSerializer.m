//
//  ModelSerializer.m
//  TimeWarp
//
//  Created by pat on 20.03.2014.
//  Copyright (c) 2014 zuehlke. All rights reserved.
//

#import "ModelSerializer.h"
#import "Activity.h"
#import "Project.h"
#import "TimeSlot.h"


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
        NSLog(@"Projects are not valid JSON objects");
        return nil;
    }
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:&error];
    
    if (error) {
        NSLog(@"Error while converting the projects to foundation objects, error: %@", [error localizedDescription]);
        return nil;
    }
    
    return data;
}

- (NSDictionary*) mapProject:(Project*)project
{
    NSMutableDictionary* projDict = [NSMutableDictionary dictionaryWithCapacity:4];
    projDict[@"name"] = project.name;
    projDict[@"subname"] = project.subname;
    projDict[@"note"] = project.note;
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[project.activities count]];
    for (Activity* activity in project.activities) {
        NSDictionary* actDict = [self mapActivity:activity];
        [array addObject:actDict];
    }
    projDict[@"activities"] = array;
    return projDict;
}

- (NSDictionary*) mapActivity:(Activity*)activity
{
    NSMutableDictionary* actDict = [NSMutableDictionary dictionaryWithCapacity:3];
    actDict[@"date"] = [self.dateFormatter stringFromDate:activity.date];
    actDict[@"note"] = activity.note;
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

@end

