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
