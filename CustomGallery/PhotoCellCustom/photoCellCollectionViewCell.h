//
//  photoCellCollectionViewCell.h
//  CustomGallery
//
//  Created by leo on 24/4/19.
//  Copyright © 2019 Shafiq Shovo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface photoCellCollectionViewCell : UICollectionViewCell
@property(nonatomic, strong) PHAsset *asset;
@property (nonatomic,strong) UIImage *img;
@property(nonatomic, weak) IBOutlet UIImageView *photoImageView;
-(UIImage *) getImageFromAsset:(PHAsset *) asset;
@end

NS_ASSUME_NONNULL_END
