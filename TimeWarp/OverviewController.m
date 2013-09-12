//
//  OverviewControllerViewController.m
//  TimeWarp
//
//  Created by pat on 01.07.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "OverviewController.h"
#import "CoreDataWrapper.h"
#import "TimeUtils.h"
#import "CHCSVParser.h"
#import "MailComposeHandler.h"
#import "NewActivityController.h"
#import "DTCustomColoredAccessory.h"
#import "UIConstants.h"
#import "UIUtils.h"


#define kDayCellHeight 30
#define kActivityCellHeightNonEmptyNote 70
#define kActivityCellHeightEmptyNote 52



@interface OverviewController ()
- (void) loadData;
- (void) initCurrentDate;
- (void) updateTitle;
@end

@implementation OverviewController


#pragma mark custom methods

- (void) loadData
{
    self.activitiesByDay = [NSMutableArray arrayWithArray:[[CoreDataWrapper shared] fetchActivitiesByDayForMonth:self.currentDate]];
    
    [self.tableView reloadData];
}

- (void) initCurrentDate
{
    self.currentDate = [NSDate date];
}

- (void) updateTitle
{
    // total hours for that month
    double totTime = 0.0;
    for (NSArray* dayActivities in self.activitiesByDay) {
        for (Activity* activity in dayActivities) {
            totTime += [activity duration];
        }
    }
    
    // date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM yyyy"];
    NSString* dateString = [dateFormatter stringFromDate:self.currentDate];
    
    // change the nav title
    // rem: if we change self.title, we change also the tab title
    self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"%@ (%.2f)", dateString, totTime];
}

- (IBAction) sharePressed:(id)sender
{

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share"
                                                    message:@"Do you want to share the activities of the current month by e-mail?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok", nil];
    [alert show];

}

- (IBAction)handleSwipeRight:(UISwipeGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded) {
		NSLog(@"Current date minus one month");
        self.currentDate = [TimeUtils decrementMonthForMonth:self.currentDate];
        [self loadData];
        [self updateTitle];
    }
}

- (IBAction)handleSwipeLeft:(UISwipeGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded) {
		NSLog(@"Current date plus one month");
        self.currentDate = [TimeUtils incrementMonthForMonth:self.currentDate];
        [self loadData];
        [self updateTitle];
    }
}

#pragma mark UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        // filename
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM"];
        NSString* dateStr = [dateFormatter stringFromDate:self.currentDate];
        NSString* fileName = [NSString stringWithFormat:@"activities-%@.csv", dateStr];

        // date formatter for activity date (with day precision)
        NSDateFormatter *activityDateFormatter = [[NSDateFormatter alloc] init];
        [activityDateFormatter setDateStyle:NSDateFormatterShortStyle];
        
        // construct CSV file
        NSString* tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        CHCSVWriter* writer = [[CHCSVWriter alloc] initForWritingToCSVFile:tempPath];

        [writer writeField:@"Date"];
        [writer writeField:@"Project"];
        [writer writeField:@"Activity Note"];
        [writer writeField:@"Duration [h]"];
        [writer finishLine];
        for (NSArray* dayActivities in self.activitiesByDay) {
            for (Activity* activity in dayActivities) {
                [writer writeField:[activityDateFormatter stringFromDate:activity.date]];
                [writer writeField:[NSString stringWithFormat:@"%@ (%@)", activity.project.name, activity.project.subname]];
                [writer writeField:activity.note];
                [writer writeField:[NSString stringWithFormat:@"%.2f", [activity duration]]];
                [writer finishLine];
            }
        }
        [writer closeStream];
        
        self.mailComposeHandler = [[MailComposeHandler alloc] init];
        self.mailComposeHandler.subject = [NSString stringWithFormat:@"Time tracking for %@", dateStr];
        self.mailComposeHandler.attachmentName = fileName;
        self.mailComposeHandler.attachmentData = [NSData dataWithContentsOfFile:tempPath];
        self.mailComposeHandler.attachmentMime = @"text/csv";
        self.mailComposeHandler.delegate = self;
        //
        [self.mailComposeHandler prepareMailComposeViewController];
		[self presentViewController:self.mailComposeHandler.mailComposeController animated:YES completion:nil];
    }
}

#pragma mark callback method from MailComposeCallbackDelegate

- (void) mailComposeCallback
{
    // free the reference to the mail compose handler, that we don't need at that point
    self.mailComposeHandler = nil;
}

#pragma mark transitions

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NewActivityController* controller = (NewActivityController*)segue.destinationViewController;
    // don't set controller.currentDate -> taken from the activity
    
    if ([segue.identifier isEqualToString:@"EditActivity"]) {
        
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        Activity* activity = [[self.activitiesByDay objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
        controller.activity = activity;
        
    }
}


#pragma mark common methods from UIViewController

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
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"EEEE d"];

    [UIUtils setEmptyFooterView:self.tableView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
    [self updateTitle];
    [CoreDataWrapper shared].storeChangeDelegate = self;
}

- (void) storeDidChange
{
    [self loadData];
    [self updateTitle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.activitiesByDay count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // +1 is for the day title cell
    return [[self.activitiesByDay objectAtIndex:section] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    // case day title cell
    if (indexPath.row == 0) {
        
        static NSString *CellIdentifier = @"DayTitleCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UILabel* dayLabel      = (UILabel*)[cell viewWithTag:100];
        UILabel* durationLabel = (UILabel*)[cell viewWithTag:101];
        
        NSArray* activitiesForDay = [self.activitiesByDay objectAtIndex:indexPath.section];
        
        Activity* activity = (Activity*)activitiesForDay[0];
        NSString* dateString = [_dateFormatter stringFromDate:activity.date];
        dayLabel.text = dateString;
        
        // TODO duration
        double dailyDuration = 0;
        for (Activity* act in activitiesForDay) {
            dailyDuration += [act duration];
        }
        durationLabel.text = [NSString stringWithFormat:@"%.2f", dailyDuration];
        
        
    }
    // case day activity
    else {
        
        static NSString *CellIdentifier = @"ActivityCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

        Activity* activity = (Activity*)[self.activitiesByDay objectAtIndex:indexPath.section][indexPath.row - 1];
        
        UILabel* titleLabel    = (UILabel*)[cell viewWithTag:100];
        UILabel* durationLabel = (UILabel*)[cell viewWithTag:101];
        UILabel* noteLabel     = (UILabel*)[cell viewWithTag:102];
        
        cell.accessoryView = [DTCustomColoredAccessory accessoryWithSingleColor:[UIConstants shared].deepBlueColor];
        
        // TODO dynamic height? -> cf CurrentListController
        
        Project* project = activity.project;
        titleLabel.text = [NSString stringWithFormat:@"%@ (%@)", project.name, project.subname];
        durationLabel.text = [NSString stringWithFormat:@"%.2f", [activity duration]];
        noteLabel.text = activity.note;
        [noteLabel sizeToFit];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return kDayCellHeight;
    }
    else {

        Activity* activity = (Activity*)[self.activitiesByDay objectAtIndex:indexPath.section][indexPath.row - 1];
        NSString* trimmedNote = [activity.note stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimmedNote length] > 0) {
            return kActivityCellHeightNonEmptyNote;
        }
        else {
            return kActivityCellHeightEmptyNote;
        }

    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
