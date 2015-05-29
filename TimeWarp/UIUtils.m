//
//  UIUtils.m
//  TimeWarp
//
//  Created by pat on 12.09.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "UIUtils.h"
#import "UIConstants.h"

@implementation UIUtils

+ (void)setEmptyFooterView:(UITableView*) tableView
{
    // not sure why we need to set the footer to an empty view, we get otherwise the separator repeating
    // itself when there are just few cells in the table
    [tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

+ (UIColor*)colorDarkGrey
{
    return [UIColor colorWithRed:83.0/255 green:90.0/255 blue:106.0/255 alpha:1.0];
}

+ (UIView*)accessoryView
{
    UIImage *image = [UIImage imageNamed:@"accessory"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tintColor = [UIConstants shared].middleBlueColor;
    return imageView;
}

@end
