//
//  PlayerView.m
//  Camera LandScape
//
//  Created by Shafiq Shovo on 15/4/19.
//  Copyright © 2019 Shafiq Shovo. All rights reserved.
//

#import "PlayerView.h"
@import AVFoundation;
@implementation PlayerView

+(Class) layerClass
{
    return [AVPlayerLayer class];
}
- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    ((AVPlayerLayer *)[self layer]).videoGravity = AVLayerVideoGravityResizeAspectFill;
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
