//
//  showVideoViewController.h
//  CustomGallery
//
//  Created by leo on 24/4/19.
//  Copyright © 2019 Shafiq Shovo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface showVideoViewController : UIViewController
@property (nonatomic) NSString *outputPath1;
//@property (nonatomic) IBOutlet UILabel *Label;
@property (nonatomic) id observer;
@property (nonatomic) PHAsset *asset;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UIView *frameView;
@property (weak, nonatomic) IBOutlet UIView *Scrollview;


// Container Size
@property (nonatomic) CGSize containerSize;
@end

NS_ASSUME_NONNULL_END
