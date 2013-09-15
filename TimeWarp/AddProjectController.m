//
//  AddProjectController.m
//  TimeWarp
//
//  Created by pat on 17.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "AddProjectController.h"
#import "AppDelegate.h"
#import "CoreDataWrapper.h"
#import "UIConstants.h"

@interface AddProjectController ()

@end

@implementation AddProjectController

- (IBAction)donePressed:(id) sender
{
    if ([self.name.text length] == 0 || [self.subname.text length] == 0) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"At least the project name and sub name should be set!"
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

            [[CoreDataWrapper shared] saveContext];

        }
        else {
            // update existing project
            
            self.project.name = self.name.text;
            self.project.subname = self.subname.text;
            self.project.note = self.note.text;
            
            [[CoreDataWrapper shared] saveContext];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    
    if (self.project != nil) {
        
        // pre-fill the fields
        self.name.text = self.project.name;
        self.subname.text = self.project.subname;
        self.note.text = self.project.note;
        
        self.title = @"Edit Project";
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark State Restauration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name.text forKey:@"name"];
    [coder encodeObject:self.subname.text forKey:@"subname"];
    [coder encodeObject:self.note.text forKey:@"note"];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    self.name.text = [coder decodeObjectForKey:@"name"];
    self.subname.text = [coder decodeObjectForKey:@"subname"];
    self.note.text = [coder decodeObjectForKey:@"note"];
    [super decodeRestorableStateWithCoder:coder];
}

@end
