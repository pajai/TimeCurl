//
//  SelectTimeController.h
//  TimeWarp
//
//  Created by pat on 18.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraduationView.h"
#import "SlotInterval.h"


typedef NS_ENUM(NSInteger, TimeControllerState) {
    TimeControllerStateNothing,
    TimeControllerStateSetSlotBegin,
    TimeControllerStateSetSlotEnd,
    TimeControllerStateSlotDone,
    TimeControllerStateTuneSlot,
};


@interface SelectTimeController : UIViewController <UIGestureRecognizerDelegate> {

    SlotInterval* _currentSlotInterval;
    BOOL _currentWasLargerThanOriginalMin; // original min is 1 hour

}

@property (nonatomic, readwrite) TimeControllerState state;

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet GraduationView* graduationView;
@property (nonatomic, strong) IBOutlet UILabel* slotLabelStart;
@property (nonatomic, strong) IBOutlet UILabel* slotLabelEnd;

@property (nonatomic, strong) NSMutableArray* timeSlotIntervals; // as array of DoublePair*

- (void) moveSlotTop:(SlotInterval*)slotInterval withDelta:(CGFloat)delta;
- (void) moveSlotBottom:(SlotInterval*)slotInterval withDelta:(CGFloat)delta;
- (void) moveEndSlot:(SlotInterval*)slotInterval;

@end
