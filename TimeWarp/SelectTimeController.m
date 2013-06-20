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
@end

@implementation SelectTimeController

#pragma mark custom methods

- (void) initDailyCalendar
{
    self.scrollView.contentSize = CGSizeMake(320, 1000);
    self.scrollView.contentOffset = CGPointMake(0, 319);
    self.scrollView.scrollEnabled = YES;
    
    self.currentSlotLabel.alpha = 0;
}

- (IBAction)donePressed:(id)sender
{
    self.scrollView.contentSize = CGSizeMake(320, 1000);
    self.scrollView.contentOffset = CGPointMake(0, 319);
    NSLog(@"Done pressed");
}

- (IBAction)handleTap:(UITapGestureRecognizer*)sender
{
    int numberOfTouches = [sender numberOfTouches];
    CGPoint lastTouch   = [sender locationOfTouch:(numberOfTouches-1) inView:self.graduationView];
    NSLog(@"tap (%d, %0f,%0f)", numberOfTouches, lastTouch.x, lastTouch.y);
}

- (IBAction)handlePress:(UILongPressGestureRecognizer*)sender
{
    int numberOfTouches = [sender numberOfTouches];
    CGPoint lastTouch   = [sender locationOfTouch:(numberOfTouches-1) inView:self.graduationView];
    NSLog(@"long press (%d, %0f,%0f)", numberOfTouches, lastTouch.x, lastTouch.y);

    double yModulo = fmod((lastTouch.y - STARTY), (DELTAY/4));
    int yMult      = (int)((lastTouch.y - STARTY)/(DELTAY/4));
    double ySlot   = lastTouch.y - yModulo;
    NSLog(@"y mult: %d, y slot: %f", yMult, ySlot);

    // gesture start
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@">>>>> state begin");
        _currentSlot = [[UIView alloc] init];
        _currentSlot.backgroundColor = [UIColor colorWithRed:124.0/255 green:177.0/255 blue:1.0 alpha:1.0];
        _currentSlot.alpha = 0.4;
        [self.graduationView addSubview:_currentSlot];
        
        _currentStartY = ySlot;
        _currentDeltaY = DELTAY;
        _currentWasLargerThanOriginalMin = NO;

    }
    // not the start -> derive the end position, cannot be less than 0.5 hour
    else {

        double originalMin = _currentWasLargerThanOriginalMin ? 0.5 : 1.0;
        _currentDeltaY = ySlot >= _currentStartY + (DELTAY * originalMin) ? ySlot - _currentStartY : _currentDeltaY;
        if (!_currentWasLargerThanOriginalMin && ySlot >= _currentStartY + DELTAY * originalMin) {
            _currentWasLargerThanOriginalMin = YES;
        }

    }
    
    _currentSlot.frame = CGRectMake(0, _currentStartY, 250, _currentDeltaY);
    
    CGRect frame = self.currentSlotLabel.frame;
    self.currentSlotLabel.frame = CGRectMake(frame.origin.x, ySlot - 20, frame.size.width, frame.size.height);
    int totMin = 15 * yMult;
    int hours  = totMin / 60;
    int min    = totMin % 60;
    NSString *currentStr = [NSString stringWithFormat:@"%02d:%02d", hours, min];
    self.currentSlotLabel.text = currentStr;
    self.currentSlotLabel.alpha = 1.0;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@">>>>> state ended");
        
        self.currentSlotLabel.alpha = 0.0;
    }
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

    self.timeslots = [NSMutableArray array];
    [self initDailyCalendar];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [self viewWillAppear:animated];
//    
//    self.scrollView.scrollEnabled = YES;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
