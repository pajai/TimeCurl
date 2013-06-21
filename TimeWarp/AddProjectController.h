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

@interface AddProjectController : UIViewController <NSFetchedResultsControllerDelegate>

- (IBAction)donePressed:(id) sender;

@property (nonatomic, strong) Project* project;

@property (nonatomic, strong) IBOutlet UITextField* name;
@property (nonatomic, strong) IBOutlet UITextField* subname;
@property (nonatomic, strong) IBOutlet UITextView* note;

@end
