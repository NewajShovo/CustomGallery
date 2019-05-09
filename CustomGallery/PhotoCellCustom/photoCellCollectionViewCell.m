//
//  photoCellCollectionViewCell.m
//  CustomGallery
//
//  Created by leo on 24/4/19.
//  Copyright © 2019 Shafiq Shovo. All rights reserved.
//
//
//  PhotoCellCollectionViewCell.m
//  PhotoApp
//
//  Created by leo on 23/4/19.
//  Copyright © 2019 Shafiq Shovo. All rights reserved.
//
#import "photoCellCollectionViewCell.h"
#import <Photos/Photos.h>

@interface photoCellCollectionViewCell ()
// 1
//@property(nonatomic, weak) IBOutlet UIImageView *photoImageView;
@end

@implementation photoCellCollectionViewCell

#pragma mark - set asset
- (void) setAsset:(PHAsset *)asset
{
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = true;
    requestOptions.networkAccessAllowed = YES;
    PHImageManager *manager = [PHImageManager defaultManager];
    _asset = asset;
    [manager requestImageForAsset:asset
     //                           targetSize:CGSizeMake(screenBounds.size.width*screenScale*.5,screenBounds.size.height*screenScale*.5)
                       targetSize:CGSizeMake(400, 400)
                      contentMode:PHImageContentModeDefault
                          options:requestOptions
                    resultHandler:^void(UIImage *image, NSDictionary *info) {
                        self.img=image;
                    }];
    if(self.img==nil) self.photoImageView.image = nil;
    else self.photoImageView.image = self.img;
}
#pragma  mark- get asset
-(UIImage *) getImageFromAsset:(PHAsset *) asset
{
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = true;
    requestOptions.networkAccessAllowed = YES;
    PHImageManager *manager = [PHImageManager defaultManager];
    _asset = asset;
    [manager requestImageForAsset:asset
     //                           targetSize:CGSizeMake(screenBounds.size.width*screenScale*.5,screenBounds.size.height*screenScale*.5)
                       targetSize:CGSizeMake(400, 400)
                      contentMode:PHImageContentModeDefault
                          options:requestOptions
                    resultHandler:^void(UIImage *image, NSDictionary *info) {
                        self.img=image;
                    }];
    if(self.img==nil) self.photoImageView.image = nil;
    else self.photoImageView.image = self.img;
    
    
    
    return self.img;
    
}
- (void) helloWorld{
    NSLog(@"HEllo world");
}
@end
