//
//  CurrentListController.h
//  TimeWarp
//
//  Created by pat on 18.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface CurrentListController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@property (nonatomic, strong) NSArray* activities;

@property (nonatomic, strong) NSDate* currentDate;

@end
