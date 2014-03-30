//
//  ConfigureReportControllerViewController.h
//  TimeWarp
//
//  Created by pat on 29.03.2014.
//  Copyright (c) 2014 zuehlke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigureReportController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSDate* periodStart;
@property (readwrite) NSInteger periodicityNb;
@property (strong, nonatomic) NSString* periodicityUnit;

@end
