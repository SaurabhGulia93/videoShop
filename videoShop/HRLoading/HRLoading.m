//
//  HRLoading.m
//  ImageCloaning
//
//  Created by Hemkaran Raghav on 9/27/13.
//  Copyright (c) 2013 Mahesh Gera. All rights reserved.
//

#import "HRLoading.h"
#import <QuartzCore/QuartzCore.h>

@implementation HRLoading

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString*)title
{
    int frameWidth = [UIScreen mainScreen].bounds.size.width;
    int frameHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect fullFrame = CGRectMake(0, 0, frameWidth, frameHeight);
//    CGRect frame = [self CGRectMakeUsingCenterX:frameWidth/2 y:frameHeight/2 width:160 height:80];
    self = [super initWithFrame:fullFrame];
    if (self) {
//        self.layer.cornerRadius = 5.0;
//        self.alpha = 0.6;
//        self.backgroundColor = [UIColor blackColor];
        CGSize maximumLabelSize = CGSizeMake(160, FLT_MAX);
        CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
        NSLog(@"width = %f, height = %f title = %@",size.width,size.height,title);
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:[self CGRectMakeUsingCenterX:frameWidth/2 y:frameHeight/2 width:size.width+20 height:size.height + 40]];
        backgroundView.alpha = 0.6;
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.layer.cornerRadius = 5.0;
        [self addSubview:backgroundView];
        [backgroundView release];
        
        UIActivityIndicatorView *activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        activityIndicator.frame = CGRectMake(backgroundView.frame.size.width/2 + backgroundView.frame.origin.x, 20+backgroundView.frame.origin.y, 0, 0);
        [activityIndicator startAnimating];
        [self addSubview:activityIndicator];
        
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10 + backgroundView.frame.origin.x, 30+backgroundView.frame.origin.y, size.width, size.height)] autorelease];
        label.text = title;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        [label setFont:[UIFont systemFontOfSize:16]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:label];
        
        [self setHidden:YES];
    }
    return self;
}

-(void)show
{
    [self setHidden:NO];
}

-(void)hide
{
    [self setHidden:YES];
    [self removeFromSuperview];
}

-(CGRect)CGRectMakeUsingCenterX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height
{
    return CGRectMake(x-width/2, y-height/2, width, height);
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
