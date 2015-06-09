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
    NSLog(@"Done selecting icon: %@", controller.selectedIconName);
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
