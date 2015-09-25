/*
 
 Copyright 2015 Jérémie Blaser
 
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

#import "ProjectSelectorController.h"
#import "CoreDataWrapper.h"
#import "UIConstants.h"
#import "UIUtils.h"
#import "NotificationConstants.h"
#import "Project+Additions.h"


#define kProjectCellHeight 44.0


@interface ProjectSelectorController ()

@property(nonatomic, strong) NSMutableArray* projects;
@property(nonatomic, strong) NSMutableSet* selectedSet;

@end


@implementation ProjectSelectorController

- (void) loadData
{
	self.projects = [NSMutableArray arrayWithArray:[[CoreDataWrapper shared] fetchAllProjects]];
	[self.tableView reloadData];
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
	if (_configController.selectedProjects) {
		_selectedSet = [[NSMutableSet alloc] initWithArray:_configController.selectedProjects];
	}
	else {
		_selectedSet = [[NSMutableSet alloc] initWithArray:_projects];
	}
	
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
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _projects.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"ProjectCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	UILabel* nameLabel    = (UILabel*)[cell viewWithTag:100];
	UIImageView* iconView = (UIImageView*)[cell viewWithTag:101];
	
	if (indexPath.row == 0) {
		cell.accessoryType = (_selectedSet.count == _projects.count) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		nameLabel.text = @"All";
		iconView.image = nil;
	}
	else{
		Project* project = _projects[indexPath.row-1];
		cell.accessoryType = [_selectedSet containsObject:project] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		nameLabel.text = [project label];
		iconView.image = [project imageWithDefaultName:@"icon-project-list"];
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kProjectCellHeight;
}


#pragma mark Table view delegates

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) { // All
		if (_selectedSet.count == _projects.count) {
			[_selectedSet removeAllObjects];
		}
		else {
			[_selectedSet addObjectsFromArray:_projects];
		}
	}
	else {
		Project* project = _projects[indexPath.row-1];
		if ([_selectedSet containsObject:project]) {
			[_selectedSet removeObject:project];
		}
		else {
			[_selectedSet addObject:project];
		}
	}
	[self.tableView reloadData];
	self.configController.selectedProjects = _selectedSet.allObjects;
}

@end
