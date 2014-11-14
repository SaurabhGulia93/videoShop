//
//  ViewController.h
//  videoShop
//
//  Created by unibera1 on 9/23/13.
//  Copyright (c) 2013 unibera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "ELCAssetTablePicker.h"
#import "urlAndThumbnails.h"
#import "MyCell.h"
#import "voiceRecorderViewController.h"
#include "mergeVideosViewController.h"
#import "changeSpeedViewController.h"
#import "PlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
- (IBAction)adjustSoundButton:(UISlider *)sender;
@property (retain, nonatomic) IBOutlet UISlider *adjustSoundSlider;
@property (retain, nonatomic) IBOutlet UIImageView *testImageView;
- (IBAction)audioChange:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIView *adjustMusic;
- (IBAction)chooseVideoAlbum:(UIButton *)sender;
- (IBAction)recordVideo:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIView *selectVideoView;
- (IBAction)transitionButtonClicked:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIImageView *transitionImageView;
@property (retain, nonatomic) IBOutlet UIView *transitionView;
- (IBAction)mergeVideosButton:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIView *bottomView;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)LoadVIdeos:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIButton *addButton;
@property (retain, nonatomic) IBOutlet UICollectionView *collectionView;
@property (retain, nonatomic) IBOutlet UIImageView *bottomImageView;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
-(void)prepareAVplayer:(NSURL *)url;
-(void)getVideos;
-(void)makeScrollView;
-(void)cutVideo:(NSURL *)url;
-(void)recordVoice:(NSURL *)url;
-(void)changeSpeed:(NSURL *)url;
-(void)changeMusic:(NSURL *)url;
-(void)delVideo:(NSURL *)url;
@end
