//
//  UITextFieldWithInset.m
//  TimeWarp
//
//  Created by pat on 12.09.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "UITextFieldWithInset.h"

@implementation UITextFieldWithInset

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Pat: subclass of UITextField to be able to have an inner margin (inset)
// when we set a custom background image

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 5, bounds.origin.y + 8,
                      bounds.size.width - 10, bounds.size.height - 16);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
