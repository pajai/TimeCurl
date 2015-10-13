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
    self = [super initWithImage:[UIImage imageNamed:@"timeslot"] highlightedImage:[UIImage imageNamed:@"timeslot_pressed"]];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //DDLogDebug(@"Touch begin slot");
    self.touchStart = [[touches anyObject] locationInView:self];
    self.isResizingTop    = self.touchStart.y < kResizeThumbSize;
    self.isResizingBottom = self.bounds.size.height - self.touchStart.y < kResizeThumbSize;
    
    if (self.isResizingTop) {
        DDLogDebug(@"is resizing top start");
    }
    if (self.isResizingBottom) {
        DDLogDebug(@"is resizing bottom start");
    }
    if (self.isResizingTop || self.isResizingBottom) {
        self.highlighted = YES;
    }
    [self handleTouchMoved:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouchMoved:touches];
}

- (void)handleTouchMoved:(NSSet*)touches
{
    CGPoint currentPoint  = [[touches anyObject] locationInView:self];
    CGPoint previousPoint = [[touches anyObject] previousLocationInView:self];
    
    float deltaHeight = currentPoint.y - previousPoint.y;
    if (self.isResizingTop) {
        //DDLogDebug(@">>> TOP delta is %f, delta tot is %f", deltaHeight, self.deltaHeightTotal);
        [self.selectTimeController moveSlotTop:self.slotInterval withDelta:deltaHeight];
    }
    else if (self.isResizingBottom) {
        //DDLogDebug(@">>> BOTTOM delta is %f, delta tot is %f", deltaHeight, self.deltaHeightTotal);
        [self.selectTimeController moveSlotBottom:self.slotInterval withDelta:deltaHeight];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouchEnd];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    DDLogDebug(@"touches cancelled");
    
    [self handleTouchEnd];
}

- (void)handleTouchEnd
{
    if (self.isResizingTop) {
        DDLogDebug(@"is resizing top end");
    }
    if (self.isResizingBottom) {
        DDLogDebug(@"is resizing bottom end");
    }

    self.highlighted = NO;
    
    //DDLogDebug(@"Touch end slot");
    self.isResizingTop = NO;
    self.isResizingBottom = NO;
    [self.selectTimeController moveEndSlot:self.slotInterval];
}

@end
