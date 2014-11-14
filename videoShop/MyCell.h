//
//  MyCell.h
//  videoShop
//
//  Created by unibera1 on 9/24/13.
//  Copyright (c) 2013 unibera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MyCell : UICollectionViewCell
@property (retain, nonatomic) IBOutlet UIImageView *backGroundImage;
@property (retain, nonatomic) IBOutlet UIImageView *thumbNailImageview;
@property (nonatomic,assign) BOOL isSelected;
@property (nonatomic,assign) BOOL themeSelected;
@property (retain , nonatomic) NSURL *url;
@property (assign ,nonatomic) float audioVolume;
@property (assign,nonatomic) int cellIndex;
@property (assign,nonatomic) float videoScaleFactor;
@property (assign,nonatomic) int transition;
@end
