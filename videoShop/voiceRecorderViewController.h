//
//  voiceRecorderViewController.h
//  videoShop
//
//  Created by unibera1 on 9/25/13.
//  Copyright (c) 2013 unibera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <MediaPlayer/MediaPlayer.h>
#include <AssetsLibrary/AssetsLibrary.h>
#import "urlAndThumbnails.h"
#import "MyCell.h"
#import "HRLoading.h"
#import "ViewController.h"

@class ViewController;
@interface voiceRecorderViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIImageView *micImageView;
- (IBAction)backButton:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UILabel *seekTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *timerLabel;
@property (retain, nonatomic) IBOutlet UIButton *previewButton;
@property (retain, nonatomic) IBOutlet UIButton *resetRecorderOutlet;
- (IBAction)resetRecorderButton:(UIButton *)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil url:(NSURL *)url cell:(MyCell *)cell view:(ViewController *)myView bundle:(NSBundle *)nibBundleOrNil;
- (IBAction)previewButton:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIButton *recordButton;
- (IBAction)saveButton:(UIButton *)sender;
- (IBAction)recordButton:(UIButton *)sender;
@end
