//
//  CurrentListController.m
//  TimeWarp
//
//  Created by pat on 18.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "CurrentListController.h"
#import "AppDelegate.h"
#import "Activity.h"
#import "Project.h"
#import "NewActivityController.h"
#import "CoreDataWrapper.h"
#import "SlotInterval.h"
#import "SelectDayController.h"
#import "DTCustomColoredAccessory.h"
#import "UIConstants.h"
#import "UIUtils.h"
#import "Flurry.h"
#import "NotificationConstants.h"


// TODO can we parameterize this?
#define kTextViewWidthPortrait  228.0
#define kTextViewWidthLandscape 476.0
#define kBodyFontSize 12.0
#define kMinCellTextViewHeight 32.0
#define kCellHeightAdditionWrtTextView 52.0
#define kNewCellHeight 82.0


@interface CurrentListController ()

@property (nonatomic,readwrite) NSInteger textViewWidth;

- (void) loadData;
- (void) initCurrentDate;
- (void) updateTitle;
- (BOOL) isToday;
- (CGFloat) textViewHeightForActivity:(Activity*)activity;
- (CGFloat) heightOfText:(NSString *)textToMesure widthOfTextView:(CGFloat)width withFont:(UIFont*)font;

@end

@implementation CurrentListController

#pragma mark action for unwind segue from SelectDayController

- (IBAction)doneSelectingDay:(UIStoryboardSegue *)segue
{
    NSLog(@"Done selecting day");
    
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
    self.currentDate = [NSDate date];
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
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:self.currentDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    return [today isEqual:otherDate];
}

- (IBAction)handleSwipeRight:(UISwipeGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded) {
		NSLog(@"Current date minus one day");
        self.currentDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:self.currentDate];
        [self loadData];
        [self updateTitle];
    }
}

- (IBAction)handleSwipeLeft:(UISwipeGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded) {
		NSLog(@"Current date plus one day");
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

    self.textViewWidth = kTextViewWidthPortrait;
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
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DATA_REFRESH_AFTER_IMPORT
                                                  object:nil];
}

- (void)dataRefreshedAfterImport
{
    [self loadData];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    self.textViewWidth = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? kTextViewWidthPortrait : kTextViewWidthLandscape;
    
    NSLog(@"Interface orientation change");
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        
        static NSString *CellIdentifier = @"ActivityCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Activity* activity = [self.activities objectAtIndex:indexPath.row];
        UILabel* titleLabel      = (UILabel*)[cell viewWithTag:100];
        UILabel* durationLabel   = (UILabel*)[cell viewWithTag:101];
        UITextView* noteTextView = (UITextView*)[cell viewWithTag:102];
        
        cell.accessoryView = [DTCustomColoredAccessory accessoryWithSingleColor:[UIConstants shared].deepBlueColor];
        
        Project* project = activity.project;
        titleLabel.text = [NSString stringWithFormat:@"%@ (%@)", project.name, project.subname];
        durationLabel.text = [NSString stringWithFormat:@"%.2f", [activity duration]];
        noteTextView.text = activity.note;
        
    }
    else {
        
        static NSString *CellIdentifier = @"NewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        Activity* activity = [self.activities objectAtIndex:indexPath.row];
        
        // cell size: add kCellHeightAdditionWrtTextView point to text view height
        CGFloat height = [self textViewHeightForActivity:activity] + kCellHeightAdditionWrtTextView;
        return height;
    }
    else {
        return kNewCellHeight;
    }
}

- (CGFloat) textViewHeightForActivity:(Activity*)activity
{
    /*
     * TODO: we could use dynamic font size, see e.g. [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
     *       sticking to fix size system fonts for now
     */
    
    // size of text view, but at least kMinCellTextViewHeight
    UIFont * bodyFont = [UIFont systemFontOfSize:kBodyFontSize];
    CGFloat textViewHeight = [self heightOfText:activity.note widthOfTextView:self.textViewWidth withFont:bodyFont];
    textViewHeight = textViewHeight < kMinCellTextViewHeight ? kMinCellTextViewHeight : textViewHeight;
    return textViewHeight;
}

- (CGFloat) heightOfText:(NSString *)textToMesure widthOfTextView:(CGFloat)width withFont:(UIFont*)font
{
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:font forKey: NSFontAttributeName];
    CGRect rect = [textToMesure boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:stringAttributes context:nil];
    return rect.size.height;
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
