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

#import <UIKit/UIKit.h>
#import "Activity.h"
#import "SAMTextView.h"

@interface NewActivityController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray* projects;
@property (nonatomic, strong) Project* selectedProject;
@property (nonatomic, strong) Activity* activity;
@property (nonatomic, strong) NSArray* timeSlotIntervals;
@property (nonatomic, strong) NSDate* currentDate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subviewWidthConstraint;

@property (weak, nonatomic) IBOutlet UITextField* timeTextField;
@property (weak, nonatomic) IBOutlet SAMTextView* noteTextView;
@property (weak, nonatomic) IBOutlet UIPickerView* pickerView;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;

@end
