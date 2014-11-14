//
//  PlayerView.h
//  X4 Video Player
//
//  Created by Hemkaran Raghav on 10/4/13.
//  Copyright (c) 2013 Mahesh Gera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "mergeVideosViewController.h"
#import <AVFoundation/AVFoundation.h>

@class PlayerView;

@protocol playerViewDelegate <NSObject>

-(void)playerViewZoomButtonClicked:(PlayerView*)view;

@end

@interface PlayerView : UIView

@property (retain, nonatomic) id <playerViewDelegate> delegate;
@property (assign, nonatomic) BOOL isFullScreenMode;
@property (retain, nonatomic) NSURL *contentURL;
@property (retain, nonatomic) AVPlayer *moviePlayer;
@property (assign, nonatomic) BOOL isPlaying;

@property (retain, nonatomic) UIButton *playPauseButton;
@property (retain, nonatomic) UIButton *volumeButton;
@property (retain, nonatomic) UIButton *zoomButton;

@property (retain, nonatomic) UISlider *progressBar;
@property (retain, nonatomic) UISlider *volumeBar;

@property (retain, nonatomic) UILabel *playBackTime;
@property (retain, nonatomic) UILabel *playBackTotalTime;

@property (retain,nonatomic) UIView *playerManageViewTop;
@property (retain,nonatomic) UIView *playerManageViewBottom;


- (id)initWithFrame:(CGRect)frame contentURL:(NSURL*)contentURL;
-(id)initWithFrame:(CGRect)frame playerItem:(AVPlayerItem*)playerItem;
-(void)play;
-(void)pause;
@end
