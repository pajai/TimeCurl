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



@interface SelectTimeController : UIViewController <UIGestureRecognizerDelegate, GraduationViewDelegate> {

    SlotInterval* _currentSlotInterval;
    BOOL _currentWasLargerThanOriginalMin; // original min is 1 hour

}

@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet GraduationView* graduationView;
@property (weak, nonatomic) IBOutlet UILabel* slotLabelStart;
@property (weak, nonatomic) IBOutlet UILabel* slotLabelEnd;

@property (nonatomic, strong) NSMutableArray* timeSlotIntervals; // as array of DoublePair*

- (void) moveSlotTop:(SlotInterval*)slotInterval withDelta:(CGFloat)delta;
- (void) moveSlotBottom:(SlotInterval*)slotInterval withDelta:(CGFloat)delta;
- (void) moveEndSlot:(SlotInterval*)slotInterval;

@end
