//
//  NewActivityController.m
//  TimeWarp
//
//  Created by pat on 20.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "NewActivityController.h"
#import "SelectTimeController.h"
#import "SlotInterval.h"
#import "AppDelegate.h"
#import "TimeUtils.h"
#import "ModelUtils.h"
#import "Project.h"


@interface NewActivityController ()
- (void) loadProjects;
@end

@implementation NewActivityController

#pragma mark custom methods

- (IBAction)doneSelectingTime:(UIStoryboardSegue *)segue {
    NSLog(@"Done selecting time");

    SelectTimeController* sourceController = segue.sourceViewController;
    self.timeSlotIntervals = sourceController.timeSlotIntervals;
    NSString* timeString = nil;
    for (SlotInterval* slotInterval in self.timeSlotIntervals) {
        NSString* slotString = [NSString stringWithFormat:@"%@-%@",
                                    [TimeUtils timeStringFromDouble:slotInterval.begin],
                                    [TimeUtils timeStringFromDouble:slotInterval.end]];
        timeString = timeString == nil ? slotString : [NSString stringWithFormat:@"%@, %@", timeString, slotString];
    }
    self.timeTextField.text = timeString;
}

- (IBAction)donePressed:(id)sender
{
    NSLog(@"NewActivityController: done pressed");
    
    if (self.activity == nil) {
        self.activity = [ModelUtils newActivity];
    }
    
    NSMutableSet* newSlots = [NSMutableSet set];
    for (SlotInterval* slot in self.timeSlotIntervals) {
        TimeSlot* newTimeSlot = [ModelUtils newTimeSlot];
        newTimeSlot.start = [TimeUtils dateFromCurrentDate:self.currentDate andDoubleHour:slot.begin];
        newTimeSlot.end   = [TimeUtils dateFromCurrentDate:self.currentDate andDoubleHour:slot.end];
        newTimeSlot.activity = self.activity;
        [newSlots addObject:newTimeSlot];
    }
    self.activity.timeslots = newSlots;
    self.activity.project = self.selectedProject;
    [ModelUtils saveContext];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) loadProjects
{
    self.projects = [ModelUtils fetchAllProjects];
}

#pragma mark methods from UIPickerView (DataSource and Delegate)

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.projects count];
}

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Project* project = [self.projects objectAtIndex:row];
    return [NSString stringWithFormat:@"%@, %@", project.name, project.subname];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedProject = [self.projects objectAtIndex:row];
}

#pragma mark standard methods from UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.selectedProject = [self.projects objectAtIndex:0];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadProjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
