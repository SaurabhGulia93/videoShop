//
//  voiceRecorderViewController.m
//  videoShop
//
//  Created by unibera1 on 9/25/13.
//  Copyright (c) 2013 unibera. All rights reserved.
//

#import "voiceRecorderViewController.h"

@interface voiceRecorderViewController ()<AVAudioRecorderDelegate, AVAudioPlayerDelegate,UIAlertViewDelegate>

@end

@implementation voiceRecorderViewController
{

    NSURL *videoUrl;
    NSURL *audioUrl;
    NSURL *recordedVideo;
    AVPlayer *avPlayer;
    AVPlayerLayer *avPlayerLayer;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    AVAudioSession *audioSession;
    AVMutableComposition *mutableComposition;
    BOOL timerStarted;
    BOOL isFinished;
    id playbackObserver;
    NSOperationQueue *queue;
    NSInvocationOperation *op;
    NSArray *images;
    NSMutableArray *animationArray;
    BOOL leftViewFlag,rightViewFlag,canSave;
    int originOfLeftView,originOfRightView;
    HRLoading *loadingView;
    AVAssetExportSession *exporter;
    int taskUserWants;
    NSTimer *progressTimer;
    int frameWidth,frameHeight;
    MyCell *selectedCell;
    ViewController *view1;
}


- (id)initWithNibName:(NSString *)nibNameOrNil url:(NSURL *)url cell:(MyCell *)cell view:(ViewController *)myView bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
        videoUrl =url;
        selectedCell = cell;
        view1 = myView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    frameHeight = [UIScreen mainScreen].bounds.size.height;
    frameWidth = [UIScreen mainScreen].bounds.size.width;
    canSave = NO;
    images = @[@"11.png",@"22.png",@"33.png",@"44.png",@"55.png"];
    animationArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < images.count; i++) {
        [animationArray addObject:[UIImage imageNamed:[images objectAtIndex:i]]];
    }
    [animationArray retain];
}


-(BOOL)prefersStatusBarHidden{

    return  YES;
}

-(void)viewWillAppear:(BOOL)animated{

    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [_timerLabel setHidden:YES];
    [_seekTimeLabel setHidden:YES];
    [_resetRecorderOutlet setEnabled:NO];
    [_previewButton setEnabled:NO];
    [_resetRecorderOutlet.layer setOpacity:0.2];
    [_previewButton.layer setOpacity:0.2];
    [self makePath];
    [self prepareAvPlayer];
}

-(void)prepareAvPlayer{
    
    AVURLAsset * asset = [AVURLAsset URLAssetWithURL:selectedCell.url options:nil];
    NSLog(@"asset duration = %f",CMTimeGetSeconds(asset.duration));
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    
    // Mute all the audio tracks
    NSMutableArray * allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =[AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    
    AVMutableAudioMix * audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];
    
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:asset];
    [avPlayerItem setAudioMix:audioZeroMix];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:avPlayerItem];
    avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:avPlayer];
    [avPlayerLayer setFrame:CGRectMake(10*frameWidth/320, 100*frameHeight/480, 300*frameWidth/320, 228*frameHeight/480)];
    [self.view.layer addSublayer:avPlayerLayer];
    [avPlayer seekToTime:kCMTimeZero];
}

-(void)makeComposition{
    
    AVAsset *videoAsset = [AVAsset assetWithURL:selectedCell.url];
    mutableComposition = [[AVMutableComposition alloc] init];
    
    // 3 - Video track
    AVMutableCompositionTrack *videoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //Audio track
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audioUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    AVMutableCompositionTrack *b_compositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    [audioAsset release];
}

-(void)makePath{
    
    NSString *tempDir = NSTemporaryDirectory();
    NSString *tmpVideoPath = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"recMov%d.mov",selectedCell.cellIndex]];
    [self deleteTmpFile:tmpVideoPath];
    
    NSString *audioOutputPath = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"recordAudio%d.mp4",selectedCell.cellIndex]];
    [self deleteTmpFile:audioOutputPath];
    audioUrl = [[NSURL fileURLWithPath:audioOutputPath] retain];
    recordedVideo = [[NSURL fileURLWithPath:tmpVideoPath] retain];
}

-(void)deleteTmpFile :(NSString *)tmp{
    
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

-(void)itemDidFinishPlaying {
    
    NSLog(@"Stopped");
    op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(resetRecorder) object:nil];
    [queue addOperation:op];
    [op release];
    isFinished = YES;
    timerStarted = NO;
    [_recordButton setEnabled:NO];
    [_resetRecorderOutlet setEnabled:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [videoUrl release];
    [audioUrl release];
    [recordedVideo release];
    [view1 release];
    [_recordButton release];
    [_resetRecorderOutlet release];
    [_previewButton release];
    [_timerLabel release];
    [_seekTimeLabel release];
    [recorder release];
    [avPlayer release];
    [player release];
    [audioSession release];
    [queue release];
    [_micImageView release];
    [super dealloc];
}

-(void)resetRecorder
{
    [recorder stop];
    [avPlayer pause];
    if (recorder) {
        [recorder release];
        recorder = nil;
    }
}

- (IBAction)resetRecorderButton:(UIButton *)sender {

    [queue cancelAllOperations];
    [_micImageView stopAnimating];
    if(!isFinished)
    {
        op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(resetRecorder) object:nil];
        [queue addOperation:op];
        [op release];
    }
    isFinished = NO;
    [avPlayerLayer removeFromSuperlayer];
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    timerStarted = NO;
    [_timerLabel setHidden:YES];
    [_seekTimeLabel setHidden:YES];
    [_previewButton setEnabled:NO];
    [_resetRecorderOutlet setEnabled:NO];
    [_resetRecorderOutlet.layer setOpacity:0.2];
    [_previewButton.layer setOpacity:0.2];
    [_recordButton setEnabled:YES];
    [self makePath];
    [self prepareAvPlayer];


}

- (IBAction)saveButton:(UIButton *)sender {
   
    if(!timerStarted)
    {
        UIAlertView *alert = [[[UIAlertView alloc]initWithTitle:@"" message:@"You cannot save without recording" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]autorelease];
        [alert show];
    }
    else
    {
        [recorder stop];
        [avPlayer pause];
        
        audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        [self makeComposition];
        exporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition
                                                                          presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL=recordedVideo;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (exporter.status == AVAssetExportSessionStatusCompleted) {
                    
                    NSLog(@"session.status = %d",exporter.status);
                    selectedCell.url = exporter.outputURL;
                    [[urlAndThumbnails sharedSettings].urlArray replaceObjectAtIndex:selectedCell.cellIndex withObject:exporter.outputURL];
                    [avPlayerLayer removeFromSuperlayer];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }

            });
        }];

    }
}

- (IBAction)recordButton:(UIButton *)sender {

    if(!timerStarted)
    {
        [_timerLabel setHidden:NO];
        [_seekTimeLabel setHidden:NO];
        [_resetRecorderOutlet setEnabled:YES];
        [_previewButton setEnabled:YES];
        [_resetRecorderOutlet.layer setOpacity:1];
        [_previewButton.layer setOpacity:1];
        [_seekTimeLabel setText:@" "];
        timerStarted  =YES;
        CMTime interval = CMTimeMake(33, 1000);
        playbackObserver = [avPlayer addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock: ^(CMTime time) {
            CMTime endTime = CMTimeConvertScale (avPlayer.currentItem.asset.duration, avPlayer.currentTime.timescale, kCMTimeRoundingMethod_RoundTowardZero);
            if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
                self.seekTimeLabel.text = [self getStringFromCMTime:avPlayer.currentTime];
            }
            else
            {
                NSLog(@"in ELSE");
            }
        }];
    }
    
    [queue cancelAllOperations];
    canSave = YES;
    if (!recorder || !recorder.recording) {
        [avPlayer play];
        _micImageView.animationImages = animationArray;
        _micImageView.animationDuration = 0.5;
        [_micImageView startAnimating];
        op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(startRecorder) object:nil];
    }
    else {
        [avPlayer pause];
        [_micImageView stopAnimating];
        op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(stopRecorder) object:nil];
    }
    [queue addOperation:op];
    [op release];

}

-(void)startRecorder{
    
    if (!recorder) {
        NSLog(@"into Recorder alloc");
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        // Initiate and prepare the recorder
        recorder = [[AVAudioRecorder alloc] initWithURL:audioUrl settings:recordSetting error:NULL];
        recorder.delegate = self;
        recorder.meteringEnabled = YES;
        [recorder prepareToRecord];
        [recordSetting release];
    }
    [recorder record];
}

-(void)stopRecorder{
    
    [recorder pause];
}

-(NSString*)getStringFromCMTime:(CMTime)time
{
    Float64 currentSeconds = CMTimeGetSeconds(time);
    int mins = currentSeconds/60.0;
    int secs = fmodf(currentSeconds, 60.0);
    NSString *minsString = mins < 10 ? [NSString stringWithFormat:@"0%d", mins] : [NSString stringWithFormat:@"%d", mins];
    NSString *secsString = secs < 10 ? [NSString stringWithFormat:@"0%d", secs] : [NSString stringWithFormat:@"%d", secs];
    return [NSString stringWithFormat:@"%@:%@", minsString, secsString];
}

- (IBAction)previewButton:(UIButton *)sender {
   
    [recorder stop];
    [_micImageView stopAnimating];
    [avPlayer pause];
    if (recorder) {
        [recorder release];
        recorder = nil;
    }
    
    [avPlayerLayer removeFromSuperlayer];
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [_recordButton setEnabled:NO];
    [_resetRecorderOutlet setEnabled:YES];
    [_timerLabel setHidden:YES];
    [_seekTimeLabel setHidden:YES];
    [_resetRecorderOutlet.layer setOpacity:1];
    [_previewButton.layer setOpacity:1];
    [self makeComposition];
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:mutableComposition];
    avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    [avPlayerItem release];
    avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:avPlayer];
    [avPlayerLayer setFrame:CGRectMake(10*frameWidth/320, 100*frameHeight/480, 300*frameWidth/320, 228*frameHeight/480)];
    [self.view.layer addSublayer:avPlayerLayer];
    [avPlayer seekToTime:kCMTimeZero];
    [avPlayer play];
}

- (IBAction)backButton:(UIButton *)sender {

    [recorder stop];
    [avPlayer pause];
    [queue cancelAllOperations];
    [_micImageView stopAnimating];
    //    [avPlayerLayer removeFromSuperlayer];
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [self dismissViewControllerAnimated:YES completion:nil];


}
@end
