//
//  PlayerView.h
//  Camera LandScape
//
//  Created by Shafiq Shovo on 15/4/19.
//  Copyright © 2019 Shafiq Shovo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN
@class AVPlayer;
@interface PlayerView : UIView
@property (nonatomic,strong) AVPlayer *player;

@end

NS_ASSUME_NONNULL_END
