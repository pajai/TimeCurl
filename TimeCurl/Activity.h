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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Project, TimeSlot;

@interface Activity : NSManagedObject

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) Project *project;
@property (nonatomic, retain) NSSet *timeslots;
@end

@interface Activity (CoreDataGeneratedAccessors)

- (void)addTimeslotsObject:(TimeSlot *)value;
- (void)removeTimeslotsObject:(TimeSlot *)value;
- (void)addTimeslots:(NSSet *)values;
- (void)removeTimeslots:(NSSet *)values;

- (double)duration;

@end
