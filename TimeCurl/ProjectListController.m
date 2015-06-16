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

#import "ProjectListController.h"
#import "Project+Additions.h"
#import "AppDelegate.h"
#import "NewProjectController.h"
#import "CoreDataWrapper.h"
#import "UIConstants.h"
#import "UIUtils.h"
#import "Flurry.h"
#import "NotificationConstants.h"


#define kProjectCellHeight 44.0
#define kNewCellHeight 82.0


@interface ProjectListController ()
@end


@implementation ProjectListController

- (void) loadData
{
    self.projects = [NSMutableArray arrayWithArray:[[CoreDataWrapper shared] fetchAllProjects]];
    [self.tableView reloadData];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView setSeparatorColor:[[UIConstants shared] lightBlueColor]];

    [UIUtils setEmptyFooterView:self.tableView];
}

- (void) storeDidChange
{
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
    [CoreDataWrapper shared].storeChangeDelegate = self;
    
    [Flurry logEvent:@"Tab Projects"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataRefreshedAfterImport)
                                                 name:DATA_REFRESH_AFTER_IMPORT
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DATA_REFRESH_AFTER_IMPORT
                                                  object:nil];
    [super viewDidDisappear:animated];
}

- (void) dataRefreshedAfterImport
{
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Transitions

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditProject"]) {
        
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        Project* project = [self.projects objectAtIndex:indexPath.row];
        NewProjectController* controller = (NewProjectController*)segue.destinationViewController;
        controller.project = project;

    }
}

#pragma mark - Edit Mode

- (IBAction)enterEditMode:(id)sender
{
    // Add the done button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
											  initWithTitle:@"Done"
											  style:UIBarButtonItemStyleDone
											  target:self
											  action:@selector(leaveEditMode:)];

    self.backupButtonRight = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
	
    [self.tableView setEditing:YES animated:YES];
   
}

- (IBAction)leaveEditMode:(id)sender
{
    // Add the edit button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Edit"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(enterEditMode:)];

    self.navigationItem.rightBarButtonItem = self.backupButtonRight;
    self.backupButtonRight = nil;

    [self.tableView setEditing:NO animated:YES];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.projects count];
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {

        static NSString *CellIdentifier = @"ProjectCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.accessoryView = [UIUtils accessoryView];
        
        UILabel* nameLabel    = (UILabel*)[cell viewWithTag:100];
        UIImageView* iconView = (UIImageView*)[cell viewWithTag:101];
        
        Project* project = [self.projects objectAtIndex:indexPath.row];
        nameLabel.text = [project label];
        iconView.image = [project imageWithDefaultName:@"icon-project-list"];

    }
    else {
        static NSString *CellIdentifier = @"NewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        return kProjectCellHeight;
    }
    else {
        return kNewCellHeight;
    }

}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.rowToDelete = indexPath;
        Project* project = [self.projects objectAtIndex:self.rowToDelete.row];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                        message:[NSString stringWithFormat:@"Are you sure that you want to delete the project '%@ %@'? It will also delete all activities using that project.", project.name, project.subname]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Delete", nil];
        [alert show];
        
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    Project* p = [self.projects objectAtIndex:fromIndexPath.row];
    [self.projects removeObject:p];
    [self.projects insertObject:p atIndex:toIndexPath.row];
    [[CoreDataWrapper shared] setProjectSortOrder:self.projects];
}

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && self.rowToDelete != nil) {
        
        Project* project = [self.projects objectAtIndex:self.rowToDelete.row];
        [self.projects removeObject:project];
        [[CoreDataWrapper shared] deleteObject:project];
        [[CoreDataWrapper shared] saveContext];
        
        [self.tableView deleteRowsAtIndexPaths:@[self.rowToDelete] withRowAnimation:UITableViewRowAnimationFade];

    }
    
    // free the ref to the previously saved index path
    self.rowToDelete = nil;
    
}

@end
