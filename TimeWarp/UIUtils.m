//
//  UIUtils.m
//  TimeWarp
//
//  Created by pat on 12.09.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "UIUtils.h"

@implementation UIUtils

- (instancetype)init
{
    self = [super init];
    if (self) {
        // initialization
    }
    return self;
}

+ (void) setEmptyFooterView:(UITableView*) tableView
{
    // not sure why we need to set the footer to an empty view, we get otherwise the separator repeating
    // itself when there are just few cells in the table
    [tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

@end
