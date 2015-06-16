/*
 
 Copyright 2013-2015 Patrick Jayet
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
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
