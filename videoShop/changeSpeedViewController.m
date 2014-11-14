//
//  changeSpeedViewController.m
//  videoShop
//
//  Created by unibera1 on 9/25/13.
//  Copyright (c) 2013 unibera. All rights reserved.
//

#import "changeSpeedViewController.h"

@interface changeSpeedViewController ()

@end

@implementation changeSpeedViewController
{
    AVPlayer *avPlayer;
    AVPlayerLayer *avPlayerLayer;
    UIImageView *imageView;
    double videoScaleFactor;
    int play;
    MyCell *selectedCell;
    ViewController *view1;
}

- (id)initWithNibName:(NSString *)nibNameOrNil url:(NSURL *)url cell:(MyCell *)cell view:(ViewController *)myView bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        selectedCell = cell;
        view1 = myView;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil url:(NSURL *)url bundle:(NSBundle *)nibBundleOrNil{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *sliderLeftTrackImage = [[UIImage imageNamed: @"slide-bar2.png"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
    UIImage *sliderRightTrackImage = [[UIImage imageNamed: @"slide-bar2.png"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
    [_slider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
    [_slider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];
    [_slider setThumbImage:[UIImage imageNamed:@"slider-button.png"] forState:UIControlStateNormal];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    play = 1;
    videoScaleFactor  =1;
    [self makeComposition];
}

-(BOOL)prefersStatusBarHidden{

    return YES;
}


-(void)preparePlayer:(AVMutableComposition *)mixComposition{
    
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:mixComposition];
    avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:avPlayerItem];
    [avPlayerItem release];
    avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:avPlayer];
    [avPlayerLayer setFrame:CGRectMake(5, 80, 310, 280)];
    [self.view.layer addSublayer:avPlayerLayer];
    [avPlayer seekToTime:kCMTimeZero];
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(130, 180, 60, 60)];
    [imageView setImage:[UIImage imageNamed:@"play.png"]];
    [self.view addSubview:imageView];
}

- (IBAction)playVideo:(UIButton *)sender {
    
    if(!play)
    {
        [avPlayer pause];
        play =1;
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(130, 190, 60, 60)];
        [imageView setImage:[UIImage imageNamed:@"play.png"]];
        [self.view addSubview:imageView];
        
    }
    else
    {
        NSLog(@"in Play");
        play = 0;
        [imageView setHidden:YES];
        [imageView removeFromSuperview];
        imageView.image = nil;
        [avPlayer play];
    }

}

-(void)itemDidFinishPlaying {
    
    NSLog(@"Stopped");
    [avPlayer pause];
    [avPlayer seekToTime:kCMTimeZero];
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(130, 190, 60, 60)];
    [imageView setImage:[UIImage imageNamed:@"play.png"]];
    [self.view addSubview:imageView];
    play = 1;
}

-(void)makeComposition{

    AVAsset *videoAsset = [AVAsset assetWithURL:selectedCell.url];
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // 3 - Video track
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    [videoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                    toDuration:CMTimeMake(videoAsset.duration.value *videoScaleFactor, videoAsset.duration.timescale)];
    //Audio track
    if([videoAsset tracksWithMediaType:AVMediaTypeAudio].count)
    {
        AVAssetTrack *audioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        CMTimeRange audio_timeRange = audioTrack.timeRange;
        AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
        [b_compositionAudioTrack scaleTimeRange:audioTrack.timeRange toDuration:CMTimeMake(audioTrack.timeRange.duration.value * videoScaleFactor, audioTrack.timeRange.duration.timescale)];
    }
    
    [self preparePlayer:mixComposition];
//    [mixComposition release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_slider release];
    [selectedCell release];
    [avPlayer release];
    [imageView release];
    [_fast release];
    [_slow release];
    [super dealloc];
}

- (IBAction)backButton:(UIButton *)sender {
    
    [avPlayer pause];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButton:(UIButton *)sender {
 
    
    AVAsset *videoAsset = [AVAsset assetWithURL:selectedCell.url];
   AVMutableComposition *mutableComposition = [[[AVMutableComposition alloc] init] autorelease];
    
    // 3 - Video track
    AVMutableCompositionTrack *videoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    [videoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                    toDuration:CMTimeMake(videoAsset.duration.value *videoScaleFactor, videoAsset.duration.timescale)];
    NSLog(@"video time = %f",CMTimeGetSeconds(videoTrack.timeRange.duration));
    
    //Audio track
    if([[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0])
    {
        AVAssetTrack *audioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        CMTimeRange audio_timeRange = audioTrack.timeRange;
        AVMutableCompositionTrack *b_compositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
        [b_compositionAudioTrack scaleTimeRange:audioTrack.timeRange toDuration:CMTimeMake(audioTrack.timeRange.duration.value * videoScaleFactor, audioTrack.timeRange.duration.timescale)];
    }
    
    NSString *tempDir = NSTemporaryDirectory();
    NSString *tmpVideoPath = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"tmpMov%d.mov",selectedCell.cellIndex]];
    [self deleteTmpFile:tmpVideoPath];
    
    NSLog(@"beginning export");
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = [NSURL fileURLWithPath:tmpVideoPath];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exportDidFinish:exporter];
        });
    }];
    
    NSLog(@"Ended");
}

- (void)exportDidFinish:(AVAssetExportSession*)session {
    if (session.status == AVAssetExportSessionStatusCompleted) {
        
        NSLog(@"session.status = %d",session.status);
        selectedCell.url = session.outputURL;
        [[urlAndThumbnails sharedSettings].urlArray replaceObjectAtIndex:selectedCell.cellIndex withObject:session.outputURL];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    CGPoint p = [(UITouch*)[touches anyObject] locationInView:self.view];
//    
//    NSLog(@"%f,%f",p.x,p.y);
//    NSLog(@"Play = %d",play);
//    if(CGRectContainsPoint(avPlayerLayer.frame, p))
//    {
//        if(!play)
//        {
//            [avPlayer pause];
//            play =1;
//             imageView = [[UIImageView alloc]initWithFrame:CGRectMake(130, 190, 60, 60)];
//            [imageView setImage:[UIImage imageNamed:@"play.png"]];
//            
//            [self.view addSubview:imageView];
//        }
//        else
//        {
//            NSLog(@"in Play");
//            play = 0;
//            imageView.image = nil;
//            [imageView setHidden:YES];
//            [imageView removeFromSuperview];
//            [avPlayer play];
//        }
//    }
}


- (IBAction)sliderChangeSpeed:(UISlider *)sender {
    
    videoScaleFactor = 3.1 - sender.value;
    NSLog(@"videoScaleFactor = %f",videoScaleFactor);
    selectedCell.videoScaleFactor = videoScaleFactor;
    [avPlayer pause];
    [avPlayerLayer removeFromSuperlayer];
    imageView.image = nil;
    [imageView setHidden:YES];
    [imageView removeFromSuperview];
    play = 1;
    [self makeComposition];
}

-(void)deleteTmpFile :(NSString *)tmp{
    
    NSLog(@"in changeSpeedDelete");
    NSURL *url = [NSURL fileURLWithPath:tmp];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        NSLog(@"file deleted");
//        if (err) {
//            NSLog(@"file remove error, %@", err.localizedDescription );
//        }
    } else {
        NSLog(@"no file by that name");
    }
}

@end
