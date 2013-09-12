//
//  GraduationView.m
//  TimeWarp
//
//  Created by pat on 18.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "GraduationView.h"
#import "GeometryConstants.h"


@implementation GraduationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0);
    
    double startY = STARTY;
    double dY     = DELTAY;
    for (int i = 0; i <= 24; i++) {
        // hour graduation
        CGContextMoveToPoint   (context, 0,   startY + i * dY);
        CGContextAddLineToPoint(context, 250, startY + i * dY);
    }
    
    CGContextStrokePath(context);
    
}

@end
