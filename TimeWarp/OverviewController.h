//
//  OverviewControllerViewController.h
//  TimeWarp
//
//  Created by pat on 01.07.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverviewController : UITableViewController {
    
    NSDateFormatter* _dateFormatter;
    
}

@property (nonatomic, strong) NSMutableArray* activitiesByDay;

@property (nonatomic, strong) NSDate* currentDate;

@end
