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
#import "CoreDataWrapper.h"
#import "Project.h"
#import "Flurry.h"


@interface NewActivityController ()

@property (readwrite) BOOL resetTimeInProgress;

- (void) updateTimeField;
- (void) loadProjects;
- (double)doubleHourFromDate:(NSDate*)date;

@end

@implementation NewActivityController

#pragma mark custom methods

- (IBAction)doneSelectingTime:(UIStoryboardSegue *)segue {
    NSLog(@"Done selecting time");

    SelectTimeController* sourceController = segue.sourceViewController;
    self.timeSlotIntervals = sourceController.timeSlotIntervals;
    [self updateTimeField];
}

- (void) updateTimeField
{
    NSString* timeString = nil;
    double tot = 0.0;
    for (SlotInterval* slotInterval in self.timeSlotIntervals) {
        NSString* slotString = [slotInterval description];
        timeString = timeString == nil ? slotString : [NSString stringWithFormat:@"%@, %@", timeString, slotString];
        tot += slotInterval.duration;
    }
    self.timeTextField.text = [NSString stringWithFormat:@"%.2fh: %@", tot, timeString];
}

- (IBAction)donePressed:(id)sender
{
    NSLog(@"NewActivityController: done pressed");
    
    if (self.activity == nil) {
        self.activity = [[CoreDataWrapper shared] newActivity];
    }
    
    NSMutableSet* newSlots = [NSMutableSet set];
    NSInteger i = 0;
    NSArray* existingSlots = self.activity.timeslots.allObjects;
    for (SlotInterval* slot in self.timeSlotIntervals) {
        TimeSlot* timeSlot = nil;
        
        // try to reuse an existing slot
        if (i < [existingSlots count]) {
            timeSlot = [existingSlots objectAtIndex:i];
        }
        // nothing found? -> create a new one
        else {
            timeSlot = [[CoreDataWrapper shared] newTimeSlot];
        }
        
        timeSlot.start = @(slot.begin);
        timeSlot.end   = @(slot.end);
        timeSlot.activity = self.activity;
        [newSlots addObject:timeSlot];
        
        i++;
    }
    self.activity.timeslots = newSlots;
    self.activity.project = self.selectedProject;
    self.activity.date = self.currentDate;
    self.activity.note = self.noteTextView.text;
    
    // delete old slots which are not used anymore
    for (NSInteger j = i; j < [existingSlots count]; j++) {
        TimeSlot* slot = [existingSlots objectAtIndex:j];
        [[CoreDataWrapper shared] deleteObject:slot];
    }
    
    [[CoreDataWrapper shared] saveContext];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) loadProjects
{
    self.projects = [[CoreDataWrapper shared] fetchAllProjects];
}

- (IBAction)resetTime:(UILongPressGestureRecognizer*)sender
{
    // we don't want two concurrent events
    if (!self.resetTimeInProgress) {
        self.resetTimeInProgress = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset Time"
                                                        message:@"Do you want to reset the time for this activity?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Reset", nil];
        [alert show];
    }
}

#pragma mark UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // from that point, we handle again resetTime events
    self.resetTimeInProgress = NO;
    
    // reset button
    if (buttonIndex == 1) {

        // reset time slot array
        self.timeSlotIntervals = [NSMutableArray array];
        [self updateTimeField];
        
    }
    
}

#pragma mark transitions

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditTime"]) {

        if (self.activity != nil) {
            SelectTimeController* controller = (SelectTimeController*)segue.destinationViewController;
            controller.timeSlotIntervals = [NSMutableArray array];
            [controller.timeSlotIntervals addObjectsFromArray:self.timeSlotIntervals];
        }
        
    }
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
    
    self.resetTimeInProgress = NO;

    [self loadProjects];

    if ([self.projects count] > 0) {
        self.selectedProject = [self.projects objectAtIndex:0];
        
        if (self.activity != nil) {
            
            // init self.timeSlotIntervals
            NSMutableArray* slotArray = [NSMutableArray array];
            for (TimeSlot* timeSlot in self.activity.timeslots) {
                SlotInterval* slotInterval = [[SlotInterval alloc] init];
                slotInterval.begin = [timeSlot.start doubleValue];
                slotInterval.end   = [timeSlot.end doubleValue];
                [slotArray addObject:slotInterval];
            }
            self.timeSlotIntervals = slotArray;
            
            // pre-fill the fields
            self.selectedProject = self.activity.project;
            NSInteger selectedProjectIndex = [self.projects indexOfObject:self.activity.project];
            [self.pickerView selectRow:selectedProjectIndex inComponent:0 animated:NO];
            self.noteTextView.text = self.activity.note;
            [self updateTimeField];
            
            self.title = @"Edit Activity";
        }
        
        // editing case -> take the currentDate from the activity
        if (self.activity != nil && self.currentDate == nil) {
            self.currentDate = self.activity.date;
        }
    }
    
    self.noteTextView.tintColor = [UIColor blackColor];
}

- (double)doubleHourFromDate:(NSDate*)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger min  = [components minute];
    return (1.0 * hour) + ((min * 1.0) / 60.0);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Flurry logEvent:@"Add Activity"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark State Restauration

// TODO not working for this controller

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:[self.pickerView selectedRowInComponent:0] forKey:@"pickerindex"];
    [coder encodeObject:self.noteTextView.text forKey:@"note"];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSInteger pickerIndex = [coder decodeIntegerForKey:@"pickerindex"];
    [self.pickerView selectRow:pickerIndex inComponent:0 animated:NO];
    self.noteTextView.text = [coder decodeObjectForKey:@"note"];
    [super decodeRestorableStateWithCoder:coder];
}

@end
