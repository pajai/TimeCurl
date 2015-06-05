//
//  OverviewControllerViewController.m
//  TimeWarp
//
//  Created by pat on 01.07.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "ReportController.h"
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
#import "ConfigureReportController.h"
#import "PrefsConstants.h"
#import "Project+Additions.h"
#import "OrderedDictionary.h"
#import "AutoscreenshotsUtils.h"


#define kDayCellHeight 23

#define kReportHeaderHeight 43
#define kReportLineHeight 27
#define kReportFooterHeight 16


@interface ReportController ()

@property (strong, nonatomic) NSMutableDictionary* offscreenCells;

@property (nonatomic, strong) MailComposeHandler* mailComposeHandler;
@property (nonatomic, strong) NSArray* activitiesByDay;
@property (nonatomic, strong) NSDate* periodStart;
@property (strong, nonatomic) NSDictionary* reportDictionary;

@property (readwrite) NSInteger periodicityNb;
@property (strong, nonatomic) NSString* periodicityUnit;

@property (strong, nonatomic) NSDateFormatter* dateFormatter;

@end

@implementation ReportController


#pragma mark custom methods

- (void) loadData
{
    NSDate* nextPeriodStart = [TimeUtils incrementDate:self.periodStart forUnitString:self.periodicityUnit andNb:self.periodicityNb];
    
    NSArray* activities = [[CoreDataWrapper shared] fetchActivitiesBetweenDate:self.periodStart andExclusiveDate:nextPeriodStart];
    [self createReportForActivities:activities];
    
    self.activitiesByDay = [[CoreDataWrapper shared] groupActivitiesByDay:activities];
    
    [self.tableView reloadData];
}

- (void) createReportForActivities:(NSArray*)activities
{
    // sum of activities of each project
    MutableOrderedDictionary* report = [[MutableOrderedDictionary alloc] init];
    for (Activity* activity in activities) {
        NSString* projectLabel = [activity.project label];
        if (!report[projectLabel]) {
            report[projectLabel] = @0.0;
        }
        report[projectLabel] = [NSNumber numberWithDouble:[report[projectLabel] doubleValue] + activity.duration];
    }
    
    // total of all projects
    double total = 0.0;
    for (NSString* key in [report allKeys]) {
        NSNumber* projectTotal = report[key];
        total += [projectTotal doubleValue];
    }
    report[@"Total"] = [NSNumber numberWithDouble:total];
    
    self.reportDictionary = report;
}

- (void) initDateAndPeriodicity
{

#ifdef AUTOSCREENSHOTS
    self.periodicityNb = 1;
    self.periodicityUnit = @"month";
    self.periodStart = [AutoscreenshotsUtils monthlyDateForScreenshots];
#else
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    self.periodicityNb   = [prefs integerForKey:PREFS_PERIODICITY_NB];
    self.periodicityUnit = [prefs stringForKey: PREFS_PERIODICITY_UNIT];
    
    self.periodStart = [prefs objectForKey:PREFS_PERIOD_START];
    NSDate* newPeriodStart = [self computeCurrentPeriodStart:self.periodStart withNb:self.periodicityNb andUnitString:self.periodicityUnit];
    if (![newPeriodStart isEqualToDate:self.periodStart]) {
        [prefs setObject:newPeriodStart forKey:PREFS_PERIOD_START];
        [prefs synchronize];
        self.periodStart = newPeriodStart;
    }
#endif
    
}

- (void) persisteReportSettings
{
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.periodicityUnit forKey:PREFS_PERIODICITY_UNIT];
    [prefs setInteger:self.periodicityNb forKey:PREFS_PERIODICITY_NB];
    [prefs setObject:self.periodStart forKey:PREFS_PERIOD_START];
    [prefs synchronize];
}

- (NSDate*) computeCurrentPeriodStart:(NSDate*)date withNb:(NSInteger)nb andUnitString:(NSString*)unitString
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents* dateComponents = [TimeUtils dateComponentForUnitString:unitString withNb:nb];

    NSDate* today = [NSDate date];
    NSDate* previousDate = date;
    while ([date compare:today] == NSOrderedAscending) {
        previousDate = date;
        date = [cal dateByAddingComponents:dateComponents toDate:date options:0];
    }

    /* previousDate is the last date before today, in the periodicity given by unitString, nb and periodStart */
    return previousDate;
}

- (void) updateTitle
{
    // date
    NSString* dateString = [self getDateString];
    
    // change the nav title
    // rem: if we change self.title, we change also the tab title
    self.navigationItem.title = dateString;
}

- (NSString*) getDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    NSString* dateString = nil;
    if ([self.periodicityUnit isEqualToString:@"month"]) {
        [dateFormatter setDateFormat:@"MMM yyyy"];
        dateString = [dateFormatter stringFromDate:self.periodStart];
    }
    else {
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        dateString = [dateFormatter stringFromDate:self.periodStart];
        NSString* plural = self.periodicityNb == 1 ? @"" : @"s";
        dateString = [NSString stringWithFormat:@"%@, %li %@%@", dateString, (long)self.periodicityNb, self.periodicityUnit, plural];
    }
    return dateString;
}

- (IBAction) configureReportDone:(UIStoryboardSegue *)segue
{
    NSLog(@"Done configuring report");
    
    ConfigureReportController* configureReportController = (ConfigureReportController*)segue.sourceViewController;
    self.periodicityNb = configureReportController.periodicityNb;
    self.periodicityUnit = configureReportController.periodicityUnit;
    self.periodStart = configureReportController.periodStart;

    [self persisteReportSettings];
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
		NSLog(@"Current date minus one period");
        self.periodStart = [TimeUtils decrementDate:self.periodStart forUnitString:self.periodicityUnit andNb:self.periodicityNb];
        [self loadData];
        [self updateTitle];
    }
}

- (IBAction)handleSwipeLeft:(UISwipeGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded) {
		NSLog(@"Current date plus one period");
        self.periodStart = [TimeUtils incrementDate:self.periodStart forUnitString:self.periodicityUnit andNb:self.periodicityNb];
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
    self.mailComposeHandler.attachmentName = [self filenameCustom];
    
    NSArray* projects = [[CoreDataWrapper shared] fetchAllProjects];
    NSData* data = [[[ModelSerializer alloc] init] serializeProjects:projects];
    
    self.mailComposeHandler.attachmentData = data;
    self.mailComposeHandler.attachmentMime = @"application/timecurl";
    self.mailComposeHandler.delegate = self;
    //
    [self.mailComposeHandler prepareMailComposeViewController];
    [self presentViewController:self.mailComposeHandler.mailComposeController animated:YES completion:nil];
}

- (NSString*)filenameCustom
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString* dateStr = [dateFormatter stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"AllActivities-%@.timecurl", dateStr];
}

- (void) exportCurrentMonthInCsv
{
    // filename
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString* dateStr = [dateFormatter stringFromDate:self.periodStart];
    NSString* fileName = [NSString stringWithFormat:@"activities-%@.csv", dateStr];
    
    NSString* title = [NSString stringWithFormat:@"Time tracking for %@", dateStr];
    
    [self exportActivitiesInCsv:self.activitiesByDay withFileName:fileName andSubject:title all:NO];
}

- (void) exportAllActivitiesInCsv
{
    NSArray* activities = [[CoreDataWrapper shared] fetchAllActivities];
    [self exportActivitiesInCsv:activities withFileName:@"all-activities.csv" andSubject:@"All activities" all:YES];
}

- (void) exportActivitiesInCsv:(NSArray*)activities withFileName:(NSString*)fileName andSubject:(NSString*)title all:(BOOL)all
{
    
    // construct CSV file
    NSString* tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    CHCSVWriter* writer = [[CHCSVWriter alloc] initForWritingToCSVFile:tempPath];
    
    [writer writeField:@"Date"];
    [writer writeField:@"Project"];
    [writer writeField:@"Activity Note"];
    [writer writeField:@"Duration [h]"];
    [writer finishLine];
    
    if (all) {
        for (Activity *activity in activities) {
            [self writeActivity:activity forWriter:writer];
        }
    }
    else {
        for (NSArray* dayActivities in activities) {
            for (Activity* activity in dayActivities) {
                [self writeActivity:activity forWriter:writer];
            }
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

- (void)writeActivity:(Activity*)activity forWriter:(CHCSVWriter*)writer
{
    NSDateFormatter *dateFormatter = [self dayDateFormatter];
    [writer writeField:[dateFormatter stringFromDate:activity.date]];
    [writer writeField:[activity.project label]];
    [writer writeField:activity.note];
    [writer writeField:[NSString stringWithFormat:@"%.2f", [activity duration]]];
    [writer finishLine];
}

- (NSDateFormatter*)dayDateFormatter
{
    static NSDateFormatter *activityDateFormatter = nil;
    
    if (!activityDateFormatter) {
        activityDateFormatter = [[NSDateFormatter alloc] init];
        [activityDateFormatter setDateStyle:NSDateFormatterShortStyle];
    }

    return activityDateFormatter;
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
    
    if ([segue.identifier isEqualToString:@"EditActivity"]) {

        NewActivityController* controller = (NewActivityController*)segue.destinationViewController;
        // don't set controller.currentDate -> taken from the activity
        
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        Activity* activity = [[self.activitiesByDay objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row - 1];
        controller.activity = activity;
        
    }
    else if ([segue.identifier isEqualToString:@"ConfigureReport"]) {
        
        ConfigureReportController* controller = (ConfigureReportController*)segue.destinationViewController;
        
        controller.periodStart = self.periodStart;
        controller.periodicityNb = self.periodicityNb;
        controller.periodicityUnit = self.periodicityUnit;
        
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
    
    [self initDateAndPeriodicity];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterFullStyle;

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
    // section for report
    if (section == 0) {
        return [self.reportDictionary count] == 0 ?
        // no entries in the report -> header cell, 'no report' cell and footer cell
        3 :
        // otherwise, number of entries + header cell + footer cell
        [self.reportDictionary count] + 2;
    }
    // sections for each day
    else {
        // +1 is for the day title cell
        return [[self.activitiesByDay objectAtIndex:section - 1] count] + 1;
    }
    
}

- (UITableViewCell*)retrieveOffscreenCellForIdentifier:(NSString*)reuseIdentifier
{
    UITableViewCell* cell = self.offscreenCells[reuseIdentifier];
    if (!cell) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self heightForReportCell:indexPath];
    }
    else {
        if (indexPath.row == 0) {
            return kDayCellHeight;
        }
        else {
            // don't do the full computation for an activity cell
            return 80.0f;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self heightForReportCell:indexPath];
    }
    else {
        if (indexPath.row == 0) {
            return kDayCellHeight;
        }
        else {
            return [self heightForDayActivity:indexPath];
        }
    }
}

- (CGFloat) heightForDayActivity:(NSIndexPath*)indexPath
{
    NSString* identifier = @"ActivityCell";
    
    UITableViewCell* cell = [self retrieveOffscreenCellForIdentifier:identifier];
    [self configureActivityCell:cell forIndexPath:indexPath];
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1.0f;
}

- (CGFloat) heightForReportCell:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0) {
        return kReportHeaderHeight;
    }
    else {
        NSInteger nbReportRows = [self tableView:self.tableView numberOfRowsInSection:indexPath.section];
        if (indexPath.row + 1 < nbReportRows) {
            return kReportLineHeight;
        }
        else {
            return kReportFooterHeight;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isReportSection:indexPath]) {
        if (indexPath.row == 0) {
            return [self createReportHeaderCell:indexPath forTableView:tableView];
        }
        else {
            if ([self reportHasOnlyTotal]) {
                if (indexPath.row == 1) {
                    return [self createReportNoneCell:indexPath forTableView:tableView];
                }
                else {
                    return [self createReportFooterCell:indexPath forTableView:tableView];
                }
            }
            // report line cell
            else {
                if (indexPath.row > [self.reportDictionary count]) {
                    return [self createReportFooterCell:indexPath forTableView:tableView];
                }
                else {
                    return [self createReportLineCell:indexPath forTableView:tableView];
                }
            }
        }
    }
    // day sections
    else {
        // case day title cell
        if (indexPath.row == 0) {
            
            return [self createDayHeaderCell:indexPath forTableView:tableView];
        }
        // case day activity
        else {
            
            return [self createDayActivityCell:indexPath forTableView:tableView];
        }
    }
}

- (BOOL)isReportSection:(NSIndexPath*)indexPath
{
    return indexPath.section == 0;
}

- (BOOL)reportHasOnlyTotal
{
    return [self.reportDictionary count] == 1;
}

- (UITableViewCell*) createDayHeaderCell:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView
{
    static NSString *cellIdentifier = @"DayTitleCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UILabel* dayLabel      = (UILabel*)[cell viewWithTag:100];
    UILabel* durationLabel = (UILabel*)[cell viewWithTag:101];
    
    NSArray* activitiesForDay = [self.activitiesByDay objectAtIndex:indexPath.section - 1];
    
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
    static NSString *cellIdentifier = @"ActivityCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureActivityCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (void)configureActivityCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath
{
    Activity* activity = (Activity*)[self.activitiesByDay objectAtIndex:indexPath.section - 1][indexPath.row - 1];
    
    UILabel* titleLabel    = (UILabel*)[cell viewWithTag:100];
    UILabel* durationLabel = (UILabel*)[cell viewWithTag:101];
    UILabel* noteLabel     = (UILabel*)[cell viewWithTag:102];
    UIImageView* iconView  = (UIImageView*)[cell viewWithTag:103];
    
    cell.accessoryView = [DTCustomColoredAccessory accessoryWithSingleColor:[UIConstants shared].middleBlueColor];
    
    Project* project = activity.project;
    titleLabel.text = [project label];
    durationLabel.text = [NSString stringWithFormat:@"%.2f", [activity duration]];
    noteLabel.text = activity.note;
    [noteLabel sizeToFit];
    iconView.image = [project imageWithDefaultName:@"icon-report-list"];
}

- (UITableViewCell*) createReportHeaderCell:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView
{
    static NSString *cellIdentifier = @"ReportHeader";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UILabel* reportLabel = (UILabel*) [cell viewWithTag:100];
    NSString* dateString = [self getDateString];
    NSString* title = [NSString stringWithFormat:@"Report for %@", dateString];
    reportLabel.text = title;
    
    return cell;
}

- (UITableViewCell*) createReportLineCell:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView
{
    static NSString *cellIdentifierNotLast = @"ReportLine";
    static NSString *cellIdentifierLast    = @"ReportLineLast";
    
    NSInteger lineIndex = indexPath.row - 1;
    NSString *cellIdentifier = [self isLastReportLine:indexPath] ? cellIdentifierLast : cellIdentifierNotLast;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString* text  = [self.reportDictionary allKeys][lineIndex];
    NSNumber* hours = self.reportDictionary[text];
    
    UILabel* projectLabel = (UILabel*) [cell viewWithTag:100];
    UILabel* hoursLabel   = (UILabel*) [cell viewWithTag:101];
    
    projectLabel.text = text;
    hoursLabel.text = [NSString stringWithFormat:@"%.2f", [hours doubleValue]];
    
    return cell;
}

- (BOOL)isLastReportLine:(NSIndexPath*)indexPath
{
    NSInteger lineIndex = indexPath.row - 1;
    NSArray* keys = [self.reportDictionary allKeys];
    return lineIndex + 1 == [keys count];
}

- (UITableViewCell*) createReportNoneCell:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView
{
    static NSString *cellIdentifier = @"ReportNone";
    return [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
}

- (UITableViewCell*) createReportFooterCell:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView
{
    static NSString *cellIdentifier = @"ReportFooter";
    return [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
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
