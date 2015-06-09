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

#import "IconSelectionController.h"

#define kAnimationDuration 0.3


@interface IconSelectionController ()

@property (strong, nonatomic) NSArray* iconNames;

@end

@implementation IconSelectionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.iconNames = @[@"app",
                       @"bird",
                       @"book",
                       @"bug",
                       @"bus",
                       @"camera",
                       @"car",
                       @"chat",
                       @"cloud",
                       @"coffee",
                       @"compass",
                       @"darth_vader",
                       @"eye",
                       @"film",
                       @"football",
                       @"glass",
                       @"guitar",
                       @"home",
                       @"justice",
                       @"lock",
                       @"money",
                       @"music",
                       @"network",
                       @"pen",
                       @"person",
                       @"picture",
                       @"plane",
                       @"saturn",
                       @"search",
                       @"skull",
                       @"social",
                       @"target",
                       @"theater",
                       @"tools",
                       @"world"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark custom methods

#pragma mark methods from UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.iconNames count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"IconCell" forIndexPath:indexPath];
    
    NSString* iconName = self.iconNames[indexPath.row];
    
    UIImageView* imageView = (UIImageView*)[cell viewWithTag:100];
    imageView.image = [UIImage imageNamed:iconName];

    UIView* selectedBackgroundView = (UIView*)[cell viewWithTag:101];
    selectedBackgroundView.alpha = 0.0;
    
    return cell;
}

#pragma mark methods from UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIconName = self.iconNames[indexPath.row];
    
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIView* selectedBackgroundView = (UIView*)[cell viewWithTag:101];
    
    [UIView animateWithDuration:kAnimationDuration animations:^(void){
        selectedBackgroundView.alpha = 1.0;
    }];
    
    [self performSelector:@selector(triggerExitSegue) withObject:nil afterDelay:kAnimationDuration];
}

- (void)triggerExitSegue
{
    [self performSegueWithIdentifier:@"SelectingIconDone" sender:self];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIView* selectedBackgroundView = (UIView*)[cell viewWithTag:101];
    
    [UIView animateWithDuration:kAnimationDuration animations:^(void){
        selectedBackgroundView.alpha = 0.0;
    }];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 15, 20, 15);
}

@end
