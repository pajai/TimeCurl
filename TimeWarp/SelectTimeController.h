//
//  SelectTimeController.h
//  TimeWarp
//
//  Created by pat on 18.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraduationView.h"

@interface SelectTimeController : UIViewController {

    UIView* _currentSlot;
    int _currentStartY;
    int _currentDeltaY;
    BOOL _currentWasLargerThanOriginalMin; // original min is 1 hour

}

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet GraduationView* graduationView;
@property (nonatomic, strong) IBOutlet UILabel* currentSlotLabel;

@property (nonatomic, strong) NSMutableArray* timeslots;

@end
