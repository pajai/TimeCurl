//
//  ActivityCellUtils.h
//  TimeCurl
//
//  Created by Patrick Jayet on 24/09/16.
//  Copyright © 2016 zuehlke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Activity.h"

@interface ActivityCellUtils : NSObject

+ (UITableViewCell*) createDayHeaderCell:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView andActivitiesForDay:(NSArray*)activitiesForDay;

+ (UITableViewCell*) createDayActivityCell:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView andActivity:(Activity*)activity;

+ (void)configureActivityCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath andActivity:(Activity*)activity;

@end
