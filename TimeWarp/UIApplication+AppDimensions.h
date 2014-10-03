//
//  UIApplication+AppDimensions.h
//  TimeWarp
//
//  Created by pat on 03.10.2014.
//  Copyright (c) 2014 zuehlke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIApplication(AppDimensions)

+(CGSize) currentSize;
+(CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation;

@end
