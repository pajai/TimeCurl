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

#import "NewProjectController.h"
#import "AppDelegate.h"
#import "CoreDataWrapper.h"
#import "UIConstants.h"
#import "Flurry.h"
#import "IconSelectionController.h"
#import "UIApplication+AppDimensions.h"
#import "DeviceInfo.h"


@interface NewProjectController ()

@property (strong, nonatomic) NSString* iconName;

@end


@implementation NewProjectController

- (IBAction)donePressed:(id) sender
{
    if ([self.name.text length] == 0) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"At least the project name should be set!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    else {
        
        if (self.project == nil) {
            // new project
            
            Project* project = [[CoreDataWrapper shared] newProject];
            project.name = self.name.text;
            project.subname = self.subname.text;
            project.note = self.note.text;
            project.icon = self.iconName;

            [[CoreDataWrapper shared] saveContext];

        }
        else {
            // update existing project
            
            self.project.name = self.name.text;
            self.project.subname = self.subname.text;
            self.project.note = self.note.text;
            self.project.icon = self.iconName;
            
            [[CoreDataWrapper shared] saveContext];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction) selectingIconDone:(UIStoryboardSegue *)segue
{
    IconSelectionController* controller = segue.sourceViewController;
    self.iconName = controller.selectedIconName;
    [self updateIcon];
    DDLogDebug(@"Done selecting icon: %@", controller.selectedIconName);
}

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

    [self initChooseIconButton];
    
    [self copyIconName];
    [self updateView];
    
    self.note.placeholder = @"Optional";

}

- (void)copyIconName
{
    if (self.project.icon) {
        self.iconName = self.project.icon;
    }
}

- (void)initChooseIconButton
{
    self.iconButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.iconButton.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)updateView
{
    if (self.project != nil) {
        // pre-fill the fields
        self.name.text = self.project.name;
        self.subname.text = self.project.subname;
        self.note.text = self.project.note;
        
        self.title = @"Edit Project";
    }

    [self updateIcon];
}

- (void)updateIcon
{
    if (self.iconName) {
        self.iconView.image = [UIImage imageNamed:self.iconName];
        self.iconView.hidden = NO;
        self.iconLabel.hidden = YES;
    }
    else {
        self.iconView.hidden = YES;
        self.iconLabel.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.subviewWidthConstraint.constant = self.view.frame.size.width + [self horizontalOffset];
    
    [Flurry logEvent:@"Add Project"];
    
}

- (CGFloat)horizontalOffset
{
    /*
     * In iOS 8, we dont need to have the horizontal constraint larger than the parrent view,
     * while in iOS 7 we do need it.
     */
    return [DeviceInfo iosVersionAsFloat] >= 8.0f ? 0.0f : 16.0f;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    CGSize newSize = [UIApplication sizeInOrientation:toInterfaceOrientation];
    self.subviewWidthConstraint.constant = newSize.width + [self horizontalOffset];
    
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark State Restauration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name.text forKey:@"name"];
    [coder encodeObject:self.subname.text forKey:@"subname"];
    [coder encodeObject:self.note.text forKey:@"note"];
    [coder encodeObject:self.iconName forKey:@"iconName"];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    self.name.text = [coder decodeObjectForKey:@"name"];
    self.subname.text = [coder decodeObjectForKey:@"subname"];
    self.note.text = [coder decodeObjectForKey:@"note"];
    self.iconName = [coder decodeObjectForKey:@"iconName"];
    self.iconView.image = [UIImage imageNamed:self.iconName];
    [super decodeRestorableStateWithCoder:coder];
}

@end
