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
