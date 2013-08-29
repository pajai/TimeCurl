//
//  SelectDayController.h
//  TimeWarp
//
//  Created by pat on 29.08.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimesSquare.h"


@interface SelectDayController : UIViewController <TSQCalendarViewDelegate>

@property (strong,nonatomic) IBOutlet TSQCalendarView* calendarView;

@property (strong,nonatomic) NSDate* currentDate;

@end
