//
//  showImageViewController.h
//  CustomGallery
//
//  Created by leo on 24/4/19.
//  Copyright © 2019 Shafiq Shovo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface showImageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;
@property (weak, nonatomic) IBOutlet UIImage *img;
@property (weak, nonatomic) IBOutlet PHAsset *asset;

@end

NS_ASSUME_NONNULL_END
