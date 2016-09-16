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

// this class is used only in the time selection controller (SelectTimeController)
// TODO: doppelt gemoppelt mit TimeSlot, refactor?

@interface SlotInterval : NSObject

@property (readwrite) double begin;
@property (readwrite) double end;
@property (readwrite) BOOL readOnly;
@property (nonatomic, weak) UIView* view;

- (double) duration;

@end
