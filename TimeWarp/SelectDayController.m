//
//  SelectDayController.h
//  TimeWarp
//
//  Created by pat on 29.08.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "SelectDayController.h"
#import "TimeUtils.h"

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

    self.calendarView.firstDate = [TimeUtils decrementMonthForMonth:self.currentDate];
    self.calendarView.lastDate  = [TimeUtils incrementMonthForMonth:self.currentDate];
    self.calendarView.selectedDate = self.currentDate;
    self.calendarView.delegate = self;
    [self.calendarView scrollToDate:self.currentDate animated:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
