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


@interface CurrentListController ()
- (void) loadData;
- (void) initCurrentDate;
- (void) updateUI;
- (BOOL) isToday;
@end

@implementation CurrentListController

#pragma mark custom logic methods

- (void) loadData
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSError* error = nil;
    self.activities = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // todo query for current period
    
    [self.tableView reloadData];
}

- (void) initCurrentDate
{
    self.currentDate = [NSDate date];
}

- (void) updateUI
{
    if ([self isToday]) {
        self.title = @"Today";
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        self.title = [dateFormatter stringFromDate:self.currentDate];
    }
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
        [self updateUI];
    }
}

- (IBAction)handleSwipeLeft:(UISwipeGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded) {
		NSLog(@"Current date plus one day");
        self.currentDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:self.currentDate];
        [self updateUI];
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

    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;

    [self loadData];
    [self initCurrentDate];
    [self updateUI];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
        
        Project* project = activity.project;
        titleLabel.text = [NSString stringWithFormat:@"%@ (%@)", project.name, project.subname];
        durationLabel.text = [NSString stringWithFormat:@"%f", [activity duration]];
        noteTextView.text = activity.note;
        
    }
    else {
        
        static NSString *CellIdentifier = @"NewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
    }
    
    return cell;
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
