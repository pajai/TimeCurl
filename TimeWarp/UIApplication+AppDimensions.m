//
//  UIApplication+AppDimensions.m
//  TimeWarp
//
//  Created by pat on 03.10.2014.
//  Copyright (c) 2014 zuehlke. All rights reserved.
//

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
