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

#import "UIConstants.h"


@implementation UIConstants

+ (instancetype)shared
{
    static UIConstants *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (sharedInstance == nil){
            sharedInstance = [[UIConstants alloc] init];
        }
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // initialization
        _deepBlueColor  = [UIColor colorWithRed:0.0 green:(121.0/255) blue:1.0 alpha:1.0];
        _middleBlueColor = [UIColor colorWithRed:(177.0/255) green:(210.0/255) blue:1.0 alpha:1.0];
        _lightBlueColor = [UIColor colorWithRed:(191.0/255) green:(221.0/255) blue:1.0 alpha:1.0];
    }
    return self;
}

@end
