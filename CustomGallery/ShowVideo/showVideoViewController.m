//
//  showVideoViewController.m
//  CustomGallery
//
//  Created by leo on 24/4/19.
//  Copyright © 2019 Shafiq Shovo. All rights reserved.
//

#import "showVideoViewController.h"
#import "PlayerView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>


@interface showVideoViewController ()

@property (weak,nonatomic) IBOutlet PlayerView *playerView;
@property (nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;



@property (weak, nonatomic) IBOutlet UILabel *lbl;
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@property (strong, nonatomic) IBOutlet UIView *startShadow;

@property (strong, nonatomic) IBOutlet UIView *endShadow;



@end
int playButtonClicked=0;
int framegenerate=1;
int cnt=0;
BOOL img_gen_cmplt =YES;
@implementation showVideoViewController {
    
    UISlider * myslider;
    AVAssetImageGenerator *imageGenerator;
    CMTime startTime;
    CMTime endTime;
    AVAsset *resultAsset;
   
    float Time,val,val1;
    float startArrowHalfWidth,endArrowHalfWidth;
    
    //Frame generation
    int total_no_frames;
    int pore_nibo;
    float imgHeight;
    float imgWidth ;
}

///Which segment is Pressed;
bool trimPressed=YES;
bool cutPressed =NO;
bool splitPressed = NO;

@synthesize startArrow,endArrow;
-(BOOL) prefersStatusBarHidden{
    return YES;
}


#pragma mark - view Did load;

- (void)viewDidLoad {
    
    
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:36.f/255.f green:36.f/255.f blue:36.f/255.f alpha:1]];
    // Navigation bar Title created Here
    self.navigationItem.title = @"Custom Gallery";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:191.f/255.f green:191.f/255.f blue:191.f/255.f alpha:1]}];

    
    UIImage *lftbtnImage = [ UIImage imageNamed:@"Group 550"];
    UIBarButtonItem *lftBtn= [ [ UIBarButtonItem alloc] initWithImage:lftbtnImage style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = lftBtn;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    UIImage *rgtbtnImage = [ UIImage imageNamed:@"Path 844"];
    UIBarButtonItem *rgtBtn= [ [ UIBarButtonItem alloc] initWithImage:rgtbtnImage style:UIBarButtonItemStylePlain target:self action:@selector(doneBtnPressed)];
    self.navigationItem.rightBarButtonItem =  rgtBtn;
    self.navigationItem.rightBarButtonItem.enabled = YES;
//    self.navigationItem.rightBarButtonItem.tintColor=[UIColor colorWithRed:255 green:125 blue:38 alpha:1];
   self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:255.f/255.f green:125.f/255.f blue:38.f/255.f alpha:1];
    
    
//    add.imageView.image=@"Group 643";
    
    cnt=0;
    img_gen_cmplt =YES;
    [super viewDidLoad];

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
//    lbl.text
    float xx= ((ceil(_asset.duration)));
    Time = _asset.duration;
    
    
   CMTime timeforShowing =CMTimeMake(_asset.duration,NSEC_PER_SEC);
    // First, create NSDate object using
    NSDateComponentsFormatter *dcFormatter = [[NSDateComponentsFormatter alloc] init];
    dcFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dcFormatter.allowedUnits = NSCalendarUnitMinute |NSCalendarUnitSecond;
    dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    NSString* result=[dcFormatter stringFromTimeInterval:Time];
    NSLog(@"%@",result);
    NSString *str =@"TOTAL ";
    result=[NSString stringWithFormat:@"%@ %@",str,result];
    _lbl.text=result;
    _lbl.textColor=[UIColor lightGrayColor];
    
    total_no_frames =(floor)(Time*framegenerate);
    NSLog(@"%f, %d",Time,total_no_frames);
    pore_nibo=total_no_frames/8;
    NSLog(@"%d",pore_nibo);
    
    _frameView.clipsToBounds = YES;
    _frameView.layer.cornerRadius = (_frameView.frame.size.height/9);
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
        [self generateFrame:resultAsset];
        [self generateUIView];
        });
    
   
//   [self generateFramefromvideo:resultAsset];
    


}
#pragma mark - UISegment pressed
- (IBAction)UIsegmentPressed:(id)sender {
    
    NSLog(@"Value pressed");
    if(_segmentControl.selectedSegmentIndex ==0)
    {
        trimPressed=YES;
        cutPressed =NO;
        splitPressed = NO;
        [self trimPressed];
    }
    else if(_segmentControl.selectedSegmentIndex ==1 )
    {
        trimPressed=NO;
        cutPressed =YES;
        splitPressed = NO;
        [self cutPressed];
        NSLog(@"Cut Pressed");
    }
    else{
        trimPressed=NO;
        cutPressed =NO;
        splitPressed = YES;
        [self splitPressed];
        NSLog(@"Split Pressed");
    }
    
    
    

}
-(void) trimPressed {
    
    _startImage.image = [ UIImage imageNamed:@"Group 640"];
    _endImage.image  = [ UIImage imageNamed:@"Group 639"];
    _splitView.backgroundColor = [ UIColor clearColor];
    _splitImage.image = nil;
    _movingView.image = [ UIImage imageNamed:@"Line 97"];
    _movingView.image = [ UIImage imageNamed:@"Line 97"];
    
    NSLog(@"%f %f",_frameView.frame.size.width,endArrow.center.x);
    
    double shadowWidth = _Scrollview.frame.size.width-endArrow.center.x-(_Scrollview.frame.size.width);
    _endShadow.frame =CGRectMake(endArrow.center.x+endArrowHalfWidth, endArrow.frame.origin.y,shadowWidth+3,_Scrollview.frame.size.height);
    _endShadow.backgroundColor = [UIColor colorWithRed:41.f/255.f green:41.f/255.f blue:41.f/255.f alpha:.92];
  
    shadowWidth =(startArrow.center.x-startArrowHalfWidth)-_frameView.frame.origin.x;
    _startShadow.frame =CGRectMake(startArrow.frame.origin.x-shadowWidth, startArrow.frame.origin.y, shadowWidth,_Scrollview.frame.size.height);
    _startShadow.backgroundColor = [UIColor colorWithRed:41.f/255.f green:41.f/255.f blue:41.f/255.f alpha:.92];

}
- (void) cutPressed
{
    _startImage.image = [ UIImage imageNamed:@"Group 640"];
    _endImage.image  = [ UIImage imageNamed:@"Group 639"];
    _splitView.backgroundColor = [ UIColor clearColor];
    _splitImage.image = nil;
    _movingView.image = [ UIImage imageNamed:@"Line 97"];
    double shadowWidth=endArrow.center.x - startArrow.center.x;
    _endShadow.frame =CGRectMake(endArrow.frame.origin.x+(2*endArrowHalfWidth), endArrow.frame.origin.y,0,_Scrollview.frame.size.height);
    _startShadow.frame =CGRectMake(startArrow.frame.origin.x+(2*startArrowHalfWidth), startArrow.frame.origin.y, shadowWidth,_Scrollview.frame.size.height);
    _startShadow.backgroundColor = [UIColor colorWithRed:41.f/255.f green:41.f/255.f blue:41.f/255.f alpha:.92];
    
}
-(void) splitPressed{
    _endShadow.backgroundColor = [ UIColor clearColor];
    _startShadow.backgroundColor=[ UIColor clearColor];
    
    
    _startImage.image = nil;
    _endImage.image  = nil;
    _movingView.image = nil;
    _splitImage.image = [ UIImage imageNamed:@"Group 1033"];
    _splitView.frame = CGRectMake(_frameView.frame.origin.x+180, _frameView.frame.origin.y-2, _splitView.frame.size.width, _splitView.frame.size.height);
    
    
    
}

#pragma mark - Done Button Pressed


-(void) doneBtnPressed
{
 
    if(cutPressed)
    {
        [self videoCropFromAsset];
    }
    
    else if(trimPressed)
    {
        [ self videoTrimFromAsset];
    }
    else{
        [self videoSplitFromAsset];
    }
        
}


#pragma mark - VideoCropFromAsset
-(void) videoCropFromAsset
{
    
    
    
    val = (Time*((startArrow.center.x-startArrowHalfWidth)))/_frameView.frame.size.width;
    val1=(Time*(endArrow.center.x-2*endArrowHalfWidth))/_frameView.frame.size.width;
    
    
    startTime=CMTimeMakeWithSeconds(val, NSEC_PER_SEC);
    endTime = CMTimeMakeWithSeconds(val1, NSEC_PER_SEC);
  
    

    CMTimeRange range = CMTimeRangeMake(startTime, endTime);



    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *videoAssetTrack = [resultAsset tracksWithMediaType:AVMediaTypeVideo].lastObject;
    AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *audioAssetTrack = [resultAsset tracksWithMediaType:AVMediaTypeAudio].lastObject;
    CMTime time = kCMTimeZero;
    NSError *videoError;
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)
                                   ofTrack:videoAssetTrack
                                    atTime:time
                                     error:&videoError];
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)
                                   ofTrack:audioAssetTrack
                                    atTime:time
                                     error:&videoError];
    [videoCompositionTrack removeTimeRange:range];
    [audioCompositionTrack removeTimeRange:range];
    if (videoError) {
        NSLog(@"Error - %@", videoError.debugDescription);
    }
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
    
    NSURL *outputVideoURL=dataFilePath(@"tmpPost.mp4"); //url of exportedVideo
    
    exportSession.outputURL = outputVideoURL;
    
    exportSession.shouldOptimizeForNetworkUse = YES;
    
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    /**
     
     creating the time range i.e. make startTime and endTime.
     
     startTime should be the first frame time at which your exportedVideo should start.
     
     endTime is the time of last frame at which your exportedVideo should stop. OR it should be the duration of the         excpected exportedVideo length
     
     **/
    
    
    exportSession.timeRange = videoCompositionTrack.timeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
        
        switch (exportSession.status)
        
        {
                
            case
            AVAssetExportSessionStatusCompleted:
                
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSURL *finalUrl=dataFilePath(@"trimmedVideo.mp4");
                    
                    NSData *urlData = [NSData dataWithContentsOfURL:outputVideoURL];
                    
                    NSError *writeError;
                    
                    //write exportedVideo to path/trimmedVideo.mp4
                    
                    [urlData writeToURL:finalUrl options:NSAtomicWrite error:&writeError];
                    
                    if (!writeError) {
                        
                        //update Original URL
                        
                        // originalURL=finalUrl;
                        NSLog(@"saving");
                        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                        dispatch_async(q, ^{
                            
                            NSData *videoData = [NSData dataWithContentsOfURL:finalUrl];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                // Write it to cache directory
                                NSString *videoPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"file.mov"];
                                [videoData writeToFile:videoPath atomically:YES];
                                
                                // After that use this path to save it to PhotoLibrary
                                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                                [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:^(NSURL *assetURL, NSError *error)
                                 {
                                     if (error)
                                     {
                                         NSLog(@"Error");
                                     }
                                     else
                                     {
                                         NSString *message = @"Video Cut Done";
                                         UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                                                         message:message
                                                                                        delegate:nil
                                                                               cancelButtonTitle:nil
                                                                               otherButtonTitles:nil, nil];
                                         [toast show];
                                         
                                         int duration = 1; // duration in seconds
                                         
                                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                             [toast dismissWithClickedButtonIndex:0 animated:YES];
                                         });
                                         
                                         NSLog(@"Success");
                                     }
                                     
                                 }];
                            });
                        });
                        
                        //update video Properties
                        
                        // [self updateParameters];
                        
                    }
                    
                    NSLog(@"Cut Done %ld %@", (long)exportSession.status, exportSession.error);
                    
                });
                
                
            }
                
                break;
                
            case AVAssetExportSessionStatusFailed:
                
                NSLog(@"Cut failed with error ===>>> %@",exportSession.error);
                
                break;
                
            case AVAssetExportSessionStatusCancelled:
                
                NSLog(@"Canceled:%@",exportSession.error);
                
                break;
                
            default:
                
                break;
                
        }
        
    }];
    
}


#pragma mark - dataFilepathCreation
NSURL * dataFilePath(NSString *path){
    //creating a path for file and checking if it already exist if exist then delete it
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), path];
    
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //check if file exist at outputPath
    success = [fileManager fileExistsAtPath:outputPath];
    
    if (success) {
        //delete if file exist at outputPath
        success=[fileManager removeItemAtPath:outputPath error:nil];
    }
    
    return [NSURL fileURLWithPath:outputPath];
    
}

#pragma mark- video Trim
-(void) videoTrimFromAsset
{

    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:resultAsset presetName:AVAssetExportPresetHighestQuality];
    
    NSURL *outputVideoURL=dataFilePath(@"tmpPost.mp4");;
    
    exportSession.outputURL = outputVideoURL;
    
    exportSession.shouldOptimizeForNetworkUse = YES;
    
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
   
    
    val = (Time*((startArrow.center.x-startArrowHalfWidth)))/_frameView.frame.size.width;
    val1=(Time*(endArrow.center.x-2*endArrowHalfWidth))/_frameView.frame.size.width;
    
   
    startTime=CMTimeMakeWithSeconds(val, NSEC_PER_SEC);
    endTime = CMTimeMakeWithSeconds(val1, NSEC_PER_SEC);
    
    CMTimeRange range = CMTimeRangeMake(startTime, endTime);
    
    exportSession.timeRange = range;
    
    
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
    
            switch (exportSession.status)
    
            {
    
                case
                AVAssetExportSessionStatusCompleted:
    
                {
    
                    dispatch_async(dispatch_get_main_queue(), ^{
    
                      NSURL *finalUrl=dataFilePath(@"trimmedVideo.mp4");
    
                        NSData *urlData = [NSData dataWithContentsOfURL:outputVideoURL];
    
                        NSError *writeError;
    
                        //write exportedVideo to path/trimmedVideo.mp4
    
                        [urlData writeToURL:finalUrl options:NSAtomicWrite error:&writeError];
    
                        if (!writeError) {
    
                            //update Original URL
    
                            // originalURL=finalUrl;
                            NSLog(@"saving");
                            dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                            dispatch_async(q, ^{
    
                                NSData *videoData = [NSData dataWithContentsOfURL:outputVideoURL];
    
                                dispatch_async(dispatch_get_main_queue(), ^{
    
                                    // Write it to cache directory
                                    NSString *videoPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"file.mov"];
                                    [videoData writeToFile:videoPath atomically:YES];
    
                                    // After that use this path to save it to PhotoLibrary
                                    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                                    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:^(NSURL *assetURL, NSError *error)
                                     {
                                         if (error)
                                         {
                                             NSLog(@"Error");
                                         }
                                         else
                                         {
                                             NSString *message = @"Video Trim Done";
                                             UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                                                             message:message
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:nil
                                                                                   otherButtonTitles:nil, nil];
                                             [toast show];
    
                                             int duration = 1; // duration in seconds
    
                                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                 [toast dismissWithClickedButtonIndex:0 animated:YES];
                                             });
                                             NSLog(@"Success");
                                         }
    
                                     }];
                                });
                            });
    
                            //update video Properties
    
                            // [self updateParameters];
    
                        }
    
                        NSLog(@"Trim Done %ld %@", (long)exportSession.status, exportSession.error);
    
                    });
    
    
                }
    
                    break;
    
                case AVAssetExportSessionStatusFailed:
    
                    NSLog(@"Trim failed with error ===>>> %@",exportSession.error);
    
                    break;
    
                case AVAssetExportSessionStatusCancelled:
    
                    NSLog(@"Canceled:%@",exportSession.error);
    
                    break;
    
                default:
    
                    break;
    
            }
    
        }];
}
    



-(void) videoSplitFromAsset
{
    
    NSLog(@"videoSplitFromAsset---%f",_splitView.center.x);
    
    //First export session
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:resultAsset presetName:AVAssetExportPresetHighestQuality];
    NSURL *outputVideoURL=dataFilePath(@"tmpPost.mp4");;
    exportSession.outputURL = outputVideoURL;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    //Second export session
    AVAssetExportSession *exportSession1 = [[AVAssetExportSession alloc] initWithAsset:resultAsset presetName:AVAssetExportPresetHighestQuality];
    NSURL *outputVideoURL1=dataFilePath(@"tmpPost1.mp4");;
    exportSession1.outputURL = outputVideoURL1;
    exportSession1.shouldOptimizeForNetworkUse = YES;
    exportSession1.outputFileType = AVFileTypeQuickTimeMovie;
    
    
    
    //two time is calculated
    val = (Time*((_splitView.center.x-startArrowHalfWidth)))/_frameView.frame.size.width;
    val1=(Time*(_splitView.center.x-2*endArrowHalfWidth))/_frameView.frame.size.width;
    startTime=CMTimeMakeWithSeconds(val, NSEC_PER_SEC);
    endTime = CMTimeMakeWithSeconds(val1, NSEC_PER_SEC);
    
    
    float initialTime =0;
    CMTime initialCMTime = CMTimeMakeWithSeconds(initialTime, NSEC_PER_SEC);
    
    //Two ranges are taken
    CMTimeRange range1 = CMTimeRangeMake(initialCMTime, startTime);
    CMTimeRange range2 = CMTimeRangeMake(endTime, resultAsset.duration);
    
    
    
    
    
    
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

      NSLog(@"exportSession1");
    exportSession.timeRange = range1;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void){

        switch (exportSession.status)

        {

            case
            AVAssetExportSessionStatusCompleted:

            {

              

                    NSURL *finalUrl=dataFilePath(@"trimmedVideo.mp4");

                    NSData *urlData = [NSData dataWithContentsOfURL:outputVideoURL];

                    NSError *writeError;

                    //write exportedVideo to path/trimmedVideo.mp4

                    [urlData writeToURL:finalUrl options:NSAtomicWrite error:&writeError];

                    if (!writeError) {

                        //update Original URL

                        // originalURL=finalUrl;
                        NSLog(@"saving");
                        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                        dispatch_async(q, ^{

                            NSData *videoData = [NSData dataWithContentsOfURL:outputVideoURL];

                            dispatch_async(dispatch_get_main_queue(), ^{

                                // Write it to cache directory
                                NSString *videoPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"file.mov"];
                                [videoData writeToFile:videoPath atomically:YES];

                                // After that use this path to save it to PhotoLibrary
                                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                                [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:^(NSURL *assetURL, NSError *error)
                                 {
                                     if (error)
                                     {
                                         NSLog(@"Error");
                                     }
                                     else
                                     {
                                         NSString *message = @"Split Done ";
                                         UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                                                         message:message
                                                                                        delegate:nil
                                                                               cancelButtonTitle:nil
                                                                               otherButtonTitles:nil, nil];
                                         [toast show];
                                         
                                         int duration = 1; // duration in seconds
                                         
                                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                             [toast dismissWithClickedButtonIndex:0 animated:YES];
                                         });
                                         NSLog(@"Success");
                                         NSLog(@"Success");
                                     }

                                 }];
                            });
                        });

                        //update video Properties

                        // [self updateParameters];

                    }

                    NSLog(@"Trim Done %ld %@", (long)exportSession.status, exportSession.error);

            


            }

                break;

            case AVAssetExportSessionStatusFailed:

                NSLog(@"Trim failed with error ===>>> %@",exportSession.error);

                break;

            case AVAssetExportSessionStatusCancelled:

                NSLog(@"Canceled:%@",exportSession.error);

                break;

            default:

                break;

        }

    }];
 });

   
   
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSLog(@"exportSession2");
    exportSession1.timeRange = range2;
    [exportSession1 exportAsynchronouslyWithCompletionHandler:^(void){

        switch (exportSession1.status)

        {

            case
            AVAssetExportSessionStatusCompleted:

            {

//                dispatch_async(dispatch_get_main_queue(), ^{

                    NSURL *finalUrl1=dataFilePath(@"trimmedVideo1.mp4");

                    NSData *urlData1 = [NSData dataWithContentsOfURL:outputVideoURL1];

                    NSError *writeError1;

                    //write exportedVideo to path/trimmedVideo.mp4

                    [urlData1 writeToURL:finalUrl1 options:NSAtomicWrite error:&writeError1];

                    if (!writeError1) {

                        //update Original URL

                        // originalURL=finalUrl;
                        NSLog(@"saving");
                        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                        dispatch_async(q, ^{

                            NSData *videoData = [NSData dataWithContentsOfURL:outputVideoURL1];

                            dispatch_async(dispatch_get_main_queue(), ^{

                                // Write it to cache directory
                                NSString *videoPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"file1.mov"];
                                [videoData writeToFile:videoPath atomically:YES];

                                // After that use this path to save it to PhotoLibrary
                                ALAssetsLibrary *library1 = [[ALAssetsLibrary alloc] init];
                                [library1 writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:^(NSURL *assetURL, NSError *error)
                                 {
                                     if (error)
                                     {
                                         NSLog(@"Error");
                                     }
                                     else
                                     {
//                                         NSString *message = @"Split2 Done ";
//                                         UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
//                                                                                         message:message
//                                                                                        delegate:nil
//                                                                               cancelButtonTitle:nil
//                                                                               otherButtonTitles:nil, nil];
//                                         [toast show];
//
//                                         int duration = 1; // duration in seconds
//
//                                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                                             [toast dismissWithClickedButtonIndex:0 animated:YES];
//                                         });
//                                         NSLog(@"Success");
                                     }

                                 }];
                            });
                        });

                        //update video Properties

                        // [self updateParameters];

                    }

                    NSLog(@"Trim Done %ld %@", (long)exportSession1.status, exportSession1.error);

//                });


            }

                break;

            case AVAssetExportSessionStatusFailed:

                NSLog(@"Trim failed with error ===>>> %@",exportSession1.error);

                break;

            case AVAssetExportSessionStatusCancelled:

                NSLog(@"Canceled:%@",exportSession1.error);

                break;

            default:

                break;

        }

    }];
     });
 
    
    
    
}
    









#pragma  mark - back button is pressed

-(void) backButtonPressed
{
    UINavigationController *navigationController = self.navigationController;
    [navigationController popViewControllerAnimated:NO];
}



double p=0;
double xxx=0;
#pragma mark - synscruber to sync with view
- (void)syncScrubber
{
    if(playButtonClicked){
    NSLog(@"syncScrubber");
    val = (Time*((startArrow.center.x-startArrowHalfWidth)))/_frameView.frame.size.width;
    val1=(Time*(endArrow.center.x-2*endArrowHalfWidth))/_frameView.frame.size.width;
    
    startTime=CMTimeMakeWithSeconds(val, NSEC_PER_SEC);
    
    
    p= (endArrow.center.x-startArrow.center.x)/(val1-val);
    p=p*.01;
    
    NSLog(@"%f %f",_movingView.center.x,_movingView.center.y);

        
        double change =(Time*((_movingView.center.x)))/_frameView.frame.size.width;
        
    NSDateComponentsFormatter *dcFormatter = [[NSDateComponentsFormatter alloc] init];
    dcFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dcFormatter.allowedUnits = NSCalendarUnitMinute |NSCalendarUnitSecond;
    dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    NSString* result=[dcFormatter stringFromTimeInterval:change];
//    startTime=CMTimeMakeWithSeconds(change, NSEC_PER_SEC);
    _midLabel.text=result;
    _midLabel.textColor =[UIColor whiteColor];
    if(_movingView.center.x+p<endArrow.center.x-endArrowHalfWidth)
    {
        [_movingView setCenter:CGPointMake(_movingView.center.x+p, _movingView.center.y)];
    }
    else{
        [self.player pause];
    }
    }
    
    
    else{
    
    }
    
    

}

#pragma mark - calculate time
- (void) timeCalculation{
    playButtonClicked =1;
    val = (Time*((startArrow.center.x-startArrowHalfWidth)))/_frameView.frame.size.width;
    val1=(Time*(endArrow.center.x-2*endArrowHalfWidth))/_frameView.frame.size.width;
    
    startTime=CMTimeMakeWithSeconds(val, NSEC_PER_SEC);
    [self.player seekToTime:startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.player play];
    
    
    
}
#pragma mark - play button clicked
- (IBAction)btnClicked:(id)sender {

    
    if(_observer==nil){
        NSLog(@"Yess");
        [self timeCalculation];
        [_movingView setCenter:CGPointMake(startArrow.center.x+startArrowHalfWidth, _movingView.center.y)];
        


    }
    else{
        [self.player removeTimeObserver:_observer];
        [self timeCalculation];
      if(_movingView.center.x>startArrow.center.x+startArrowHalfWidth && _movingView.center.x< endArrow.center.x-(endArrow.frame.size.width/2))
      {
          [_movingView setCenter:CGPointMake(_movingView.center.x, _movingView.center.y)];
      }
        else
        {
             [_movingView setCenter:CGPointMake(startArrow.center.x+startArrowHalfWidth, _movingView.center.y)];
        }
    }
   CMTime invoke = CMTimeMakeWithSeconds(0.01, NSEC_PER_SEC);
    _observer=[_player addPeriodicTimeObserverForInterval:invoke
                                                    queue:NULL
                                               usingBlock:
               ^(CMTime time)
               
               {
                   [self syncScrubber];
               }];


}



#pragma mark - sliderMovement controll
-(void) sliderAction:(id) temp
{


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
//    NSLog(@"%f %f",_frameView.frame.size.height,self.frameVie
//    NSLog(@"%f",self.frameView.frame.size.width);
    imgHeight = self.frameView.frame.size.height;
    imgWidth = imgHeight;
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





#pragma mark - Generating UI View like start arrow,end arrow;

-(void) generateUIView
{


 
    //start Selector created
    [_Scrollview addSubview:startArrow];
    startArrow.backgroundColor = [ UIColor clearColor];
    [startArrow setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *panGestureForStartArrow = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanForStartArrow:)];
    [startArrow addGestureRecognizer:panGestureForStartArrow];


    // value for calculation in time
    NSLog(@"generate %f",startArrow.frame.size.width);
    startArrowHalfWidth = (startArrow.frame.size.width/2);
    endArrowHalfWidth = (endArrow.frame.size.width/2);
    
    
    // End Selector
    [_Scrollview addSubview:endArrow];
    endArrow.backgroundColor = [ UIColor clearColor];
    [endArrow setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *panGestureForEndArrow = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanForEndArrow:)];
    [endArrow addGestureRecognizer:panGestureForEndArrow];
   
    
    // Pan gesture for Moving arrow
    [_Scrollview addSubview:_movingView];
    [_movingView setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *panGestureMovingArrow = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanForMovingArrow:)];
    [_movingView addGestureRecognizer:panGestureMovingArrow];
    
    
    //Pan gesture for Split view
    
    
    [_Scrollview addSubview:_splitView];
    [_splitView setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *panGestureSplitView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanForSplitView:)];
    [_splitView addGestureRecognizer:panGestureSplitView];
    
    
    
    
    
    
    
}

#pragma mark - Pan gesture for Moving Arrow
- (void) handlePanForMovingArrow:(UIPanGestureRecognizer*) gesture {
    if(gesture.state == UIGestureRecognizerStateBegan){
        [self.player pause];
        playButtonClicked=0;
    
    }
    
   
    CGPoint translation = [gesture translationInView:_movingView ];
    NSLog(@"%f",translation.x);
    
  
    if(translation.x<0){
        
        [_movingView setCenter:CGPointMake(_movingView.center.x+translation.x, _movingView.center.y)];
        [_startLabel setCenter:CGPointMake(startArrow.center.x+translation.x, _startLabel.center.y)];
        
    }
    
    else{
//        [_startLabel setCenter:CGPointMake(startArrow.center.x+translation.x, _startLabel.center.y)];
        
         [_movingView setCenter:CGPointMake(_movingView.center.x+translation.x, _movingView.center.y)];
    }
    
    
    
    
    
    [gesture setTranslation:CGPointZero inView:_movingView];
    
    val = (Time*((_movingView.center.x)))/_frameView.frame.size.width;
    //creating time into string
    NSDateComponentsFormatter *dcFormatter = [[NSDateComponentsFormatter alloc] init];
    dcFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dcFormatter.allowedUnits =NSCalendarUnitMinute|NSCalendarUnitSecond ;
    dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    NSString* result=[dcFormatter stringFromTimeInterval:val];
    
    NSLog(@"%@",result);
    
    
    
    startTime=CMTimeMakeWithSeconds(val, NSEC_PER_SEC);
    [self.player seekToTime:startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
  
        _startLabel.text=@"";
        _startLabel.textColor= [ UIColor whiteColor];
        _midLabel.textColor= [ UIColor whiteColor];
        _midLabel.text=result;
 
    
}
    
    
    



#pragma mark - Handling Pan gesture of Start Arrow
- (void) handlePanForStartArrow:(UIPanGestureRecognizer*) gesture {
    
    
    if(trimPressed){
        [self trimPressed];
    }
    else if(cutPressed){
        
        [self cutPressed];
        
        
    }
    else{
        [self splitPressed];
    }
    
    
    
    
   NSLog(@"handle for start %f %f %f",startArrow.frame.size.width,startArrow.center.x,startArrowHalfWidth);
    
    
    
    [self.player pause];
    
    //Time calculation and seek to time
    val = (Time*((startArrow.center.x-startArrowHalfWidth)))/_frameView.frame.size.width;
    startTime=CMTimeMakeWithSeconds(val, NSEC_PER_SEC);
    [self.player seekToTime:startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    
    //creating time into string
    NSDateComponentsFormatter *dcFormatter = [[NSDateComponentsFormatter alloc] init];
    dcFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dcFormatter.allowedUnits =NSCalendarUnitMinute|NSCalendarUnitSecond ;
    dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    NSString* result=[dcFormatter stringFromTimeInterval:val];
    
    _startLabel.textColor=[UIColor whiteColor];
    _startLabel.text = result;

    
    
    double cngValue = _startLabel.frame.size.width;
    cngValue =cngValue/3;
    
    


    CGPoint translation = [gesture translationInView:startArrow];
    NSLog(@"%f",translation.x);
    
    if(translation.x<0){
        
        [startArrow setCenter:CGPointMake(startArrow.center.x+translation.x, startArrow.center.y)];
        [_startLabel setCenter:CGPointMake(startArrow.center.x+translation.x, _startLabel.center.y)];
       
        if(startArrow.center.x<((startArrowHalfWidth))){
            
            [startArrow setCenter:CGPointMake(0+(startArrowHalfWidth), endArrow.center.y)];
        }

    }
    
    else{
           [_startLabel setCenter:CGPointMake(startArrow.center.x+translation.x, _startLabel.center.y)];
   
        if(startArrow.center.x+startArrowHalfWidth < endArrow.center.x-endArrowHalfWidth){
            
            [ startArrow setCenter:CGPointMake(startArrow.center.x+translation.x, startArrow.center.y)];
            
        }
        
        //If still moves away
        if(startArrow.center.x+startArrowHalfWidth > endArrow.center.x-endArrowHalfWidth){
            [ startArrow setCenter:CGPointMake(endArrow.center.x-startArrow.frame.size.width, startArrow.center.y)];
        
          }
    }


    if(startArrow.center.x<2* cngValue)
    {
        [_startLabel setCenter:CGPointMake(startArrow.center.x+translation.x, _startLabel.center.y)];
    }
    
    
    [gesture setTranslation:CGPointZero inView:startArrow];
    if(gesture.state == UIGestureRecognizerStateEnded)
    {
        _startLabel.text=@"";
        _startLabel.textColor= [ UIColor whiteColor];
        _midLabel.textColor= [ UIColor whiteColor];
        _midLabel.text=result;
    }

}





#pragma mark - for Handling pan gesture of End Arrow
- (void) handlePanForEndArrow:(UIPanGestureRecognizer*) gesture {
    
    
    
    if(trimPressed){
        [self trimPressed];
    }
    else if(cutPressed){
        
        [self cutPressed];
        
    }
    else{
        [self splitPressed];
    }
    
    
    
    
//    NSLog(@"%f",endArrow.center.x);
    [self.player pause];
    playButtonClicked=0;
//    [_movingView setCenter:CGPointMake(-1000, _movingView.center.y)];
    val1=(Time*(endArrow.center.x-2*endArrowHalfWidth))/_frameView.frame.size.width;
    endTime=CMTimeMakeWithSeconds(val1, NSEC_PER_SEC);
    [self.player seekToTime:endTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    /// Converting seconds into result
    NSDateComponentsFormatter *dcFormatter = [[NSDateComponentsFormatter alloc] init];
    dcFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dcFormatter.allowedUnits = NSCalendarUnitMinute|NSCalendarUnitSecond ;
    dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    NSString* result=[dcFormatter stringFromTimeInterval:val1];

//    NSLog(@"%@",result);
    
    CGPoint translation = [gesture translationInView:endArrow];

    
    _endLabel.textColor=[UIColor whiteColor];
    _endLabel.text = result;

    double cngValue = _endLabel.frame.size.width;
    cngValue =cngValue/3;


    if(translation.x>0){
        
        [endArrow setCenter:CGPointMake(endArrow.center.x+translation.x, endArrow.center.y)];
        [_endLabel setCenter:CGPointMake(endArrow.center.x+translation.x, _endLabel.center.y)];
       
        
        
        //Gets outside of the boundary
        if(endArrow.center.x>_Scrollview.frame.size.width-(endArrow.frame.size.width/2)){
            
            [endArrow setCenter:CGPointMake(_Scrollview.frame.size.width-((endArrow.frame.size.width/2)), endArrow.center.y)];
            
            
        }
        
    }
    
    
    else{
          [_endLabel setCenter:CGPointMake(endArrow.center.x+translation.x, _endLabel.center.y)];
       
        if(startArrow.center.x+startArrowHalfWidth<endArrow.center.x-endArrowHalfWidth){
            [endArrow setCenter:CGPointMake(endArrow.center.x+translation.x, endArrow.center.y)];
        
        }
        
        //if still moves way
        if(startArrow.center.x+(startArrow.frame.size.width/2)>endArrow.center.x)
        {
            [endArrow setCenter:CGPointMake(startArrow.center.x+startArrow.frame.size.width, endArrow.center.y)];
        }
    }
    
    
    //Did here so that _endlabel jate baire na jay
    
    if(endArrow.center.x>_Scrollview.frame.size.width-(2* cngValue))
    {
        [_endLabel setCenter:CGPointMake(endArrow.center.x+translation.x-cngValue, _endLabel.center.y)];
    }
    

    [gesture setTranslation:CGPointZero inView:endArrow];
   

 if(gesture.state == UIGestureRecognizerStateEnded)
 {
  
     _endLabel.text = @"";
     _endLabel.textColor = [ UIColor whiteColor];
     _midLabel.textColor= [ UIColor whiteColor];
     _midLabel.text=result;
 }


}
- (void) handlePanForSplitView:(UIPanGestureRecognizer*) gesture {
    
    NSLog(@"HERE");
    CGPoint translation = [gesture translationInView:_splitView];
    [_splitView setCenter:CGPointMake(_splitView.center.x+translation.x,_splitView.center.y )];
    [gesture setTranslation:CGPointZero inView:_splitView];

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

