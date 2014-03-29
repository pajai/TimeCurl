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
#import "Flurry.h"
#import "ModelSerializer.h"
#import "NotificationConstants.h"


#define kDayCellHeight 30
#define kActivityCellHeightNonEmptyNote 70
#define kActivityCellHeightEmptyNote 52



@interface OverviewController ()

@property (nonatomic, strong) MailComposeHandler* mailComposeHandler;
@property (nonatomic, strong) NSArray* activitiesByDay;
@property (nonatomic, strong) NSDate* currentDate;
@property (strong, nonatomic) NSMutableDictionary* reportDictionary;

- (void) loadData;
- (void) initCurrentDate;
- (void) updateTitle;
@end

@implementation OverviewController


#pragma mark custom methods

- (void) loadData
{
    NSArray* activities = [[CoreDataWrapper shared] fetchActivitiesForMonth:self.currentDate];
    [self createReportForActivities:activities];
    
    self.activitiesByDay = [[CoreDataWrapper shared] groupActivitiesByDay:activities];
    
    [self.tableView reloadData];
}

- (void) createReportForActivities:(NSArray*)activities
{
    NSMutableDictionary* report = [NSMutableDictionary dictionaryWithCapacity:10];
    for (Activity* activity in activities) {
        NSString* projectLabel = [self createLabelForProject:activity.project];
        if (!report[projectLabel]) {
            report[projectLabel] = @0.0;
        }
        report[projectLabel] = [NSNumber numberWithDouble:[report[projectLabel] doubleValue] + activity.duration];
    }
    self.reportDictionary = report;
}

- (NSString*) createLabelForProject:(Project*)project
{
    return [NSString stringWithFormat:@"%@, %@", project.name, project.subname];
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
                                                    message:@"How do you want to share the data?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Current month (CSV)", @"All activities (CSV)", @"Complete data set (proprietary)", nil];
    [alert show];

}

- (IBAction)handleSwipeRight:(UISwipeGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded) {
		NSLog(@"Current date minus one month");
        self.currentDate = [TimeUtils decrementMonthForDate:self.currentDate];
        [self loadData];
        [self updateTitle];
    }
}

- (IBAction)handleSwipeLeft:(UISwipeGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded) {
		NSLog(@"Current date plus one month");
        self.currentDate = [TimeUtils incrementMonthForDate:self.currentDate];
        [self loadData];
        [self updateTitle];
    }
}

#pragma mark UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        [self exportCurrentMonthInCsv];
        
    }
    else if (buttonIndex == 2) {
        
        [self exportAllActivitiesInCsv];
        
    }
    else if (buttonIndex == 3) {
        
        [self exportAllActivitiesCustom];
        
    }
}

- (void) exportAllActivitiesCustom
{
    self.mailComposeHandler = [[MailComposeHandler alloc] init];
    self.mailComposeHandler.subject = [NSString stringWithFormat:@"All activities"];
    self.mailComposeHandler.attachmentName = @"AllActivities.timecurl";
    
    NSArray* projects = [[CoreDataWrapper shared] fetchAllProjects];
    NSData* data = [[[ModelSerializer alloc] init] serializeProjects:projects];
    
    self.mailComposeHandler.attachmentData = data;
    self.mailComposeHandler.attachmentMime = @"application/timecurl";
    self.mailComposeHandler.delegate = self;
    //
    [self.mailComposeHandler prepareMailComposeViewController];
    [self presentViewController:self.mailComposeHandler.mailComposeController animated:YES completion:nil];
}

- (void) exportCurrentMonthInCsv
{
    // filename
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString* dateStr = [dateFormatter stringFromDate:self.currentDate];
    NSString* fileName = [NSString stringWithFormat:@"activities-%@.csv", dateStr];
    
    NSString* title = [NSString stringWithFormat:@"Time tracking for %@", dateStr];
    
    [self exportActivitiesInCsv:self.activitiesByDay withFileName:fileName andSubject:title];
}

- (void) exportAllActivitiesInCsv
{
    NSArray* activities = [[CoreDataWrapper shared] fetchActivitiesByDayForMonth:self.currentDate];
    [self exportActivitiesInCsv:activities withFileName:@"all-activities.csv" andSubject:@"All activities"];
}

- (void) exportActivitiesInCsv:(NSArray*)activities withFileName:(NSString*)fileName andSubject:(NSString*)title
{
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
    for (NSArray* dayActivities in activities) {
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
    self.mailComposeHandler.subject = title;
    self.mailComposeHandler.attachmentName = fileName;
    self.mailComposeHandler.attachmentData = [NSData dataWithContentsOfFile:tempPath];
    self.mailComposeHandler.attachmentMime = @"text/csv";
    self.mailComposeHandler.delegate = self;
    //
    [self.mailComposeHandler prepareMailComposeViewController];
    [self presentViewController:self.mailComposeHandler.mailComposeController animated:YES completion:nil];
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
    
    [Flurry logEvent:@"Tab Report"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataRefreshedAfterImport)
                                                 name:DATA_REFRESH_AFTER_IMPORT
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DATA_REFRESH_AFTER_IMPORT
                                                  object:nil];
}

- (void)dataRefreshedAfterImport
{
    [self loadData];
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
    // +1 for the report section
    return [self.activitiesByDay count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // sections for each day
    if (section < [self.activitiesByDay count]) {
        // +1 is for the day title cell
        return [[self.activitiesByDay objectAtIndex:section] count] + 1;
    }
    // section for report
    else {
        return [self.reportDictionary count] == 0 ?
                // no entries in the report -> header cell and 'no report' cell
                2 :
                // otherwise, number of entries + header cell
                [self.reportDictionary count] + 1;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // day sections
    if (indexPath.section < [self.activitiesByDay count]) {
        // case day title cell
        if (indexPath.row == 0) {
            
            return [self createDayHeaderCell:indexPath forTableView:tableView];
        }
        // case day activity
        else {
            
            return [self createDayActivityCell:indexPath forTableView:tableView];
        }
    }
    // report section
    else {
        if (indexPath.row == 0) {
            return [self createReportHeaderCell:indexPath forTableView:tableView];
        }
        else {
            if ([self.reportDictionary count] == 0) {
                return [self createReportNoneCell:indexPath forTableView:tableView];
            }
            // report line cell
            else {
                return [self createReportLineCell:indexPath forTableView:tableView];
            }
        }
    }
}

- (UITableViewCell*) createDayHeaderCell:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView
{
    static NSString *CellIdentifier = @"DayTitleCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
    return cell;
}

- (UITableViewCell*) createDayActivityCell:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView
{
    static NSString *CellIdentifier = @"ActivityCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
    return cell;
}

- (UITableViewCell*) createReportHeaderCell:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView
{
    static NSString *CellIdentifier = @"ReportHeader";
    return [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
}

- (UITableViewCell*) createReportLineCell:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView
{
    static NSString *CellIdentifier = @"ReportLine";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString* text  = [self.reportDictionary allKeys][indexPath.row - 1];
    NSNumber* hours = self.reportDictionary[text];
    
    UILabel* projectLabel = (UILabel*) [cell viewWithTag:100];
    UILabel* hoursLabel   = (UILabel*) [cell viewWithTag:101];
    
    projectLabel.text = text;
    hoursLabel.text = [NSString stringWithFormat:@"%.2f", [hours doubleValue]];
    
    return cell;
}

- (UITableViewCell*) createReportNoneCell:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView
{
    static NSString *CellIdentifier = @"ReportNone";
    return [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [self.activitiesByDay count]) {
        if (indexPath.row == 0) {
            return kDayCellHeight;
        }
        else {
            return [self heightForDayActivity:indexPath];
        }
    }
    // report section
    else {
        return [self heightForReportCell:indexPath];
    }
}

- (CGFloat) heightForDayActivity:(NSIndexPath*)indexPath
{
    Activity* activity = (Activity*)[self.activitiesByDay objectAtIndex:indexPath.section][indexPath.row - 1];
    NSString* trimmedNote = [activity.note stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedNote length] > 0) {
        return kActivityCellHeightNonEmptyNote;
    }
    else {
        return kActivityCellHeightEmptyNote;
    }
}

- (CGFloat) heightForReportCell:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0) {
        return 71.0;
    }
    else {
        return 27.0;
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
