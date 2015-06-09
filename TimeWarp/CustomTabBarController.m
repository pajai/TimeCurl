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

#import "CustomTabBarController.h"
#import "PrefsConstants.h"


#define INDEX_PROJECT_TAB 2


@implementation CustomTabBarController

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

    [self setSelectedTabFirstLaunch];
}

- (void) setSelectedTabFirstLaunch
{
	BOOL firstLaunchFlagSet = [[NSUserDefaults standardUserDefaults] boolForKey:PREFS_FIRST_LAUNCH_SELECT_TAB];
    if (!firstLaunchFlagSet) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREFS_FIRST_LAUNCH_SELECT_TAB];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.selectedIndex = INDEX_PROJECT_TAB;
    }
}

@end
