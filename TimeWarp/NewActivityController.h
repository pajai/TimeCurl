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
