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

#import "UIApplication+AppDimensions.h"
#import "DeviceInfo.h"

@implementation UIApplication(AppDimensions)

+(CGSize) currentSize
{
    return [UIApplication sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+(CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation
{
    UIApplication *application = [UIApplication sharedApplication];
    UIInterfaceOrientation currentOrientation = application.statusBarOrientation;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    if ([DeviceInfo iosVersionAsFloat] >= 8.0f) {
        /*
         * In iOS 8, we get the bounds corrected for the current orientation
         */
        if (UIInterfaceOrientationIsLandscape(currentOrientation) != UIInterfaceOrientationIsLandscape(orientation))
        {
            size = CGSizeMake(size.height, size.width);
        }
    }
    else {
        /*
         * In iOS 7, we always get the bounds for the portrait orientation
         */
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            size = CGSizeMake(size.height, size.width);
        }
    }
    
    /*
     * Not sure if we need this, since we don't know if the status bar will be shown or hidden in the new orientation
     */
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return size;
}

@end
