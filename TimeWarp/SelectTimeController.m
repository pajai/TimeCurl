//
//  SelectTimeController.m
//  TimeWarp
//
//  Created by pat on 18.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "SelectTimeController.h"
#import "GeometryConstants.h"
#import <tgmath.h>


@interface SelectTimeController ()
- (void) initDailyCalendar;
- (UIView*) createSlotView;
- (void) createSlotIntervalWithBegin:(double)begin andEnd:(double)end;
- (void) adaptViewForSlot:(SlotInterval*)slot;
- (void) mergeSlots;
- (void) removeSlot:(SlotInterval*)slot withRemoveList:(NSMutableArray*)toRemove;
- (double) yStartForSlot:(SlotInterval*)slot;
- (double) yEndForSlot:(SlotInterval*)slot;
@end

@implementation SelectTimeController

#pragma mark custom methods

- (void) initDailyCalendar
{
    self.scrollView.contentSize = CGSizeMake(320, 1000);
    self.scrollView.contentOffset = CGPointMake(0, 319);
    self.scrollView.scrollEnabled = YES;
    
    self.currentSlotLabel.alpha = 0;
    
    for (SlotInterval* slotInterval in self.timeSlotIntervals) {
        slotInterval.view = [self createSlotView];
        [self adaptViewForSlot:slotInterval];
    }
}

- (IBAction)donePressed:(id)sender
{
    self.scrollView.contentSize = CGSizeMake(320, 1000);
    self.scrollView.contentOffset = CGPointMake(0, 319);
    NSLog(@"Done pressed");
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    // allow the two gesture recognizers to recognize gestures at the same time
    return YES;
}

- (IBAction)handlePress:(UILongPressGestureRecognizer*)sender
{
    int numberOfTouches = [sender numberOfTouches];
    //CGPoint bottom   = [sender locationOfTouch:(numberOfTouches-1) inView:self.graduationView];
    CGPoint bottom = CGPointMake(0, 0);
    for (int i = 0; i < numberOfTouches; i++) {
        CGPoint location = [sender locationOfTouch:i inView:self.graduationView];
        bottom = location.y >= bottom.y ? location : bottom;
    }

    int slotIndex      = (int)((bottom.y - STARTY)/(DELTAY/4));
    
    NSString* stateStr = nil;
    if (sender.state == UIGestureRecognizerStateBegan) {
        stateStr = @"began";
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        stateStr = @"ended";
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        stateStr = @"changed";
    }
    NSLog(@"press (%d, %0f, %0f, %@)", numberOfTouches, bottom.x, bottom.y, stateStr);

    // kStateNothing -> kStateSetSlotBegin
    if (state == kStateNothing && numberOfTouches == 1 && sender.state == UIGestureRecognizerStateBegan) {
        state = kStateSetSlotBegin;

        [self createSlotIntervalWithBegin:(0.25 * slotIndex) andEnd:(0.25 * slotIndex + 1)];
        
        _currentWasLargerThanOriginalMin = NO;

    }

    // kStateSetSlotBegin -> kStateSetSlotBegin
    if (state == kStateSetSlotBegin && numberOfTouches == 1 && sender.state == UIGestureRecognizerStateChanged) {
        // state remains the same
        
        // start of the slot is adapted
        _currentSlotInterval.begin = 0.25 * slotIndex;
        _currentSlotInterval.end = 0.25 * slotIndex + 1;
    }

    // kStateSetSlotBegin -> kStateSetSlotEnd
    if (state == kStateSetSlotBegin && numberOfTouches == 2 && sender.state == UIGestureRecognizerStateBegan) {
        state = kStateSetSlotEnd;
    }

    // kStateSetSlotEnd -> kStateSetSlotEnd
    if (state == kStateSetSlotEnd && numberOfTouches == 2 &&
        (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged)) {
        // state does not change

        // modify the end time, cannot be less than 0.5 hour
        double originalMin = _currentWasLargerThanOriginalMin ? 0.5 : 1.0;
        BOOL beyondMin = slotIndex >= _currentSlotInterval.begin + originalMin;
        if (beyondMin) {
            _currentSlotInterval.end = 0.25 * slotIndex;
            _currentWasLargerThanOriginalMin = YES;
        }
        
    }
    
    // kStateSetSlotBegin -> kStateNothing ||
    // kStateSetSlotEnd -> kStateSlotDone
    if ((state == kStateSetSlotBegin && numberOfTouches == 1 && sender.state == UIGestureRecognizerStateEnded) ||
        (state == kStateSetSlotEnd && numberOfTouches == 2 && sender.state == UIGestureRecognizerStateEnded)) {
        
        state = kStateNothing;
        
        _currentSlotInterval = nil;
        
        [self mergeSlots];

    }
    
    // if we are editing the begin or end -> adapt view
    if ((state == kStateSetSlotBegin || state == kStateSetSlotEnd) && _currentSlotInterval != nil) {

        [self adaptViewForSlot:_currentSlotInterval];

    }
    
    // time label
    CGRect frame = self.currentSlotLabel.frame;
    if (state == kStateSetSlotBegin || state == kStateSetSlotEnd) {
        int yPos;
        
        if (state == kStateSetSlotBegin) {
            yPos = [self yStartForSlot:_currentSlotInterval] - 20;
        }
        else /* kStateSetSlotEnd */ {
            yPos = [self yEndForSlot:_currentSlotInterval] + 5;
        }
        
        self.currentSlotLabel.frame = CGRectMake(frame.origin.x, yPos, frame.size.width, frame.size.height);
        int totMin = 15 * slotIndex;
        int hours  = totMin / 60;
        int min    = totMin % 60;
        NSString *currentStr = [NSString stringWithFormat:@"%02d:%02d", hours, min];
        self.currentSlotLabel.text = currentStr;
        self.currentSlotLabel.alpha = 1.0;
        
    }
    else {
        self.currentSlotLabel.alpha = 0.0;
    }
    
}

- (UIView*) createSlotView
{
    UIView* currentSlotView = [[UIView alloc] init];
    currentSlotView.backgroundColor = [UIColor colorWithRed:124.0/255 green:177.0/255 blue:1.0 alpha:1.0];
    currentSlotView.alpha = 0.4;
    [self.graduationView addSubview:currentSlotView];
    return currentSlotView;
}

- (void) createSlotIntervalWithBegin:(double)begin andEnd:(double)end
{
    _currentSlotInterval = [[SlotInterval alloc] init];
    _currentSlotInterval.begin = begin;
    _currentSlotInterval.end = end;
    _currentSlotInterval.view = [self createSlotView];
    [self.timeSlotIntervals addObject:_currentSlotInterval];

}

- (void) adaptViewForSlot:(SlotInterval*)slot
{
    double yStart = [self yStartForSlot:slot];
    double yEnd   = [self yEndForSlot:slot];
    double height = yEnd - yStart;
    slot.view.frame = CGRectMake(0, yStart, 250, height);
}

- (double) yStartForSlot:(SlotInterval*)slot
{
    return STARTY + (slot.begin * DELTAY);
}

- (double) yEndForSlot:(SlotInterval*)slot
{
    return STARTY + (slot.end * DELTAY);
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
    NSLog(@">>> merging slots");
    for (SlotInterval* slot in self.timeSlotIntervals) {
        NSLog(@"slot %.2f, %.2f", slot.begin, slot.end);
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
    
    state = kStateNothing;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.scrollView.contentSize = CGSizeMake(320, 1000);
    self.scrollView.contentOffset = CGPointMake(0, 319);
    self.scrollView.scrollEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
