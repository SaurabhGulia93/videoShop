//
//  PlayerView.m
//  X4 Video Player
//
//  Created by Hemkaran Raghav on 10/4/13.
//  Copyright (c) 2013 Mahesh Gera. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView
{
    id playbackObserver;
    AVPlayerLayer *playerLayer;
    BOOL viewIsShowing;
    mergeVideosViewController *merge;
}

-(id)initWithFrame:(CGRect)frame playerItem:(AVPlayerItem*)playerItem
{
    self = [super initWithFrame:frame];
    if (self) {
        self.moviePlayer = [AVPlayer playerWithPlayerItem:playerItem];
        playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.moviePlayer];
        [playerLayer setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.moviePlayer seekToTime:kCMTimeZero];
        [self.layer addSublayer:playerLayer];
        self.contentURL = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFinishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        
        [self initializePlayer:frame];
        merge = [[mergeVideosViewController alloc]init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame contentURL:(NSURL*)contentURL
{
    self = [super initWithFrame:frame];
    if (self) {
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:contentURL];
        self.moviePlayer = [AVPlayer playerWithPlayerItem:playerItem];
        playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.moviePlayer];
        [playerLayer setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.moviePlayer seekToTime:kCMTimeZero];
        [self.layer addSublayer:playerLayer];
        self.contentURL = contentURL;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFinishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        
        [self initializePlayer:frame];
    }
    return self;
}

-(void)initializePlayer:(CGRect)frame
{
    int frameWidth =  frame.size.width;
    int frameHeight = frame.size.height;
    
    viewIsShowing =  NO;
    self.isFullScreenMode = NO;
    
    [self.layer setMasksToBounds:YES];
    
    self.playerManageViewTop = [[[UIView alloc] init] autorelease];
    self.playerManageViewTop.frame = CGRectMake(0, 0-32*frameHeight/160, frameWidth, 32*frameHeight/160);
    [self.playerManageViewTop setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.playerManageViewTop];
    
    UIView *backgroundView = [[[UIView alloc] init] autorelease];
    backgroundView.frame = CGRectMake(0, 0, frameWidth, 32*frameHeight/160);
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.4;
    [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [self.playerManageViewTop addSubview:backgroundView];
    
    self.playerManageViewBottom = [[[UIView alloc] init] autorelease];
    self.playerManageViewBottom.frame = CGRectMake(0, 112*frameHeight/160 + 48*frameHeight/160, frameWidth, 48*frameHeight/160);
    [self.playerManageViewBottom setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.playerManageViewBottom];
    
    UIView *bgView = [[[UIView alloc] init] autorelease];
    bgView.frame = CGRectMake(0, 0, frameWidth, 48*frameHeight/160);
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.4;
    [self.playerManageViewBottom addSubview:bgView];
    
    //Play Pause Button
    self.playPauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.playPauseButton.frame = CGRectMake(5*frameWidth/240, 6*frameHeight/160, 34*frameWidth/240, 34*frameHeight/160);
    [self.playPauseButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playPauseButton setSelected:NO];
    [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"pauseButton"] forState:UIControlStateSelected];
    [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
    [self.playPauseButton setTintColor:[UIColor clearColor]];
    [self.playerManageViewBottom addSubview:self.playPauseButton];
    
    //VolumeButton
    self.volumeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.volumeButton.frame = CGRectMake(5*frameWidth/240, 2*frameHeight/160, 30*frameWidth/240, 30*frameHeight/160);
    [self.volumeButton addTarget:self action:@selector(volumeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.volumeButton setSelected:YES];
    [self.volumeButton setBackgroundImage:[UIImage imageNamed:@"soundOn"] forState:UIControlStateSelected];
    [self.volumeButton setBackgroundImage:[UIImage imageNamed:@"soundOff"] forState:UIControlStateNormal];
    [self.volumeButton setTintColor:[UIColor clearColor]];
    [self.playerManageViewTop addSubview:self.volumeButton];
    
    //zoom button
    self.zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.zoomButton.frame = CGRectMake(187*frameWidth/240, 2*frameHeight/160, 30*frameWidth/240, 30*frameHeight/160);
    [self.zoomButton addTarget:self action:@selector(zoomButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.zoomButton setBackgroundImage:[UIImage imageNamed:@"zoom"] forState:UIControlStateNormal];
    [self.playerManageViewTop addSubview:self.zoomButton];
    
    //Seek Time Progress Bar
    self.progressBar = [[[UISlider alloc] init] autorelease];
    self.progressBar.frame = CGRectMake(44*frameWidth/240, 6*frameHeight/160, 187*frameWidth/240,33*frameHeight/160);
    [self.progressBar addTarget:self action:@selector(progressBarChanged:) forControlEvents:UIControlEventValueChanged];
    [self.progressBar addTarget:self action:@selector(proressBarChangeEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.progressBar setThumbImage:[UIImage imageNamed:@"Slider_button"] forState:UIControlStateNormal];
    [self.playerManageViewBottom addSubview:self.progressBar];
    
    //Volume Progress Bar
    self.volumeBar = [[[UISlider alloc] init] autorelease];
    self.volumeBar.frame = CGRectMake(44*frameWidth/240, 0*frameHeight/160, 130*frameWidth/240, 33*frameHeight/160);
    [self.volumeBar addTarget:self action:@selector(volumeBarChanged:) forControlEvents:UIControlEventValueChanged];
    [self.volumeBar setValue:self.moviePlayer.volume];
    [self.volumeBar setThumbImage:[UIImage imageNamed:@"Slider_button"] forState:UIControlStateNormal];
    [self.playerManageViewTop addSubview:self.volumeBar];
    
    //Current Time Label
    self.playBackTime = [[[UILabel alloc] init] autorelease];
    self.playBackTime.frame = CGRectMake(44*frameWidth/240, 24*frameHeight/160, 42*frameWidth/240, 21*frameHeight/160);
    self.playBackTime.text = [self getStringFromCMTime:self.moviePlayer.currentTime];
    [self.playBackTime setTextAlignment:NSTextAlignmentLeft];
    [self.playBackTime setTextColor:[UIColor whiteColor]];
    self.playBackTime.font = [UIFont systemFontOfSize:12*frameWidth/240];
    [self.playerManageViewBottom addSubview:self.playBackTime];
    
    //Total Time label
    self.playBackTotalTime = [[[UILabel alloc] init] autorelease];
    self.playBackTotalTime.frame = CGRectMake(187*frameWidth/240, 24*frameHeight/160, 42*frameWidth/240, 21*frameHeight/160);
    self.playBackTotalTime.text = [self getStringFromCMTime:self.moviePlayer.currentItem.asset.duration];
    [self.playBackTotalTime setTextAlignment:NSTextAlignmentRight];
    [self.playBackTotalTime setTextColor:[UIColor whiteColor]];
    self.playBackTotalTime.font = [UIFont systemFontOfSize:12*frameWidth/240];
    [self.playerManageViewBottom addSubview:self.playBackTotalTime];
    
    for (UIView *view in [self subviews]) {
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    CMTime interval = CMTimeMake(33, 1000);
    playbackObserver = [self.moviePlayer addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock: ^(CMTime time) {
        CMTime endTime = CMTimeConvertScale (self.moviePlayer.currentItem.asset.duration, self.moviePlayer.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
        if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
            double normalizedTime = (double) self.moviePlayer.currentTime.value / (double) endTime.value;
            self.progressBar.value = normalizedTime;
        }
        self.playBackTime.text = [self getStringFromCMTime:self.moviePlayer.currentTime];
    }];
}

//-(void)layoutSubviews
//{
//    NSLog(@"layout subviews called");
//    int frameWidth =  self.frame.size.width;
//    int frameHeight = self.frame.size.height;
//    [playerLayer setFrame:CGRectMake(0, 0, frameWidth, frameHeight)];
//
//    self.playerManageViewTop.layer.frame = CGRectMake(0, 0, frameWidth, 32*frameHeight/160);
//
//    self.playerManageViewBottom.layer.frame = CGRectMake(0, 112*frameHeight/160, frameWidth, 48*frameHeight/160);
//    self.playPauseButton.layer.frame = CGRectMake(5*frameWidth/240, 6*frameHeight/160, 34*frameWidth/240, 34*frameHeight/160);
//    self.volumeButton.layer.frame = CGRectMake(5*frameWidth/240, 2*frameHeight/160, 30*frameWidth/240, 30*frameHeight/160);
//    self.zoomButton.layer.frame = CGRectMake(187*frameWidth/240, 2*frameHeight/160, 30*frameWidth/240, 30*frameHeight/160);
//    self.progressBar.layer.frame = CGRectMake(44*frameWidth/240, 6*frameHeight/160, 187*frameWidth/240,33*frameHeight/160);
//    self.volumeBar.layer.frame = CGRectMake(44*frameWidth/240, 0*frameHeight/160, 130*frameWidth/240, 33*frameHeight/160);
//    self.playBackTime.layer.frame = CGRectMake(44*frameWidth/240, 24*frameHeight/160, 42*frameWidth/240, 21*frameHeight/160);
//    self.playBackTotalTime.layer.frame = CGRectMake(187*frameWidth/240, 24*frameHeight/160, 42*frameWidth/240, 21*frameHeight/160);
//}

-(void)zoomButtonPressed:(UIButton*)sender
{
//    [UIView animateWithDuration:0.5 animations:^{
//        [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
//    }];
    [self.delegate playerViewZoomButtonClicked:self];
}

-(void)setIsFullScreenMode:(BOOL)isFullScreenMode
{
    _isFullScreenMode = isFullScreenMode;
    if (isFullScreenMode) {
        self.backgroundColor = [UIColor blackColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

-(void)playerFinishedPlaying
{
    [self.moviePlayer pause];
    [self.moviePlayer seekToTime:kCMTimeZero];
    [self.playPauseButton setSelected:NO];
    self.isPlaying = NO;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [(UITouch*)[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(playerLayer.frame, point)) {
        if (viewIsShowing) {
            [UIView animateWithDuration:0.3 animations:^{
                [self.playerManageViewBottom setFrame:CGRectMake(self.playerManageViewBottom.frame.origin.x, self.playerManageViewBottom.frame.origin.y  + self.playerManageViewBottom.frame.size.height,self.playerManageViewBottom.frame.size.width, self.playerManageViewBottom.frame.size.height)];
                [self.playerManageViewTop setFrame:CGRectMake(self.playerManageViewTop.frame.origin.x, self.playerManageViewTop.frame.origin.y  - self.playerManageViewTop.frame.size.height,self.playerManageViewTop.frame.size.width, self.playerManageViewTop.frame.size.height)];
                viewIsShowing = NO;
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                [self.playerManageViewBottom setFrame:CGRectMake(self.playerManageViewBottom.frame.origin.x, self.playerManageViewBottom.frame.origin.y  - self.playerManageViewBottom.frame.size.height,self.playerManageViewBottom.frame.size.width, self.playerManageViewBottom.frame.size.height)];
                [self.playerManageViewTop setFrame:CGRectMake(self.playerManageViewTop.frame.origin.x, self.playerManageViewTop.frame.origin.y  + self.playerManageViewTop.frame.size.height,self.playerManageViewTop.frame.size.width, self.playerManageViewTop.frame.size.height)];
                viewIsShowing = YES;
            }];
        }
    }
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

-(void)volumeButtonPressed:(UIButton*)sender
{
    if (sender.isSelected) {
        [self.moviePlayer setMuted:YES];
        [sender setSelected:NO];
    } else {
        [self.moviePlayer setMuted:NO];
        [sender setSelected:YES];
    }
}

-(void)playButtonAction:(UIButton*)sender
{
    if (self.isPlaying) {
        [self pause];
//        [sender setSelected:NO];
    } else {
        [self play];
//        [sender setSelected:YES];
    }
}

-(void)progressBarChanged:(UISlider*)sender
{
    if (self.isPlaying) {
        [self.moviePlayer pause];
    }
    CMTime seekTime = CMTimeMakeWithSeconds(sender.value * (double)self.moviePlayer.currentItem.asset.duration.value/(double)self.moviePlayer.currentItem.asset.duration.timescale, self.moviePlayer.currentTime.timescale);
    [self.moviePlayer seekToTime:seekTime];
}

-(void)proressBarChangeEnded:(UISlider*)sender
{
    if (self.isPlaying) {
        [self.moviePlayer play];
    }
}

-(void)volumeBarChanged:(UISlider*)sender
{
    [self.moviePlayer setVolume:sender.value];
}

-(void)play
{
    [self.moviePlayer play];
    self.isPlaying = YES;
    [self.playPauseButton setSelected:YES];
    [merge removeLayers];
}

-(void)pause
{
    [self.moviePlayer pause];
    self.isPlaying = NO;
    [self.playPauseButton setSelected:NO];
}

-(void)dealloc
{
    [self.moviePlayer removeTimeObserver:playbackObserver];
    [super dealloc];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
