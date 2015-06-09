/*
 
 Copyright (C) 2013-2015, Patrick Jayet
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
*/

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
