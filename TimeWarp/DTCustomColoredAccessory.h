//
//  DTCustomColoredAccessory.h
//  TimeWarp
//
//  Created by pat on 29.08.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DTCustomColoredAccessory : UIControl
{
	UIColor *_accessoryColor;
	UIColor *_highlightedColor;
}

@property (nonatomic, retain) UIColor *accessoryColor;
@property (nonatomic, retain) UIColor *highlightedColor;

// return a custom accessory according to the given color (hightlighted color can be set separately)
+ (DTCustomColoredAccessory *)accessoryWithColor:(UIColor *)color;

// return a custom accessory according to the given color (hightlighted color same as given one)
+ (DTCustomColoredAccessory *)accessoryWithSingleColor:(UIColor *)color;

@end
