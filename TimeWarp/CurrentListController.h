//
//  CurrentListController.h
//  TimeWarp
//
//  Created by pat on 18.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "StoreChangeDelegate.h"


@interface CurrentListController : UITableViewController <NSFetchedResultsControllerDelegate, StoreChangeDelegate>

@property (nonatomic, strong) NSMutableArray* activities;

@property (nonatomic, strong) NSDate* currentDate;

// backup of the + button item (during edition)
@property (nonatomic, strong) UIBarButtonItem* backupButtonRight;

@end
