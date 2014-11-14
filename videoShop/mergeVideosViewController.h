//
//  mergeVideosViewController.h
//  videoShop
//
//  Created by unibera1 on 9/26/13.
//  Copyright (c) 2013 unibera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreVideo/CoreVideo.h>
#import "urlAndThumbnails.h"
#include "MyCell.h"
#import "PlayerView.h"
#import <QuartzCore/QuartzCore.h>

@interface mergeVideosViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (retain, nonatomic) IBOutlet UIView *titleAuthorPlaceView;
- (IBAction)titleAuthorPlace:(UIButton *)sender;
- (IBAction)saveButton:(UIButton *)sender;
- (IBAction)backButton:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UICollectionView *themesCollectionCell;
//- (id)initWithNibName:(NSString *)nibNameOrNil cellArray:(NSMutableArray *)array bundle:(NSBundle *)nibBundleOrNil;
- (id)initWithNibName:(NSString *)nibNameOrNil urls:(NSMutableArray *)urlarray themeArray:(NSMutableArray *)themearray bundle:(NSBundle *)nibBundleOrNil;

-(void)mergeVideos;
-(void)removeLayers;
@end
