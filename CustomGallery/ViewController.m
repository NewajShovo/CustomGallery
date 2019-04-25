//
//  ViewController.m
//  CustomGallery
//
//  Created by leo on 24/4/19.
//  Copyright © 2019 Shafiq Shovo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "PhotoCellCustom/photoCellCollectionViewCell.h"
#import "ShowImage/showImageViewController.h"
#import "ShowVideo/showVideoViewController.h"

@interface ViewController ()

@end

@implementation ViewController
bool flag =true;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void) loadData
{
    _assets = [@[] mutableCopy];
    _images=[@[]mutableCopy];
    
    
    PHFetchResult *result;
    if(flag) result= [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
    else result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:nil];
    
    NSLog(@"%d",(int)result.count);
    
    for (PHAsset *val in result)
    {
        [_assets addObject:val];
    }
    [self.collectionView reloadData];
}



#pragma mark - collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    photoCellCollectionViewCell *cell = (photoCellCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    PHAsset *asset = self.assets[indexPath.row];
    cell.photoImageView.image=nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            cell.asset =asset;
            
        });
        
    });
    
    return cell;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    photoCellCollectionViewCell *cell = (photoCellCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    PHAsset *tmpasset = self.assets[indexPath.row];
    UIImage *img= [cell getImageFromAsset:tmpasset];
    
    // getting video controller for image
    showImageViewController *vc1 =[ [showImageViewController alloc]init];
    vc1.asset =tmpasset;
    
    //getting video controller for video
    showVideoViewController *vc2 = [ [ showVideoViewController alloc] init];
    vc2.asset=tmpasset;
    
    // flag true for showing image and other for video
    if(flag) [self. navigationController pushViewController:vc1 animated:YES];
    else [ self.navigationController pushViewController:vc2 animated:YES];

}
#pragma  mark - image and video button clicked
- (IBAction)imgBtnClicked:(id)sender {
    
    flag = true;
    [self loadData];
    NSLog(@"IMage");
    
    
}
- (IBAction)videoBtnClicked:(id)sender {
    flag =false;
    [self loadData];


}

@end
