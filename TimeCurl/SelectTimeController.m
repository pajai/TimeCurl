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

#import "SelectTimeController.h"
#import "GeometryConstants.h"
#import <tgmath.h>
#import "Flurry.h"
#import "SlotView.h"


typedef NS_ENUM(NSInteger, TimeLabelType) {
    TimeLabelStart,
    TimeLabelEnd,
};


@implementation SelectTimeController

#pragma mark custom methods

- (void) initDailyCalendar
{
    self.scrollView.contentOffset = CGPointMake(0, 319);
    
    self.slotLabelStart.alpha = 0;
    self.slotLabelEnd.alpha = 0;
    
    for (SlotInterval* slotInterval in self.timeSlotIntervals) {
        slotInterval.view = [self createSlotView:slotInterval];
    }
    
    self.slotLabelStart.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.slotLabelEnd.font   = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}

- (void) initGraduationLabels
{
    double startY = STARTY;
    double dY     = DELTAY;
    UIFont * font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    for (int i = 0; i <= 24; i++) {
        CGRect frame = CGRectMake(10, startY + i * dY - 10, 50, 20);
        UILabel* label = [[UILabel alloc] initWithFrame:frame];
        label.font = font;
        label.text = [NSString stringWithFormat:@"%02d:00", i];
        [self.scrollView addSubview:label];
    }

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    // allow the two gesture recognizers to recognize gestures at the same time
    return YES;
}

- (void) moveSlotTop:(SlotInterval*)slotInterval withDelta:(CGFloat)delta
{
    slotInterval.begin += delta/DELTAY;
    [self adaptViewForSlot:slotInterval];
    [self showTimeLabels:slotInterval];
}

- (void) moveSlotBottom:(SlotInterval*)slotInterval withDelta:(CGFloat)delta
{
    slotInterval.end += delta/DELTAY;
    [self adaptViewForSlot:slotInterval];
    [self showTimeLabels:slotInterval];
}

- (void) moveEndSlot:(SlotInterval*)slotInterval
{
    slotInterval.begin = [self roundToQuarterHour:slotInterval.begin];
    slotInterval.end   = [self roundToQuarterHour:slotInterval.end];
    [self correctNegativeInterval:slotInterval];
    [self adaptViewForSlot:slotInterval];
    [self mergeSlots];
    [self hideTimeLabels];
}

- (void) defineSlotStart:(NSSet*)touches
{
    int slotIndex = [self getSlotIndexForTouches:touches];
    [self createSlotIntervalWithBegin:(0.25 * slotIndex) andEnd:(0.25 * slotIndex + 1)];
    [self setCurrentSlotViewHighlighted:YES];
    [self adaptViewForSlot:_currentSlotInterval];
    [self showTimeLabels:_currentSlotInterval];
}

- (void) defineSlotMove:(NSSet*)touches
{
    // start of the slot is adapted
    int slotIndex = [self getSlotIndexForTouches:touches];
    _currentSlotInterval.begin = 0.25 * slotIndex;
    _currentSlotInterval.end = 0.25 * slotIndex + 1;
    [self correctNegativeInterval:_currentSlotInterval];
    [self adaptViewForSlot:_currentSlotInterval];
    [self showTimeLabels:_currentSlotInterval];
}

- (void) defineSlotEnd:(NSSet*)touches
{
    [self setCurrentSlotViewHighlighted:NO];
    _currentSlotInterval = nil;
    [self mergeSlots];
    [self hideTimeLabels];
}

- (void) setCurrentSlotViewHighlighted:(BOOL)highlighted
{
    if (_currentSlotInterval) {
        SlotView* slotView = (SlotView*)_currentSlotInterval.view;
        slotView.highlighted = highlighted;
    }
}


- (void) correctNegativeInterval:(SlotInterval*)slotInterval
{
    if (slotInterval.end < slotInterval.begin) {
        double tmp = slotInterval.begin;
        slotInterval.begin = slotInterval.end;
        slotInterval.end = tmp;
    }
}

- (int) getSlotIndexForTouches:(NSSet*)touches
{
    CGPoint location = [[touches anyObject] locationInView:self.graduationView];
    int slotIndex      = [self computeSlotIndex:location.y];
    return slotIndex;
}

- (int) getSlotIndex:(UILongPressGestureRecognizer*)sender
{
    NSUInteger numberOfTouches = [sender numberOfTouches];
    CGPoint bottom = CGPointMake(0, 0);
    for (int i = 0; i < numberOfTouches; i++) {
        CGPoint location = [sender locationOfTouch:i inView:self.graduationView];
        bottom = location.y >= bottom.y ? location : bottom;
    }
    
    int slotIndex      = [self computeSlotIndex:bottom.y];
    return slotIndex;
}

- (int) computeSlotIndex:(CGFloat)y
{
    return (int)((y - STARTY)/(DELTAY/4));
}

- (void) showTimeLabels:(SlotInterval*)slotInterval
{
    [self setTimeLabel:self.slotLabelStart withTime:slotInterval.begin forType:TimeLabelStart];
    [self setTimeLabel:self.slotLabelEnd   withTime:slotInterval.end   forType:TimeLabelEnd];
}

- (void) hideTimeLabels
{
    self.slotLabelStart.alpha = 0.0;
    self.slotLabelEnd.alpha   = 0.0;
}

- (void) setTimeLabel:(UILabel*)label withTime:(double)time forType:(TimeLabelType)labelType
{
    int yPos;
    
    if (labelType == TimeLabelStart) {
        yPos = [self yPosForSlot:time] - 20;
    }
    else /* TimeLabelEnd */ {
        yPos = [self yPosForSlot:time] + 5;
    }
    
    label.frame = CGRectMake(label.frame.origin.x, yPos, label.frame.size.width, label.frame.size.height);
    double roundedTime = [self roundToQuarterHour:time];
    label.text = [self timeToString:roundedTime];
    label.alpha = 1.0;
}

- (NSString*) timeToString:(double)time
{
    int totMin = 15 * 4 * time;
    int hours  = totMin / 60;
    int min    = totMin % 60;
    return [NSString stringWithFormat:@"%02d:%02d", hours, min];

}

- (UIView*) createSlotView:(SlotInterval*)slotInterval
{
    SlotView* currentSlotView = [[SlotView alloc] init];
    currentSlotView.selectTimeController = self;
    currentSlotView.slotInterval = slotInterval;
    [self.graduationView addSubview:currentSlotView];
    return currentSlotView;
}

- (void) createSlotIntervalWithBegin:(double)begin andEnd:(double)end
{
    _currentSlotInterval = [[SlotInterval alloc] init];
    _currentSlotInterval.begin = begin;
    _currentSlotInterval.end = end;
    _currentSlotInterval.view = [self createSlotView:_currentSlotInterval];
    [self.timeSlotIntervals addObject:_currentSlotInterval];

}

- (void) adaptViewForSlot:(SlotInterval*)slot
{
    double yStart = [self yPosForSlot:slot.begin];
    double yEnd   = [self yPosForSlot:slot.end];
    double height = yEnd - yStart;
    slot.view.frame = CGRectMake(0, yStart, self.graduationView.frame.size.width - 10, height);
}

- (double) yPosForSlot:(double)time
{
    return STARTY + (time * DELTAY);
}

- (double) roundToQuarterHour:(double)time
{
    return round(time * 4.0) / 4.0;
}

- (void) mergeSlots
{
    [self.timeSlotIntervals sortUsingComparator:^(id a, id b) {
        SlotInterval* slotA = (SlotInterval*)a;
        SlotInterval* slotB = (SlotInterval*)b;
        return slotA.begin < slotB.begin ? NSOrderedAscending :
               (slotA.begin > slotB.begin ? NSOrderedDescending : NSOrderedSame);
    }];
    
    SlotInterval* previousSlot = nil;
    NSMutableArray* toRemove = [NSMutableArray array];
    DDLogDebug(@">>> merging slots");
    for (SlotInterval* slot in self.timeSlotIntervals) {
        DDLogDebug(@"slot %.2f, %.2f", slot.begin, slot.end);
        if (previousSlot != nil) {
            
            // current slot is contained in previous one -> remove current
            if (previousSlot.begin <= slot.begin && previousSlot.end >= slot.end) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [self removeSlot:slot withRemoveList:toRemove];
                [UIView commitAnimations];
            }
            // previous slot is contained in current one -> remove previous
            else if (slot.begin <= previousSlot.begin && slot.end >= previousSlot.end) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [self removeSlot:previousSlot withRemoveList:toRemove];
                [UIView commitAnimations];
                previousSlot = slot;
            }
            // overlap of previous and current slot -> merge them into previous + remove current
            else if (previousSlot.end >= slot.begin) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                previousSlot.end = slot.end;
                [self adaptViewForSlot:previousSlot];
                [self removeSlot:slot withRemoveList:toRemove];
                [UIView commitAnimations];
            }
            else {
                // no overlap
                previousSlot = slot;
            }
            
        }
        else {
            previousSlot = slot;
        }
    }
    [self.timeSlotIntervals removeObjectsInArray:toRemove];
}

- (void)removeSlot:(SlotInterval*)slot withRemoveList:(NSMutableArray*)toRemove
{
    [toRemove addObject:slot];
    slot.view.alpha = 0.0;
    
    // we don't remove slot.view from its superview, otherwise we don't get the
    // animation effect, there are not so many views for it to be a problem.
}

#pragma mark methods from UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // is nil for a new activity -> create a mutable array
    if (self.timeSlotIntervals == nil) {
        self.timeSlotIntervals = [NSMutableArray array];
    }

    [self initDailyCalendar];
    [self initGraduationLabels];
    
    self.graduationView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (SlotInterval* slotInterval in self.timeSlotIntervals) {
        [self adaptViewForSlot:slotInterval];
    }

    [Flurry logEvent:@"Enter Time Span"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
