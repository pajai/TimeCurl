/*
 
 Copyright 2013-2015 Patrick Jayet
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
*/

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
