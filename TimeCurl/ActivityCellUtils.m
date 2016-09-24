//
//  ActivityCellUtils.m
//  TimeCurl
//
//  Created by Patrick Jayet on 24/09/16.
//  Copyright © 2016 zuehlke. All rights reserved.
//

#import "ActivityCellUtils.h"
#import "Project.h"
#import "Project+Additions.h"
#import "UIUtils.h"

@implementation ActivityCellUtils

+ (UITableViewCell*) createDayHeaderCell:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView andActivitiesForDay:(NSArray*)activitiesForDay
{
    static NSString *cellIdentifier = @"DayTitleCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UILabel* dayLabel      = (UILabel*)[cell viewWithTag:100];
    UILabel* durationLabel = (UILabel*)[cell viewWithTag:101];
    
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterFullStyle;
    }
    
    Activity *activity = activitiesForDay.firstObject;
    NSString* dateString = [dateFormatter stringFromDate:activity.date];
    dayLabel.text = dateString;
    
    // TODO duration
    double dailyDuration = 0;
    for (Activity* act in activitiesForDay) {
        dailyDuration += [act duration];
    }
    durationLabel.text = [NSString stringWithFormat:@"%.2f", dailyDuration];
    return cell;
}

+ (UITableViewCell*) createDayActivityCell:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView andActivity:(Activity*)activity
{
    static NSString *cellIdentifier = @"ActivityCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureActivityCell:cell forIndexPath:indexPath andActivity:activity];
    
    return cell;
}

+ (void)configureActivityCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath andActivity:(Activity*)activity
{
    UILabel* titleLabel    = (UILabel*)[cell viewWithTag:100];
    UILabel* durationLabel = (UILabel*)[cell viewWithTag:101];
    UILabel* noteLabel     = (UILabel*)[cell viewWithTag:102];
    UIImageView* iconView  = (UIImageView*)[cell viewWithTag:103];
    
    cell.accessoryView = [UIUtils accessoryView];
    
    Project* project = activity.project;
    titleLabel.text = [project label];
    durationLabel.text = [NSString stringWithFormat:@"%.2f", [activity duration]];
    noteLabel.text = activity.note;
    [noteLabel sizeToFit];
    iconView.image = [project imageWithDefaultName:@"icon-report-list"];
}

@end
