/*
 
 Copyright (C) 2013-2015, Patrick Jayet
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
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
