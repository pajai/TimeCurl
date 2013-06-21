//
//  DoublePair.h
//  TimeWarp
//
//  Created by pat on 20.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SlotInterval : NSObject

@property (readwrite) double begin;
@property (readwrite) double end;
@property (nonatomic, weak) UIView* view;

@end
