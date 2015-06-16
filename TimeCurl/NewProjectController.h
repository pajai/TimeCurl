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
#import <CoreData/CoreData.h>
#import "Project.h"
#import "SAMTextView.h"

@class TPKeyboardAvoidingScrollView;

@interface NewProjectController : UIViewController <NSFetchedResultsControllerDelegate>

- (IBAction)donePressed:(id) sender;

@property (nonatomic, strong) Project* project;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subviewWidthConstraint;

@property (weak, nonatomic) IBOutlet UITextField* name;
@property (weak, nonatomic) IBOutlet UITextField* subname;
@property (weak, nonatomic) IBOutlet SAMTextView* note;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UIButton *iconButton;

@end
