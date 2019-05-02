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
CMTime startTime;
CMTime endTime;
AVAsset *resultAsset;
UIView *view1;
UIScrollView *scrollView;
UIView *tempView ;
UIView *movingview;
float Time,add,val,val1,endArrowTime,startArrowTime,sliderValue;
int total_no_frames;
double movement;


@implementation showVideoViewController {
    UIImageView *startArrow;
    UIImageView *endArrow;
    UISlider * myslider;
}

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
    
    
    
    // creating a scrollview
    NSLog(@"%f",SCREEN_WIDTH);
    scrollView = [ [ UIScrollView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-164, SCREEN_WIDTH, 100)];
    [self.view addSubview:scrollView];

//    [tempView addGestureRecognizer:pgr];
    scrollView.backgroundColor = [ UIColor blueColor];
    tempView.backgroundColor = [ UIColor clearColor];
    float xx= ((ceil(_asset.duration)));
    Time = _asset.duration;
    total_no_frames =(int)xx;
    NSLog(@"%d",total_no_frames);
    scrollView.contentSize=CGSizeMake(100*(total_no_frames),100);
//    scrollView.contentSize=CGSizeMake(100*(total_no_frames),100);
    NSLog(@"asdfasdf%d",[scrollView isScrollEnabled]);
   //Creating a UISlider
    
    myslider = [ [ UISlider alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50)];
    [myslider setBackgroundColor:[UIColor clearColor]];
    myslider.minimumValue = 0.0;
    myslider.maximumValue = scrollView.contentSize.width-scrollView.frame.size.width;
    NSLog(@"%f",myslider.maximumValue);
    [self.view addSubview:myslider];
    [self sliderAction:myslider];
    [myslider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [self generateFramefromvideo:resultAsset];
    [self generateUIView];
    
    
}
int cnt=0;
double p=0;
double xxx=0;
#pragma mark - synscruber to sync with view
- (void)syncScrubber
{
    cnt++;
    if(movingview.center.x+p>endArrow.center.x-(((scrollView.frame.size.height/4)/2))){
        
        
        [movingview setCenter:CGPointMake(endArrow.center.x-(((scrollView.frame.size.height/4)/2)), movingview.center.y)];
        [movingview removeFromSuperview];
        cnt=0;
        [self.player pause];
    }
    else [movingview setCenter:CGPointMake(movingview.center.x+p, movingview.center.y)];
    
}
#pragma mark - play button clicked


- (IBAction)PlayButtonClicked:(id)sender {


    [self.player seekToTime:startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.player play];
    if(cnt==0)[self creatMovingView];
    
    
    //moving view created here
    
    double delayInSeconds = val1-val;
    CMTime xx=CMTimeMakeWithSeconds(.001, NSEC_PER_SEC);
    double yy= CMTimeGetSeconds(xx);
    
    
    double interval =(sliderValue+endArrow.center.x-add)-(sliderValue+startArrow.center.x+add)-2;
//    NSLog(@"%f %f",([(UISlider *)temp value]+endArrow.center.x-add),([(UISlider *)temp value]+startArrow.center.x+add));
    interval = (interval/delayInSeconds)*yy;
    
    
    
    NSLog(@"----interval %f",interval);
    CMTime invoke = CMTimeMakeWithSeconds(0.001, NSEC_PER_SEC);
    p=interval;
//    cnt=(([(UISlider *)temp value]+endArrow.center.x-add)-([(UISlider *)temp value]+startArrow.center.x+add)-2)/interval;
    _observer=[_player addPeriodicTimeObserverForInterval:invoke
                                                    queue:NULL
                                               usingBlock:
               ^(CMTime time)
               {
                   [self syncScrubber];
               }];
    
    
    
    NSLog(@"----%f %d-----",interval,cnt);









}







#pragma mark - sliderMovement controll
-(void) sliderAction:(id) temp
{
    
    
     [scrollView setContentOffset:CGPointMake([(UISlider *)temp value],0) animated:NO];
//    cnt=0;
    
    ///value of half of the arrows
    add = ((scrollView.frame.size.height/4)/2);
    
    
    
    // converting start arrow's value to time
     val = (Time*([(UISlider *)temp value]+startArrow.center.x+add))/([(UISlider *)temp maximumValue]);
    NSLog(@"%f",Time);
    // converting end arrow's value to time
     val1= (Time*([(UISlider *)temp value]+endArrow.center.x-add))/([(UISlider *)temp maximumValue]);

    endTime = CMTimeMakeWithSeconds(val1, NSEC_PER_SEC);
    startTime=CMTimeMakeWithSeconds(val, NSEC_PER_SEC);
    endArrowTime= [(UISlider *)temp value]+endArrow.center.x;
    sliderValue = [(UISlider *)temp value];
    
 
//    [movingview removeFromSuperview];
}

#pragma mark - generating frame for video
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

-(void) creatMovingView
{
    movingview = [ [ UIView alloc] initWithFrame:CGRectMake((startArrow.center.x+((scrollView.frame.size.height/4)/2)),SCREEN_HEIGHT-164,2,100)];
    [self.view addSubview:movingview];
    NSLog(@"%f %f %f",(startArrow.center.x+((scrollView.frame.size.height/4)/2)),movingview.center.x,(endArrow.center.x-((scrollView.frame.size.height/4)/2)));
    movingview.backgroundColor = [UIColor greenColor];
}




#pragma mark - Generating UI View like start arrow,end arrow;

-(void) generateUIView
{
    
    
    
    
    
    float height = scrollView.frame.size.height;
    float width = height/4;
    
    // Start Selector
    startArrow = [ [ UIImageView alloc] initWithFrame:CGRectMake(scrollView.frame.origin.x+30, SCREEN_HEIGHT-164, width, height)];
    startArrow.image=[UIImage imageNamed:@"EndArrow.png"];
    [startArrow setContentMode:UIViewContentModeScaleToFill];
    [self.view addSubview:startArrow];
    startArrow.backgroundColor = [ UIColor blueColor];
    [startArrow setUserInteractionEnabled:YES];

    UIPanGestureRecognizer *panGestureForStartArrow = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanForStartArrow:)];
    [startArrow addGestureRecognizer:panGestureForStartArrow];
    
    
    // End Selector
    endArrow = [ [ UIImageView alloc] initWithFrame:CGRectMake(scrollView.frame.origin.x+100,SCREEN_HEIGHT-164, width, height)];
    endArrow.image = [ UIImage imageNamed:@"StartArrow.png"];
    [endArrow setContentMode:UIViewContentModeScaleToFill];
    [self.view addSubview:endArrow];
    endArrow.backgroundColor = [ UIColor blueColor];
    [endArrow setUserInteractionEnabled:YES];

    UIPanGestureRecognizer *panGestureForEndArrow = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanForEndArrow:)];
    [endArrow addGestureRecognizer:panGestureForEndArrow];
    
    
    
    
    
    
    

}

#pragma mark - Handling Pan gesture of Start Arrow

- (void) handlePanForStartArrow:(UIPanGestureRecognizer*) gesture {
    
   
    NSLog(@"Start Arrow");
    CGPoint translation = [gesture translationInView:startArrow];
    NSLog(@"%f",startArrow.center.x);
    
    if(translation.x<0){
        [ startArrow setCenter:CGPointMake(startArrow.center.x+translation.x, startArrow.center.y)];
    }
   
    
   if(startArrow.center.x<endArrow.center.x-(scrollView.frame.size.height/4))[startArrow setCenter:CGPointMake(startArrow.center.x+translation.x, startArrow.center.y)];
    
    ///still move away.
    if(endArrow.center.x-(scrollView.frame.size.height/4)<startArrow.center.x)
    {
        [startArrow setCenter:CGPointMake(endArrow.center.x-(scrollView.frame.size.height/4), endArrow.center.y)];
    }
    
    
    if(startArrow.center.x<((scrollView.frame.size.height/4)/2)){
        
         [startArrow setCenter:CGPointMake(0+((scrollView.frame.size.height/4)/2), endArrow.center.y)];
    }
    
    [gesture setTranslation:CGPointZero inView:startArrow];
    
}

#pragma mark - for Handling pan gesture of End Arrow
- (void) handlePanForEndArrow:(UIPanGestureRecognizer*) gesture {
    
    
   
    CGPoint translation = [gesture translationInView:endArrow];
     NSLog(@"%f",translation.x);
     NSLog(@"Changed ----%f %f-------",startArrow.center.x,endArrow.center.x);
    if(translation.x>0) [endArrow setCenter:CGPointMake(endArrow.center.x+translation.x, endArrow.center.y)];
    
    else if(startArrow.center.x+(scrollView.frame.size.height/4)<endArrow.center.x)[endArrow setCenter:CGPointMake(endArrow.center.x+translation.x, endArrow.center.y)];
    
    //
    
    if(startArrow.center.x+(scrollView.frame.size.height/4)>endArrow.center.x)
    {
        [endArrow setCenter:CGPointMake(startArrow.center.x+(scrollView.frame.size.height/4), endArrow.center.y)];
    }
    
    if(endArrow.center.x>scrollView.frame.size.width-(scrollView.frame.size.height/4)/2){
        
        [endArrow setCenter:CGPointMake(scrollView.frame.size.width-((scrollView.frame.size.height/4)/2), endArrow.center.y)];
    }
   
    
    [gesture setTranslation:CGPointZero inView:endArrow];
    
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

