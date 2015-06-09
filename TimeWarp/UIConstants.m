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
