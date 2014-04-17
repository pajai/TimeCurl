//
//  DoublePair.h
//  TimeWarp
//
//  Created by pat on 20.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <Foundation/Foundation.h>

// this class is used only in the time selection controller (SelectTimeController)
// TODO: doppelt gemoppelt mit TimeSlot, refactor?

@interface SlotInterval : NSObject

@property (readwrite) double begin;
@property (readwrite) double end;
@property (nonatomic, weak) UIView* view;

- (double) duration;

@end
