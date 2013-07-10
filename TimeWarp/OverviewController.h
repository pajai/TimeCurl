//
//  OverviewControllerViewController.h
//  TimeWarp
//
//  Created by pat on 01.07.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailComposeHandler.h"
#import "MailComposeCallbackDelegate.h"

@interface OverviewController : UITableViewController <UIAlertViewDelegate, MailComposeCallbackDelegate> {
    
    NSDateFormatter* _dateFormatter;
    
}

@property (nonatomic, strong) MailComposeHandler* mailComposeHandler;

@property (nonatomic, strong) NSMutableArray* activitiesByDay;

@property (nonatomic, strong) NSDate* currentDate;

@end
