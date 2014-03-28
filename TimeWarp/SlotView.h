//
//  SlotView.h
//  TimeWarp
//
//  Created by pat on 26.03.2014.
//  Copyright (c) 2014 zuehlke. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectTimeController;
@class SlotInterval;

@interface SlotView : UIImageView

@property (weak, nonatomic) SelectTimeController* selectTimeController;
@property (weak, nonatomic) SlotInterval* slotInterval;

@end
