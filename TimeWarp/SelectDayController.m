//
//  SelectDayController.h
//  TimeWarp
//
//  Created by pat on 29.08.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "SelectDayController.h"
#import "TimeUtils.h"
#import "TSQTACalendarRowCell.h"

@interface SelectDayController ()

@end

@implementation SelectDayController

#pragma mark methods from TSQCalendarViewDelegate

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    self.currentDate = date;
    [self performSegueWithIdentifier:@"DaySelectionDone" sender:self];
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
