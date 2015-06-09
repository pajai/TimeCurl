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

#import "Project+Additions.h"

@implementation Project (ProjectAdditions)

- (NSString*) label
{
    if (self.subname.length == 0) {
        return self.name;
    }
    else {
        return [NSString stringWithFormat:@"%@, %@", self.name, self.subname];
    }
}

- (UIImage*)  imageWithDefaultName:(NSString*)defaultName
{
    if (self.icon) {
        return [UIImage imageNamed:self.icon];
    }
    else {
        return [UIImage imageNamed:defaultName];
    }

}

- (NSString*) projectId
{
    return [[[self objectID] URIRepresentation] absoluteString];
}

@end
