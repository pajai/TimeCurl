//
//  CustomTabBarController.m
//  TimeWarp
//
//  Created by pat on 05.06.2014.
//  Copyright (c) 2014 zuehlke. All rights reserved.
//

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
