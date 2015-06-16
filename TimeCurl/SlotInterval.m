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

#import "SlotInterval.h"
#import "TimeUtils.h"

@implementation SlotInterval

- (double) duration
{
    return self.end - self.begin;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@-%@",
                     [TimeUtils timeStringFromDouble:self.begin],
                     [TimeUtils timeStringFromDouble:self.end]];

}

@end
