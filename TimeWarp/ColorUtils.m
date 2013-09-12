//
//  ColorUtils.m
//  TimeWarp
//
//  Created by pat on 30.08.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "ColorUtils.h"


@implementation ColorUtils

+ (instancetype)shared
{
    static ColorUtils *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (sharedInstance == nil){
            sharedInstance = [[ColorUtils alloc] init];
        }
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // initialization
        _deepBlueColor = [UIColor colorWithRed:0.0 green:(121.0/255) blue:1.0 alpha:1.0];
        _lightBlueColor = [UIColor colorWithRed:(191.0/255) green:(221.0/255) blue:1.0 alpha:1.0];
    }
    return self;
}

@end
