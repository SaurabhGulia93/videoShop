//
//  changeSpeedViewController.h
//  videoShop
//
//  Created by unibera1 on 9/25/13.
//  Copyright (c) 2013 unibera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import <CoreVideo/CoreVideo.h>
#import <MediaPlayer/MediaPlayer.h>
#include <AssetsLibrary/AssetsLibrary.h>
#include "urlAndThumbnails.h"
#import "MyCell.h"
@class ViewController;
@interface changeSpeedViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIImageView *slow;
@property (retain, nonatomic) IBOutlet UIImageView *fast;
- (IBAction)backButton:(UIButton *)sender;
- (IBAction)saveButton:(UIButton *)sender;
- (IBAction)sliderChangeSpeed:(UISlider *)sender;
@property (retain, nonatomic) IBOutlet UISlider *slider;
- (IBAction)playVideo:(UIButton *)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil url:(NSURL *)url bundle:(NSBundle *)nibBundleOrNil;
- (id)initWithNibName:(NSString *)nibNameOrNil url:(NSURL *)url cell:(MyCell *)cell view:(ViewController *)myView bundle:(NSBundle *)nibBundleOrNil;
-(void)preparePlayer:(AVMutableComposition *)mixComposition;
- (void)exportDidFinish:(AVAssetExportSession*)session;
@end
