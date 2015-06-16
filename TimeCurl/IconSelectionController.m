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
