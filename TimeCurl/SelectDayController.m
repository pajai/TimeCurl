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

#import "SelectDayController.h"
#import "TimeUtils.h"
#import "TSQTACalendarRowCell.h"
#import "CoreDataWrapper.h"


@interface SelectDayController ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultController;
@property (strong, nonatomic) NSDictionary *dayStringDictionary;
@end


@implementation SelectDayController

#pragma mark methods from TSQCalendarViewDelegate

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    self.currentDate = date;
    [self performSegueWithIdentifier:@"DaySelectionDone" sender:self];
}

- (BOOL)calendarView:(TSQCalendarView *)calendarView shouldDisplayEventMarkerForDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    NSString *dateString = [dateFormatter stringFromDate:date];
    return self.dayStringDictionary[dateString] != nil;
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

    [self initCalendarView];
    [self loadDaysWithActivities];
}

- (void)initCalendarView
{
    self.calendarView.rowCellClass = [TSQTACalendarRowCell class];
    self.calendarView.firstDate = [TimeUtils decrementYearForDate:self.currentDate];
    self.calendarView.lastDate  = [TimeUtils incrementYearForDate:self.currentDate];
    self.calendarView.backgroundColor = [UIColor colorWithRed:0.84f green:0.85f blue:0.86f alpha:1.0f];
    self.calendarView.pagingEnabled = YES;
    CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
    self.calendarView.contentInset = UIEdgeInsetsMake(0.0f, onePixel, 0.0f, onePixel);
    self.calendarView.selectedDate = self.currentDate;
    self.calendarView.delegate = self;
}

- (void)loadDaysWithActivities
{
    self.fetchedResultController = [[CoreDataWrapper shared] fetchResultControllerForActivitiesByDay];
    
    [self.fetchedResultController performFetch:nil];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (id<NSFetchedResultsSectionInfo> info in [self.fetchedResultController sections]) {
        dict[[info name]] = @1;
    }
    self.dayStringDictionary = dict;
}

- (void)viewDidLayoutSubviews;
{
    // Set the calendar view to show today date on start
    [self.calendarView scrollToDate:self.currentDate animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
