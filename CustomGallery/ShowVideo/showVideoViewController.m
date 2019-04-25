//
//  showVideoViewController.m
//  CustomGallery
//
//  Created by leo on 24/4/19.
//  Copyright © 2019 Shafiq Shovo. All rights reserved.
//

#import "showVideoViewController.h"
#import "PlayerView.h"

@interface showVideoViewController ()
@property (weak,nonatomic) IBOutlet PlayerView *playerView;
@property (nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@end
AVAsset *resultAsset;
UIView *view1;
UIScrollView *scrollView;
int total_no_frames;
@implementation showVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    
    PHVideoRequestOptions *option = [PHVideoRequestOptions new];
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:option resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {
        resultAsset = avasset;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    _playerItem = [AVPlayerItem playerItemWithAsset:resultAsset];
    _player = [AVPlayer playerWithPlayerItem:self.playerItem];
    _playerView.player = _player;
    [self.player play];
    
    
    //Creating a view;
    view1 = [ [ UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-164, SCREEN_WIDTH, 100)];
    self.view.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:view1];
//    view1.backgroundColor=[ UIColor greenColor];
    
    // creating a scrollview
    NSLog(@"%f",SCREEN_WIDTH);
    scrollView = [ [ UIScrollView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-164, SCREEN_WIDTH, 100)];
    [self.view addSubview:scrollView];
    scrollView.backgroundColor = [ UIColor blueColor];
    total_no_frames = (int) _asset.duration;
    NSLog(@"%d",total_no_frames);
    scrollView.contentSize=CGSizeMake(100*(total_no_frames+1),100);
    [self generateFramefromvideo:resultAsset];
    
    
    
}

-(void) generateFramefromvideo: (AVAsset *) movieAsset
{
    
    
    NSLog(@"I am here");
    
    AVAssetTrack *videoAssetTrack= [[movieAsset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    NSError *error;
    __block int i = 0;
    AVMutableComposition *com = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [com addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, movieAsset.duration) ofTrack:[[movieAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:kCMTimeZero error:nil];
    
    //Video asset er
    videoCompositionTrack.preferredTransform = videoAssetTrack.preferredTransform;
    
    
    
    
    
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:com error:&error];
    CGSize size = videoCompositionTrack.naturalSize;
    float imgWidth =  scrollView.frame.size.height;
    float imgHeight = scrollView.frame.size.height;
    size = CGSizeMake(imgWidth , imgHeight);
//    size = CGSizeMake(imgWidth, imgHeight);
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, com.duration);
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];


    CGRect originalRect = CGRectApplyAffineTransform(CGRectMake(0, 0, videoCompositionTrack.naturalSize.width, videoCompositionTrack.naturalSize.height), videoCompositionTrack.preferredTransform);
    CGSize originalSize = CGSizeApplyAffineTransform(videoCompositionTrack.naturalSize, videoCompositionTrack.preferredTransform);
    originalSize = CGSizeMake(fabs(originalSize.width), fabs(originalSize.height));


    CGFloat scaleX = size.width / originalSize.width;

    CGFloat translateX = (originalRect.origin.x/originalRect.size.width) * size.width;
    CGFloat translateY = (originalRect.origin.y/originalRect.size.height) * size.height;

    CGAffineTransform origTrans = videoCompositionTrack.preferredTransform;
    CGAffineTransform scaleTrans = CGAffineTransformConcat(origTrans, CGAffineTransformMakeScale(scaleX, scaleX));
    CGAffineTransform translateTrans = CGAffineTransformConcat(scaleTrans, CGAffineTransformMakeTranslation(-translateX, -translateY));

   [transformer setTransform:translateTrans atTime:kCMTimeZero];
    
    
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 1);
    videoComposition.renderSize = size;
    videoComposition.instructions = [NSArray arrayWithObject:instruction];
    
    AVAssetReaderVideoCompositionOutput *assetReaderVideoCompositionOutput = [[AVAssetReaderVideoCompositionOutput alloc] initWithVideoTracks:[com tracksWithMediaType:AVMediaTypeVideo] videoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                                                                                                                                                                                         (id)kCVPixelBufferWidthKey : [NSNumber numberWithFloat:size.width],
                                                                                                                                                                                                         (id)kCVPixelBufferHeightKey: [NSNumber numberWithFloat:size.height]
                                                                                                                                                                                                         }];
    assetReaderVideoCompositionOutput.videoComposition = videoComposition;
    assetReaderVideoCompositionOutput.alwaysCopiesSampleData = NO;
    [reader addOutput:assetReaderVideoCompositionOutput];
    
    [reader startReading];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"%ld",(long)reader.status);
        
        while (reader.status == AVAssetReaderStatusReading) {
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(assetReaderVideoCompositionOutput.copyNextSampleBuffer);
            CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
            
            uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
            size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
            size_t width = CVPixelBufferGetWidth(imageBuffer);
            size_t height = CVPixelBufferGetHeight(imageBuffer);
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            
            CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
            CGImageRef newImage = CGBitmapContextCreateImage(newContext);
            CGContextRelease(newContext);
            
            CGColorSpaceRelease(colorSpace);
            CVPixelBufferUnlockBaseAddress(imageBuffer,0);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:newImage]];
                [scrollView addSubview:imgV];
                NSLog(@"frame number: %d",i);
                
                
                imgV.frame = CGRectMake(imgWidth * i++ , 0, imgWidth, imgHeight);
                [imgV setContentMode:UIViewContentModeScaleAspectFit];
                
            });
        }
    });
    
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
