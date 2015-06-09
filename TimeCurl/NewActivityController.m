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

#import "NewActivityController.h"
#import "SelectTimeController.h"
#import "SlotInterval.h"
#import "AppDelegate.h"
#import "TimeUtils.h"
#import "CoreDataWrapper.h"
#import "Project+Additions.h"
#import "Flurry.h"
#import "PrefsConstants.h"
#import "UIApplication+AppDimensions.h"
#import "DeviceInfo.h"

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
    
    NSString* text = [NSString stringWithFormat:@"%.2fh", tot];
    if (timeString) {
        text = [NSString stringWithFormat:@"%@: %@", text, timeString];
    }
    
    self.timeTextField.text = text;
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

        if (self.timeSlotIntervals.count > 0) {
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
    
    [self saveSelectedProjectInPrefs];
}

- (void) saveSelectedProjectInPrefs
{
    NSString* projectId = [self.selectedProject projectId];
    [[NSUserDefaults standardUserDefaults] setObject:projectId forKey:PREFS_CURRENT_PROJECT];
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
    [self fillData];
    [self initAutoScreenshots];

    self.noteTextView.placeholder = @"Optional";
}

- (void)initAutoScreenshots
{
#ifdef AUTOSCREENSHOTS
    self.timeButton.accessibilityLabel = @"TimeButton";
#endif
}

- (void) fillData
{
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
        else {
            [self setDefaultProject];
        }
        
        // editing case -> take the currentDate from the activity
        if (self.activity != nil && self.currentDate == nil) {
            self.currentDate = self.activity.date;
        }
    }
}

- (void) setDefaultProject
{
    NSString* currentProjectId = [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_CURRENT_PROJECT];
    NSUInteger index = [self.projects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Project* project = (Project*)obj;
        return [project.projectId isEqualToString:currentProjectId];
    }];
    if (index != NSNotFound) {
        [self.pickerView selectRow:index inComponent:0 animated:NO];
        self.selectedProject = self.projects[index];
    }
}

- (double)doubleHourFromDate:(NSDate*)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger min  = [components minute];
    return (1.0 * hour) + ((min * 1.0) / 60.0);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.subviewWidthConstraint.constant = self.view.frame.size.width + [self horizontalOffset];

    [Flurry logEvent:@"Add Activity"];
}

- (CGFloat)horizontalOffset
{
    /*
     * In iOS 8, we dont need to have the horizontal constraint larger than the parrent view,
     * while in iOS 7 we do need it.
     */
    return [DeviceInfo iosVersionAsFloat] >= 8.0f ? 0.0f : 16.0f;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    CGSize newSize = [UIApplication sizeInOrientation:toInterfaceOrientation];
    self.subviewWidthConstraint.constant = newSize.width + [self horizontalOffset];
    
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
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
