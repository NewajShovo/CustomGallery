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
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@end

int framegenerate=1;
int cnt=0;
BOOL img_gen_cmplt =YES;
@implementation showVideoViewController {
  UIImageView *startArrow;
    UIImageView *endArrow;
    UISlider * myslider;


    AVAssetImageGenerator *imageGenerator;
    CMTime startTime;
    CMTime endTime;
    AVAsset *resultAsset;
    UIView *view1;
    UIView *tempView ;
    UIView *movingview;
    float Time,add,val,val1,endArrowTime,startArrowTime,sliderValue;
    int total_no_frames;
    double movement;
    int pore_nibo;




}




- (void)viewDidLoad {
    cnt=0;
    img_gen_cmplt =YES;
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
    NSLog(@"%f %f",_frameView.frame.size.height,self.frameView.frame.size.width);
    
    float xx= ((ceil(_asset.duration)));
    Time = _asset.duration;
    total_no_frames =(floor)(Time*framegenerate);
    NSLog(@"%f, %d",Time,total_no_frames);
    pore_nibo=total_no_frames/8;
    NSLog(@"%d",pore_nibo);
    

//   //Creating a UISlider

    myslider = [ [ UISlider alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50)];
    [myslider setBackgroundColor:[UIColor clearColor]];
    myslider.minimumValue = 0.0;
    myslider.maximumValue = Time;
//    NSLog(@"%f",myslider.maximumValue);
    [self.view addSubview:myslider];
    [self sliderAction:myslider];
    [myslider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    myslider.hidden=YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self generateFramefromvideo:resultAsset];
        [self generateFrame:resultAsset];
    });
    
    [self generateUIView];


}


double p=0;
double xxx=0;
#pragma mark - synscruber to sync with view
- (void)syncScrubber
{
    NSLog(@"----%f",movingview.center.x);
    if(movingview.center.x+p>endArrow.center.x-(endArrow.frame.size.width/2)){


        [movingview setCenter:CGPointMake(endArrow.center.x-(((_Scrollview.frame.size.height/4)/2)), movingview.center.y)];
        [movingview removeFromSuperview];
        cnt=0;
        [self.player pause];
    }
    else [movingview setCenter:CGPointMake(movingview.center.x+p, movingview.center.y)];

}
#pragma mark - play button clicked
- (IBAction)btnClicked:(id)sender {
    NSLog(@"----%f----",_frameView.frame.size.width);
    NSLog(@"---%f----%f--",startArrow.center.x,endArrow.center.x);
    val = (Time/_frameView.frame.size.width)*(startArrow.center.x+add);
    val1=(Time/_frameView.frame.size.width)*(endArrow.center.x-add);
//    _button.hidden=YES;
    startTime=CMTimeMakeWithSeconds(val, NSEC_PER_SEC);
    [self.player seekToTime:startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.player play];
    if(cnt==0)[self creatMovingView];
    
    p= (endArrow.center.x-startArrow.center.x-(2*add))/(val1-val);
    p=p*.01;
   // moving view created here
    CMTime invoke = CMTimeMakeWithSeconds(0.01, NSEC_PER_SEC);
    _observer=[_player addPeriodicTimeObserverForInterval:invoke
                                                    queue:NULL
                                               usingBlock:
               ^(CMTime time)
               {
                   [self syncScrubber];
               }];



//    NSLog(@"----%f %d-----",interval,cnt);


}



#pragma mark - sliderMovement controll
-(void) sliderAction:(id) temp
{

   add = (startArrow.frame.size.width/2);



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

#pragma mark - generating frame for video with asset reader
//-(void) generateFramefromvideo: (AVAsset *) movieAsset
//{
//
//
//    NSLog(@"I am here");
//
//    AVAssetTrack *videoAssetTrack= [[movieAsset tracksWithMediaType:AVMediaTypeVideo] lastObject];
//    NSError *error;
//    __block int i = 0;
//    AVMutableComposition *com = [AVMutableComposition composition];
//    AVMutableCompositionTrack *videoCompositionTrack = [com addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, movieAsset.duration) ofTrack:[[movieAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:kCMTimeZero error:nil];
//
//    //Video asset er
//    videoCompositionTrack.preferredTransform = videoAssetTrack.preferredTransform;
//    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:com error:&error];
//    CGSize size = videoCompositionTrack.naturalSize;
//    float imgHeight = self.frameView.frame.size.height;
//    float imgWidth =self.frameView.frame.size.height ;
//    //imgHeight * (size.width/size.height);
//    size = CGSizeMake(imgWidth * [UIScreen mainScreen].scale * 2 , imgHeight * [UIScreen mainScreen].scale *2);
//
//    //    size = CGSizeMake(imgWidth, imgHeight);
//    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, com.duration);
//
//    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
//
//
//
//    CGSize originalSize = CGSizeApplyAffineTransform(videoCompositionTrack.naturalSize, videoCompositionTrack.preferredTransform);
//    originalSize = CGSizeMake(fabs(originalSize.width), fabs(originalSize.height));
//
//
//    CGFloat scaleX = (size.width / originalSize.width)*2;
//    CGFloat scaleY = size.height /originalSize.height;
//
//    CGAffineTransform origTrans = videoCompositionTrack.preferredTransform;
//    CGAffineTransform scaleTrans;
//    if(originalSize.height < originalSize.width){
//        scaleTrans = CGAffineTransformConcat(origTrans, CGAffineTransformMakeScale(scaleX, scaleY));
//    }else{
//        scaleTrans = CGAffineTransformConcat(origTrans, CGAffineTransformMakeScale(scaleX/2, scaleX/2));
//    }
//
//
//    [transformer setTransform:scaleTrans atTime:kCMTimeZero];
//
//
//    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
//
//    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
//    videoComposition.frameDuration = CMTimeMake(1, framegenerate);
//    videoComposition.renderSize = size ;
//    videoComposition.instructions = [NSArray arrayWithObject:instruction];
//
//    AVAssetReaderVideoCompositionOutput *assetReaderVideoCompositionOutput = [[AVAssetReaderVideoCompositionOutput alloc] initWithVideoTracks:[com tracksWithMediaType:AVMediaTypeVideo] videoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
//                                                                                                                                                                                                         (id)kCVPixelBufferWidthKey : [NSNumber numberWithFloat:size.width],
//                                                                                                                                                                                                         (id)kCVPixelBufferHeightKey: [NSNumber numberWithFloat:size.height]
//                                                                                                                                                                                                         }];
//    assetReaderVideoCompositionOutput.videoComposition = videoComposition;
//    assetReaderVideoCompositionOutput.alwaysCopiesSampleData = NO;
//    [reader addOutput:assetReaderVideoCompositionOutput];
//
//    [reader startReading];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        NSLog(@"%ld",(long)reader.status);
//
//        while (reader.status == AVAssetReaderStatusReading) {
//            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(assetReaderVideoCompositionOutput.copyNextSampleBuffer);
//            CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
//
//            uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
//            size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
//            size_t width = CVPixelBufferGetWidth(imageBuffer);
//            size_t height = CVPixelBufferGetHeight(imageBuffer);
//            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//
//            CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
//            CGImageRef newImage = CGBitmapContextCreateImage(newContext);
//            CGContextRelease(newContext);
//
//            CGColorSpaceRelease(colorSpace);
//            CVPixelBufferUnlockBaseAddress(imageBuffer,0);
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:newImage]];
//
//                if(cnt%pore_nibo==0&&img_gen_cmplt){
//                    [self.frameView addSubview:imgV];
//                    NSLog(@"%d",cnt);
////                    NSLog(@"%f %f",_frameView.frame.size.width,(imgHeight * i)+imgHeight);
//                    if((imgHeight * i)+imgHeight>_frameView.frame.size.width){
//                        double val = ((imgHeight * i)+imgHeight-_frameView.frame.size.width);
//                        imgV.frame = CGRectMake(imgHeight * i ,0,imgHeight-val ,imgHeight);
//                        i++;
//                        [imgV setContentMode:UIViewContentModeScaleAspectFill];
//                        img_gen_cmplt=NO;
//                    }
//                    else{
//                        imgV.frame = CGRectMake(imgHeight * i ,0, imgHeight,imgHeight);
//                        i++;
//                        [imgV setContentMode:UIViewContentModeScaleAspectFit];
//
//                    }
//
//                }
//                cnt++;
//            });
//        }
//    });
//
//
//}
#pragma mark - generate image with imagegenerator
-(void) generateFrame : (AVAsset *) movieAsset {
    
    imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:movieAsset];
    // Image Width from height with ratio
    float imgHeight = self.frameView.frame.size.height;
    float imgWidth = imgHeight;
    
    // Time distance per frame
//    Float64 timePerFrame = duration/_totalFrames;
    __block int i=0;
    dispatch_queue_t queueHigh = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
    dispatch_async(queueHigh, ^{
         Float64 secondsIn= Time/7;
        __block Float64 tt=0.00;
        // 0th frame
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            for( int cnt =0; cnt<8;cnt++){
            // Frame
                
            UIImage *img = [self getImageFromAsset:movieAsset atTime:CMTimeMakeWithSeconds(cnt*secondsIn, 600)];
            UIImageView *imgV = [[UIImageView alloc] initWithImage:img];
            [self.frameView addSubview:imgV];
            imgV.frame = CGRectMake(imgHeight * i++ ,0, imgHeight,imgHeight);
            [imgV setContentMode:UIViewContentModeScaleAspectFill];
            [imgV setClipsToBounds:YES];
            tt+=secondsIn;
            }

            
            });
 });
}

- (UIImage*) getImageFromAsset:(AVAsset*)asset atTime:(CMTime)cmTime {
    
    // Image Generator
    imageGenerator.maximumSize = CGSizeMake(self.frameView.frame.size.height*3,self.frameView.frame.size.height*3);
    
    CMTime actualTime;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:cmTime actualTime:&actualTime error:nil];
//    CGSize size = CGSizeMake(self.frameView.frame.size.height * [UIScreen mainScreen].scale * 2 , self.frameView.frame.size.height * [UIScreen mainScreen].scale *2)
    UIImage *image = [UIImage imageWithCGImage: imageRef scale: 1.00 orientation: [self orientTheFrame:asset]];
    CGImageRelease(imageRef);
//    NSLog(@"%f",(double)actualTime);
    return image;
}


// Get Video Orientation
- (UIImageOrientation) orientTheFrame : (AVAsset *) asset{
    if([self getVideoOrientationFromAsset:asset] == UIImageOrientationUp)
        return UIImageOrientationRight;
    if([self getVideoOrientationFromAsset:asset] == UIImageOrientationLeft)
        return UIImageOrientationDown;
    return UIImageOrientationUp;
}
- (UIImageOrientation)getVideoOrientationFromAsset:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIImageOrientationLeft; //return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIImageOrientationRight; //return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIImageOrientationDown; //return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIImageOrientationUp;  //return UIInterfaceOrientationPortrait;
}






#pragma  mark - creating moving view
-(void) creatMovingView
{
    movingview = [ [ UIView alloc] initWithFrame:CGRectMake((startArrow.center.x+((startArrow.frame.size.width/2))),startArrow.frame.origin.y-2,4,54)];
    [_Scrollview addSubview:movingview];
//    NSLog(@"%f %f %f",(startArrow.center.x+((_Scrollview.frame.size.height/4)/2)),movingview.center.x,(endArrow.center.x-((_Scrollview.frame.size.height/4)/2)));
    movingview.backgroundColor = [UIColor whiteColor];
    movingview.layer.cornerRadius=2;
    movingview.layer.masksToBounds=true;
//    [movingview backgroundColor]
}




//#pragma mark - Generating UI View like start arrow,end arrow;

-(void) generateUIView
{

//    float height = _Scrollview.frame.size.height;
//    float width = height/4;

    // Start Selector
    startArrow = [ [ UIImageView alloc] initWithFrame:CGRectMake(_frameView.frame.origin.x+100, _frameView.frame.origin.y-2, 16, 50)];
    startArrow.image=[UIImage imageNamed:@"Group 640"];
    [startArrow setContentMode:UIViewContentModeScaleToFill];
    [_Scrollview addSubview:startArrow];
    startArrow.backgroundColor = [ UIColor clearColor];
    [startArrow setUserInteractionEnabled:YES];

    UIPanGestureRecognizer *panGestureForStartArrow = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanForStartArrow:)];
    [startArrow addGestureRecognizer:panGestureForStartArrow];


    // End Selector
    endArrow = [ [ UIImageView alloc] initWithFrame:CGRectMake(_frameView.frame.origin.x+250, _frameView.frame.origin.y-2, 16, 50)];
    endArrow.image = [ UIImage imageNamed:@"Group 639"];
    [endArrow setContentMode:UIViewContentModeScaleToFill];
    [_Scrollview addSubview:endArrow];
    endArrow.backgroundColor = [ UIColor clearColor];
    [endArrow setUserInteractionEnabled:YES];

    UIPanGestureRecognizer *panGestureForEndArrow = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanForEndArrow:)];
    [endArrow addGestureRecognizer:panGestureForEndArrow];


}
//
//#pragma mark - Handling Pan gesture of Start Arrow

- (void) handlePanForStartArrow:(UIPanGestureRecognizer*) gesture {

  [movingview removeFromSuperview];
    NSLog(@"Start Arrow");
    CGPoint translation = [gesture translationInView:startArrow];
    NSLog(@"%f %f",startArrow.center.x,endArrow.frame.size.width);

    NSLog(@"%f %f",endArrow.center.x,endArrow.center.x-(endArrow.frame.size.width/2));
    
    
    if(translation.x<0){
        [startArrow setCenter:CGPointMake(startArrow.center.x+translation.x, startArrow.center.y)];
    
    }
    if(startArrow.center.x+(endArrow.frame.size.width/2)<endArrow.center.x-(endArrow.frame.size.width/2)) [ startArrow setCenter:CGPointMake(startArrow.center.x+translation.x, startArrow.center.y)];
    
    //If still moves away
     if(startArrow.center.x+(endArrow.frame.size.width/2)>endArrow.center.x-(endArrow.frame.size.width/2))
    [ startArrow setCenter:CGPointMake(endArrow.center.x-startArrow.frame.size.width, startArrow.center.y)];
    

    if(startArrow.center.x<((endArrow.frame.size.width/2)/2)){

        [startArrow setCenter:CGPointMake(0+(endArrow.frame.size.width/2), endArrow.center.y)];
    }

    [gesture setTranslation:CGPointZero inView:startArrow];

}

#pragma mark - for Handling pan gesture of End Arrow
- (void) handlePanForEndArrow:(UIPanGestureRecognizer*) gesture {



    CGPoint translation = [gesture translationInView:endArrow];
     NSLog(@"%f",translation.x);
     NSLog(@"Changed ----%f %f-------",startArrow.center.x,endArrow.center.x);
    if(translation.x>0) [endArrow setCenter:CGPointMake(endArrow.center.x+translation.x, endArrow.center.y)];

     if(startArrow.center.x+(startArrow.frame.size.width/2)<endArrow.center.x-(startArrow.frame.size.width/2))[endArrow setCenter:CGPointMake(endArrow.center.x+translation.x, endArrow.center.y)];

    //if still moves way
    if(startArrow.center.x+(startArrow.frame.size.width/2)>endArrow.center.x)
    {
        [endArrow setCenter:CGPointMake(startArrow.center.x+startArrow.frame.size.width, endArrow.center.y)];
    }

    if(endArrow.center.x>_Scrollview.frame.size.width-(_Scrollview.frame.size.height/4)/2){

        [endArrow setCenter:CGPointMake(_Scrollview.frame.size.width-((_Scrollview.frame.size.height/4)/2), endArrow.center.y)];
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

