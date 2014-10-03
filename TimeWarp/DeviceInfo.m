//
//  DeviceInfo.m
//  TimeWarp
//
//  Created by pat on 03.10.2014.
//  Copyright (c) 2014 zuehlke. All rights reserved.
//

#import "DeviceInfo.h"

@implementation DeviceInfo

+ (CGFloat)iosVersionAsFloat
{
    return [[UIDevice currentDevice].systemVersion floatValue];
}

@end
