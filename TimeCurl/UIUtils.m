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
