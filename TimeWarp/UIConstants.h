//
//  ColorUtils.h
//  TimeWarp
//
//  Created by pat on 30.08.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIConstants : NSObject

@property (strong, nonatomic) UIColor* deepBlueColor;
@property (strong, nonatomic) UIColor* middleBlueColor;
@property (strong, nonatomic) UIColor* lightBlueColor;

+ (instancetype)shared;

@end
