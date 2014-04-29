//
//  AddProjectController.h
//  TimeWarp
//
//  Created by pat on 17.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Project.h"
#import "SAMTextView.h"

@interface NewProjectController : UIViewController <NSFetchedResultsControllerDelegate>

- (IBAction)donePressed:(id) sender;

@property (nonatomic, strong) Project* project;

@property (nonatomic, strong) IBOutlet UITextField* name;
@property (nonatomic, strong) IBOutlet UITextField* subname;
@property (nonatomic, strong) IBOutlet SAMTextView* note;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UIButton *iconButton;

@end
