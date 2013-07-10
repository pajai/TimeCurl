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
#import "ModelUtils.h"
#import "SlotInterval.h"

// TODO can we parameterize this?
#define kTextViewWidth 300


@interface CurrentListController ()
- (void) loadData;
- (void) initCurrentDate;
- (void) updateTitle;
- (BOOL) isToday;
- (CGFloat) textViewHeightForActivity:(Activity*)activity;
- (CGFloat) heightOfText:(NSString *)textToMesure widthOfTextView:(CGFloat)width withFont:(UIFont*)font;
@end

@implementation CurrentListController

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
    self.activities = [NSMutableArray arrayWithArray:[ModelUtils fetchActivitiesForDate:self.currentDate]];
    
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
    
    // title
    self.title = [NSString stringWithFormat:@"%@ (%.2f)", dateString, totTime];
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

#pragma mark transitions

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NewActivityController* controller = (NewActivityController*)segue.destinationViewController;
    // don't set controller.currentDate -> taken from the activity
 
    if ([segue.identifier isEqualToString:@"EditActivity"]) {
        
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        Activity* activity = [self.activities objectAtIndex:indexPath.row];
        controller.activity = activity;
        
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

        CGFloat textViewHeight = [self textViewHeightForActivity:activity];
        
        // adapt note text view height
        CGRect frame = noteTextView.frame;
        frame.size.height = textViewHeight; //noteTextView.contentSize.height;
        noteTextView.frame = frame;
        
        // adapt green rectangle height
        UIView* greenBackground  = (UIView*)[cell viewWithTag:103];
        frame = greenBackground.frame;
        frame.size.height = textViewHeight + 20;
        greenBackground.frame = frame;
        
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
        
        // cell size: add 28 point to text view height
        return [self textViewHeightForActivity:activity] + 28;
    }
    else {
        return 57;
    }
}

- (CGFloat) textViewHeightForActivity:(Activity*)activity
{
    // size of text view, but at least 45
    UIFont * bodyFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    CGFloat textViewHeight = [self heightOfText:activity.note widthOfTextView:kTextViewWidth withFont:bodyFont];
    textViewHeight = textViewHeight < 45 ? 45 : textViewHeight;
    return textViewHeight;
}

- (CGFloat) heightOfText:(NSString *)textToMesure widthOfTextView:(CGFloat)width withFont:(UIFont*)font
{
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:font forKey: NSFontAttributeName];
    CGRect rect = [textToMesure boundingRectWithSize:CGSizeMake(width - 20, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:stringAttributes context:nil];
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
        [ModelUtils deleteObject:activity];
        [ModelUtils saveContext];
        
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
