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
    //NSLog(@"Touch begin slot");
    self.touchStart = [[touches anyObject] locationInView:self];
    self.isResizingTop    = self.touchStart.y < kResizeThumbSize;
    self.isResizingBottom = self.bounds.size.height - self.touchStart.y < kResizeThumbSize;
    
    if (self.isResizingTop) {
        NSLog(@"is resizing top start");
    }
    if (self.isResizingBottom) {
        NSLog(@"is resizing bottom start");
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
        //NSLog(@">>> TOP delta is %f, delta tot is %f", deltaHeight, self.deltaHeightTotal);
        [self.selectTimeController moveSlotTop:self.slotInterval withDelta:deltaHeight];
    }
    else if (self.isResizingBottom) {
        //NSLog(@">>> BOTTOM delta is %f, delta tot is %f", deltaHeight, self.deltaHeightTotal);
        [self.selectTimeController moveSlotBottom:self.slotInterval withDelta:deltaHeight];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouchEnd];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches cancelled");
    
    [self handleTouchEnd];
}

- (void)handleTouchEnd
{
    if (self.isResizingTop) {
        NSLog(@"is resizing top end");
    }
    if (self.isResizingBottom) {
        NSLog(@"is resizing bottom end");
    }

    self.highlighted = NO;
    
    //NSLog(@"Touch end slot");
    self.isResizingTop = NO;
    self.isResizingBottom = NO;
    [self.selectTimeController moveEndSlot:self.slotInterval];
}

@end
