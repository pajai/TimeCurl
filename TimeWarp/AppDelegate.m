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

#import "AppDelegate.h"
#import "Flurry.h"
#import "ModelSerializer.h"
#import "TimeUtils.h"
#import "PrefsConstants.h"
#import "UIUtils.h"

@interface AppDelegate ()

// used for a data import
@property (strong, nonatomic) NSURL* tmpFileURL;

- (void) customizeAppearance;
@end


@implementation AppDelegate

#pragma mark custom private methods

- (void) customizeAppearance
{
    self.window.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],
      NSForegroundColorAttributeName,
      nil]];
    [[UINavigationBar appearance] setBarTintColor:[UIUtils colorDarkGrey]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor whiteColor]];

    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabbar-background"]];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbar-selected"]];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    
    // title text in the tab bar always white (also when not selected)
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                        [UIColor whiteColor],
                                                                        NSForegroundColorAttributeName,
                                                                        nil]
                               forState:UIControlStateNormal];
    
    UITabBarController* tabBarController = (UITabBarController*)self.window.rootViewController;
    for (UITabBarItem* item in tabBarController.tabBar.items) {
        item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

#pragma mark usual app delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self writeDefaultPrefs];
    
    [self customizeAppearance];
    
    [self setupFlurry];
    
    [self handleImportData:launchOptions];
    
    [self handleAutoscreenshotsDataImport];
    
    return YES;
}

- (void) writeDefaultPrefs
{
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    BOOL changed = NO;
    if ([prefs integerForKey:PREFS_PERIODICITY_NB] == 0) {
        [prefs setInteger:1 forKey:PREFS_PERIODICITY_NB];
        changed = YES;
    }
    if (![prefs stringForKey:PREFS_PERIODICITY_UNIT]) {
        [prefs setObject:@"month" forKey:PREFS_PERIODICITY_UNIT];
        changed = YES;
    }
    if (![prefs objectForKey:PREFS_PERIOD_START]) {
        NSDate* date = [NSDate date];
        NSDate* month = [TimeUtils monthForDate:date];
        [prefs setObject:month forKey:PREFS_PERIOD_START];
        changed = YES;
    }
    if (changed) {
        [prefs synchronize];
    }
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (url && [url isFileURL]) {
        self.tmpFileURL = url;
        [self showImportConfirmation];
    }
    return YES;
}

- (void) handleImportData:(NSDictionary*)launchOptions
{
    NSURL* url = (NSURL*)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if (url && [url isFileURL]) {
        self.tmpFileURL = url;
        [self showImportConfirmation];
    }
}

- (void) handleAutoscreenshotsDataImport
{
#ifdef AUTOSCREENSHOTS
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data-screenshots" ofType:@"timecurl"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    ModelSerializer *modelSerializer = [[ModelSerializer alloc] init];
    [modelSerializer deleteAllData];
    [modelSerializer importFileFromUrl:url];
#endif
}

#define PHASE_IMPORT_CONFIRMATION 1
#define PHASE_DELETE_CONFIRMATION 2

- (void) showImportConfirmation
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Import" message:@"Are you sure that you want to import this data set?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete existing data and import", @"Don't modify existing data and import", nil];
    alert.tag = PHASE_IMPORT_CONFIRMATION;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == PHASE_IMPORT_CONFIRMATION) {
        if (buttonIndex == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to overwrite the current data (cannot be undone)?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.tag = PHASE_DELETE_CONFIRMATION;
            [alert show];
        }
        else if (buttonIndex == 2) {
            [self importData];
        }
    }
    else if (alertView.tag == PHASE_DELETE_CONFIRMATION) {
        if (buttonIndex == 1) {
            [self deleteAndImportData];
        }
    }
}

- (void)importData
{
    NSURL* tmpFileURL = self.tmpFileURL;
    self.tmpFileURL = nil;
    [[[ModelSerializer alloc] init] importFileFromUrl:tmpFileURL];
}

- (void)deleteAndImportData
{
    NSURL* tmpFileURL = self.tmpFileURL;
    self.tmpFileURL = nil;
    ModelSerializer *modelSerializer = [[ModelSerializer alloc] init];
    [modelSerializer deleteAllData];
    [modelSerializer importFileFromUrl:tmpFileURL];
}

- (void)setupFlurry
{
    //note: iOS only allows one crash reporting tool per app; if using another, set to: NO
    [Flurry setCrashReportingEnabled:YES];
    
    // Replace YOUR_API_KEY with the api key in the downloaded package
    [Flurry startSession:@"T7WKQGFT7ZG2WDHZCK62"];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark State Restauration

-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

@end
