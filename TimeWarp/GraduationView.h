//
//  GraduationView.h
//  TimeWarp
//
//  Created by pat on 18.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

@protocol GraduationViewDelegate <NSObject>

- (void) defineSlotStart:(NSSet*)touches;
- (void) defineSlotMove:(NSSet*)touches;
- (void) defineSlotEnd:(NSSet*)touches;

@end


#import <UIKit/UIKit.h>

@interface GraduationView : UIView

@property (strong, nonatomic) id<GraduationViewDelegate> delegate;

@end
