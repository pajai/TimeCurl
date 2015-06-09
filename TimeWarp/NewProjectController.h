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
