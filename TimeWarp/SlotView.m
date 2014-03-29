//
//  SlotView.m
//  TimeWarp
//
//  Created by pat on 26.03.2014.
//  Copyright (c) 2014 zuehlke. All rights reserved.
//

#import "SlotView.h"
#import "SelectTimeController.h"

#define kResizeThumbSize 25

@interface SlotView ()

@property (readwrite) BOOL isResizingTop;
@property (readwrite) BOOL isResizingBottom;
@property (readwrite) CGPoint touchStart;

@end


@implementation SlotView

- (id)init
{
    self = [super initWithImage:[UIImage imageNamed:@"timeslot"]];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchStart = [[touches anyObject] locationInView:self];
    self.isResizingTop    = self.touchStart.y < kResizeThumbSize;
    self.isResizingBottom = self.bounds.size.height - self.touchStart.y < kResizeThumbSize;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@">>> END moving slot");
    [self.selectTimeController moveEndSlot:self.slotInterval];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint currentPoint  = [[touches anyObject] locationInView:self];
    CGPoint previousPoint = [[touches anyObject] previousLocationInView:self];
    
    float deltaHeight = currentPoint.y - previousPoint.y;
    if (self.isResizingTop) {
        //NSLog(@">>> TOP delta is %f, delta tot is %f", deltaHeight, self.deltaHeightTotal);
        [self.selectTimeController moveSlotTop:self.slotInterval withDelta:deltaHeight];
    }
    else if (self.isResizingBottom) {
        //NSLog(@">>> BOTTOM delta is %f, delta tot is %f", deltaHeight, self.deltaHeightTotal);
        [self.selectTimeController moveSlotBottom:self.slotInterval withDelta:deltaHeight];
    }
}

@end
