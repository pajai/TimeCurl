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

#import "CurrentListController.h"
#import "AppDelegate.h"
#import "Activity.h"
#import "Project+Additions.h"
#import "Activity+Additions.h"
#import "NewActivityController.h"
#import "CoreDataWrapper.h"
#import "SlotInterval.h"
#import "SelectDayController.h"
#import "UIConstants.h"
#import "UIUtils.h"
#import "Flurry.h"
#import "NotificationConstants.h"
#import "AutoscreenshotsUtils.h"


@interface CurrentListController ()
@end


@implementation CurrentListController

#pragma mark action for unwind segue from SelectDayController

- (IBAction)doneSelectingDay:(UIStoryboardSegue *)segue
{
    DDLogDebug(@"Done selecting day");
    
    SelectDayController* sourceController = segue.sourceViewController;
    self.currentDate = sourceController.currentDate;
}

#pragma mark - Edit Mode

- (IBAction)enterEditMode:(id)sender
{
    // Add the done button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Done"
                                             style:UIBarButtonItemStyleDone
                                             target:self
                                             action:@selector(leaveEditMode:)];
    
    self.backupButtonRight = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
	
    [self.tableView setEditing:YES animated:YES];
    
}

- (IBAction)leaveEditMode:(id)sender
{
    // Add the edit button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Edit"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(enterEditMode:)];
    
    self.navigationItem.rightBarButtonItem = self.backupButtonRight;
    self.backupButtonRight = nil;
    
    [self.tableView setEditing:NO animated:YES];
    
}


#pragma mark custom logic methods

- (void) loadData
{
    self.activities = [NSMutableArray arrayWithArray:[[CoreDataWrapper shared] fetchActivitiesForDate:self.currentDate]];
    [self.tableView reloadData];
}

- (void) initCurrentDate
{
#ifdef AUTOSCREENSHOTS
    self.currentDate = [AutoscreenshotsUtils dateForScreenshots];
#else
    self.currentDate = [NSDate date];
#endif
}

- (void) updateTitle
{
    // total hours for that day
    double totTime = 0.0;
    for (Activity* activity in self.activities) {
        totTime += [activity duration];
    }

    // date
    NSString* dateString = nil;
    if ([self isToday]) {
        dateString = @"Today";
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        dateString = [dateFormatter stringFromDate:self.currentDate];
    }
    NSString* titleString = [NSString stringWithFormat:@"%@ (%.2f)", dateString, totTime];
    
    // change the nav title
    // rem: if we change self.title, we change also the tab title
    self.navigationController.navigationBar.topItem.title = titleString;
}

- (BOOL) isToday
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.currentDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    return [today isEqual:otherDate];
}

- (IBAction)handleSwipeRight:(UISwipeGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded) {
		DDLogDebug(@"Current date minus one day");
        self.currentDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:self.currentDate];
        [self loadData];
        [self updateTitle];
    }
}

- (IBAction)handleSwipeLeft:(UISwipeGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded) {
		DDLogDebug(@"Current date plus one day");
        self.currentDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:self.currentDate];
        [self loadData];
        [self updateTitle];
    }
}

- (void) storeDidChange
{
    [self loadData];
}


#pragma mark transitions

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"NewActivity"]) {
        
        /*
         * For a new activity, check that we have at least one project
         */
        
        // TODO: get the number of projects without loading them
        
        NSArray* projects = [[CoreDataWrapper shared] fetchAllProjects];
        if ([projects count] == 0) {
            // show an error message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Project Yet"
                                                            message:@"Please insert a project first (in the tab Projects)!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            // We need to deselect the row. Since we know which cell it was (new activity cell),
            // we can directly construct the index path for it.
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES];
        }
        
        return [projects count] > 0;
    }
    else {
        return YES;
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 
    if ([segue.identifier isEqualToString:@"EditActivity"]) {
        
        NewActivityController* controller = (NewActivityController*)segue.destinationViewController;
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        Activity* activity = [self.activities objectAtIndex:indexPath.row];
        controller.activity = activity;
        
        // don't set controller.currentDate -> taken from the activity
        
    }
    else if ([segue.identifier isEqualToString:@"NewActivity"]) {

        NewActivityController* controller = (NewActivityController*)segue.destinationViewController;
        controller.currentDate = self.currentDate;
        
    }
    else if ([segue.identifier isEqualToString:@"SelectDay"]) {
        
        SelectDayController* controller = (SelectDayController*)segue.destinationViewController;
        controller.currentDate = self.currentDate;
        
    }
    
}


#pragma mark standard UIViewController methods

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initCurrentDate];
    
    [UIUtils setEmptyFooterView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
    [CoreDataWrapper shared].storeChangeDelegate = self;
    
    [Flurry logEvent:@"Tab Activities"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataRefreshedAfterImport)
                                                 name:DATA_REFRESH_AFTER_IMPORT
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    // if we do this call from viewWillAppear, we might get a wrong controller shown,
    // hence we don't change the right navbar title
    [self updateTitle];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DATA_REFRESH_AFTER_IMPORT
                                                  object:nil];
    [super viewDidDisappear:animated];
}

- (void)dataRefreshedAfterImport
{
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.activities count];
    }
    else {
        return 1;
    }
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath
{
    static NSString *activityId = @"ActivityCell";
    static NSString *newCellId  = @"NewCell";
    return indexPath.section == 0 ? activityId : newCellId;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIdentifier = [self reuseIdentifierForIndexPath:indexPath];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        Activity* activity = [self.activities objectAtIndex:indexPath.row];
        UILabel* titleLabel      = (UILabel*)[cell viewWithTag:100];
        UILabel* durationLabel   = (UILabel*)[cell viewWithTag:101];
        UILabel* noteTextLabel   = (UILabel*)[cell viewWithTag:102];
        UIImageView* iconView    = (UIImageView*)[cell viewWithTag:103];
        
        cell.accessoryView = [UIUtils accessoryView];
        
        Project* project = activity.project;
        titleLabel.text = [project label];
        durationLabel.text = [activity formattedDuration];
        noteTextLabel.text = activity.note ? activity.note : @" ";
        iconView.image = [project imageWithDefaultName:@"icon-activity-list"];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.section) {
        default:
        case 0:
            return 75.0f;
        case 1:
            return 82.0f;
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // we don't show a confirmation here, since deleting an activity is not as destructive as
        // deleting a project
        
        Activity* activity = [self.activities objectAtIndex:indexPath.row];
        [self.activities removeObject:activity];
        [[CoreDataWrapper shared] deleteObject:activity];
        [[CoreDataWrapper shared] saveContext];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self updateTitle];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
