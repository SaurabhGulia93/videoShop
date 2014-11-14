//
//  mergeVideosViewController.m
//  videoShop
//
//  Created by unibera1 on 9/26/13.
//  Copyright (c) 2013 unibera. All rights reserved.
//

#import "mergeVideosViewController.h"

enum selectTag {
    title = 1,
    author = 2,
    place = 3
    };
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
@interface mergeVideosViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIAlertViewDelegate>

@end

@implementation mergeVideosViewController
{
    AVAsset *savePreviousAsset;
    NSArray *themesImagesArray;
    NSMutableArray *titleAuthorPlaceArray;
    MyCell *selectedCell;
//    AVMutableComposition *mutableComposition;
    int play;
    int pause;
    UIImageView *imageView;
    NSMutableArray *cellArray;
    NSMutableArray *transitionArray;
    PlayerView *playerView;
    int TAG,theme;
    BOOL isPortrait;
    BOOL saveVideoClicked;
    CGRect themeRect;
    CALayer *layer;
    CAShapeLayer *pathLayer;
    int frameWidth,frameHeight;
    int videoWidth,videoHeight;
}

- (id)initWithNibName:(NSString *)nibNameOrNil urls:(NSMutableArray *)urlarray themeArray:(NSMutableArray *)themearray bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        cellArray = urlarray;
        transitionArray = themearray;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    [_indicator setHidden:YES];
    videoWidth = 700/320;
    videoHeight = 700/480;
    frameWidth = [UIScreen mainScreen].bounds.size.width/320;
    frameHeight  =[UIScreen mainScreen].bounds.size.height/480;
    saveVideoClicked = NO;
    layer = [[CALayer layer] retain];
    pathLayer = [[CAShapeLayer layer] retain];
    imageView = nil;
    themesImagesArray = [[NSArray alloc]init];
    themesImagesArray =@[@"none.png",@"basic.png",@"news.png",@"trip.png",@"speakr.png",@"song.png"];
    [themesImagesArray retain];
    titleAuthorPlaceArray = [[NSMutableArray alloc]init];
    NSString *string = @" ";
    for(int i = 0;i<3;i++)
    {
        [titleAuthorPlaceArray addObject:string];
    }
//    [self mergeVideos];
}

-(void)viewWillAppear:(BOOL)animated{

    [self.themesCollectionCell registerNib:[UINib nibWithNibName:@"MyCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [NSThread detachNewThreadSelector:@selector(mergeVideos) toTarget:self withObject:nil];
}

-(BOOL)prefersStatusBarHidden{

    return YES;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell.thumbNailImageview setImage:[UIImage imageNamed:[themesImagesArray objectAtIndex:indexPath.item ]]];
    [cell.backGroundImage setImage:nil];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return themesImagesArray.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MyCell *cell = (MyCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if(!cell.themeSelected)
        {
            NSLog(@"in If");
            if(selectedCell)
            {
                NSLog(@"In selected cell If");
                [selectedCell.backGroundImage setImage:nil];
                selectedCell.themeSelected = NO;
               
            }
            [cell.backGroundImage setImage:[UIImage imageNamed:@"blueBackground.png"]];
            selectedCell = cell;
            cell.themeSelected = YES;
            [playerView pause];
            [playerView.moviePlayer seekToTime:kCMTimeZero];
            theme = indexPath.item;
//            [self addTheme:theme];
        }
        else
        {
            NSLog(@"In Else");
            [cell.backGroundImage setImage:nil];
            cell.themeSelected = NO;
            selectedCell = nil;
            theme = 0;
        }
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


-(void)mergeVideos{

    [_indicator setHidden:NO];
    [_indicator startAnimating];
    AVAsset *previousAsset;
    previousAsset = nil;
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    int transition;
    CMTime time = kCMTimeZero;
    NSMutableArray *instructionArray = [[NSMutableArray alloc]init];
    AVAssetTrack *videoTrack, *audioTrack;
    audioTrack = nil;
    videoTrack = nil;
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    AVMutableVideoCompositionLayerInstruction *prevVideolayerInstruction;
    for(int i=0;i<cellArray.count;i++)
    {
        NSURL *videoUrl = cellArray[i];
        AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableVideoCompositionLayerInstruction *videolayerInstruction;
        MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:videoUrl];
        UIImage *image = [[moviePlayer thumbnailImageAtTime:01.0 timeOption:MPMovieTimeOptionNearestKeyFrame] autorelease];
        [moviePlayer pause];
        [moviePlayer release];
        NSLog(@"imageSizeWidth = %f , height = %f",image.size.width,image.size.height);
        AVAsset *asset = [AVAsset assetWithURL:videoUrl];
        videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        if([asset tracksWithMediaType:AVMediaTypeAudio].count)
            audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        CGAffineTransform a;
        if(image.size.width > image.size.height)
            a = CGAffineTransformConcat(CGAffineTransformScale(CGAffineTransformIdentity, 700/image.size.width, 700/image.size.width), CGAffineTransformMakeTranslation(0, 90));
        else
            a = CGAffineTransformConcat(CGAffineTransformScale(CGAffineTransformIdentity, 700/image.size.height, 700/image.size.height), CGAffineTransformMakeTranslation(150,0));
        if(!previousAsset)
        {
            if(image.size.height > image.size.width)
                isPortrait = YES;
            [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
            
            if(audioTrack)
            {
                [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:audioTrack atTime:kCMTimeZero error:nil];
            }
            videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
            [videolayerInstruction setTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) atTime:kCMTimeZero];
//            CMTime transTime = CMTimeSubtract(asset.duration, CMTimeMake(2, 1));
//            [videolayerInstruction setTransformRampFromStartTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) toEndTransform:CGAffineTransformTranslate(CGAffineTransformScale(CGAffineTransformConcat(videoTrack.preferredTransform, a), 0.1, 0.1), 2000, 2000) timeRange:CMTimeRangeMake(transTime, CMTimeMake(2, 1))];
        }
        else
        {
            [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:time error:nil];
            
            if(audioTrack)
            {
                [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:audioTrack atTime:time error:nil];
                
            }
            videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
            switch (transition) {
                case 0:
                    [videolayerInstruction setTransform: CGAffineTransformConcat(videoTrack.preferredTransform, a) atTime:previousAsset.duration];
                    break;
                case 1:
                    NSLog(@"in case 1");
//                    [videolayerInstruction setTransformRampFromStartTransform:CGAffineTransformTranslate(CGAffineTransformScale(CGAffineTransformConcat(videoTrack.preferredTransform, a), 0.45, 0.45), 320, 300) toEndTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) timeRange:CMTimeRangeMake(time, CMTimeMake(2, 1))];
                     [videolayerInstruction setTransformRampFromStartTransform:CGAffineTransformTranslate( CGAffineTransformConcat(videoTrack.preferredTransform, a), 320, 0) toEndTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) timeRange:CMTimeRangeMake(time, CMTimeMake(2, 1))];
                    break;
                case 2:
                    [videolayerInstruction setTransformRampFromStartTransform:CGAffineTransformTranslate( CGAffineTransformConcat(videoTrack.preferredTransform, a), 0, -315) toEndTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) timeRange:CMTimeRangeMake(time, CMTimeMake(2, 1))];
                    break;
                case 3:
                    [videolayerInstruction setTransformRampFromStartTransform:CGAffineTransformTranslate( CGAffineTransformConcat(videoTrack.preferredTransform, a), 0, 315) toEndTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) timeRange:CMTimeRangeMake(time, CMTimeMake(2, 1))];
                    break;
                case 4:
                    [videolayerInstruction setTransformRampFromStartTransform:CGAffineTransformTranslate( CGAffineTransformConcat(videoTrack.preferredTransform, a), -320, 0) toEndTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) timeRange:CMTimeRangeMake(time, CMTimeMake(2, 1))];
                    break;
                case 6:
                    [videolayerInstruction setTransformRampFromStartTransform:CGAffineTransformTranslate(CGAffineTransformScale(CGAffineTransformConcat(videoTrack.preferredTransform, a), 0.45, 0.45), 320, 300) toEndTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) timeRange:CMTimeRangeMake(time, CMTimeMake(2, 1))];

                default:
                    break;
            }
            [prevVideolayerInstruction setOpacity:0 atTime:time];
        }
        time = CMTimeAdd(time, asset.duration);
        NSLog(@"After time is = %f",CMTimeGetSeconds(time));
        [instructionArray addObject:videolayerInstruction];
        previousAsset = asset;
        prevVideolayerInstruction = videolayerInstruction;
        
        transition = [(NSNumber *)[transitionArray objectAtIndex:i] intValue];
        NSLog(@"transition = %d",transition);
        audioTrack = nil;
        videoTrack = Nil;
    }
    
    //------------ audioMix----------------------------
//    NSArray *tracksToDuck = [mutableComposition tracksWithMediaType:AVMediaTypeAudio];
//    NSLog(@"Total audio added : %d",tracksToDuck.count);
//    NSMutableArray *trackMixArray = [NSMutableArray array];
//    for (NSInteger i = 0; i < [tracksToDuck count]; i++) {
//        
//        AVMutableAudioMixInputParameters *trackMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:[tracksToDuck objectAtIndex:i]];
//        [trackMix setVolume:((MyCell*)[cellArray objectAtIndex:i]).audioVolume atTime:kCMTimeZero];
//        NSLog(@"Currently volume set of track id : %d",((AVMutableCompositionTrack*)[tracksToDuck objectAtIndex:i]).trackID);
//        [trackMixArray addObject:trackMix];
//    }
    
//    NSArray *inArray = [[instructionArray reverseObjectEnumerator] allObjects];
//    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
//    audioMix.inputParameters = trackMixArray;
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, time);
    mainInstruction.layerInstructions = instructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.renderSize = CGSizeMake(700,700);
    mainCompositionInst.instructions = [NSArray arrayWithObjects:mainInstruction, nil];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
//    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:mutableComposition];
//    avPlayerItem.videoComposition = mainCompositionInst;
////    [avPlayerItem setAudioMix:audioMix];
//    playerView = [[PlayerView alloc]initWithFrame:CGRectMake(2, 80, 315, 320) playerItem:avPlayerItem];
//    [self.view addSubview:playerView];
////    [avPlayerItem release];
////    [instructionArray release];
    [_indicator stopAnimating];
    [_indicator setHidden:YES];
}

-(void)itemDidFinishPlaying {

    NSLog(@"Stopped");
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(130, 190, 60, 60)];
    [imageView setImage:[UIImage imageNamed:@"play.png"]];
    [self.view addSubview:imageView];
    play = 0;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
}

-(void)dealloc{

    [_themesCollectionCell release];
    [_indicator release];
//    [previousAsset release];
    [savePreviousAsset release];
    [themesImagesArray release];
    [titleAuthorPlaceArray release];
    [selectedCell release];
    [imageView release];
    [cellArray release];
    [playerView release];
    [layer release];
    [pathLayer release];
    [super dealloc];
//    [mutableComposition release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size{
    
    NSLog(@"in applyVideoEffectsToComposition");
    NSLog(@"Size.widt = %f,%f",size.width,size.height);
    CABasicAnimation *fade,*pathAnimation,*pathAnimation1;
    UIBezierPath *path,*path1;
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer setBackgroundColor:[UIColor purpleColor].CGColor];
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(5, 5, size.width-10, size.height-10);

    CALayer *overlayLayer = [CALayer layer];
    CAShapeLayer *pathOverlayLayer = [CAShapeLayer layer];
    NSLog(@"theme in aplyEffects = %d",theme);
    switch (theme) {
        case 0:
            [overlayLayer removeFromSuperlayer];
            [pathOverlayLayer removeFromSuperlayer];
            break;
        case 1:
            [overlayLayer removeFromSuperlayer];
            [pathOverlayLayer removeFromSuperlayer];
            [overlayLayer setFrame:CGRectMake(70*(700/320),210*(700/480), 176*(700/320), 70*(700/480))];
            [overlayLayer setDelegate:self];
            [overlayLayer setNeedsDisplay];
            fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fade.duration=4.0;
            fade.beginTime = 0.5;
            fade.fromValue=[NSNumber numberWithFloat:1.0];
            fade.toValue=[NSNumber numberWithFloat:0.0];
            fade.beginTime = AVCoreAnimationBeginTimeAtZero;
            fade.removedOnCompletion = NO;
            fade.fillMode = kCAFillModeForwards;
            [overlayLayer addAnimation:fade forKey:@"animateOpacity"];
            [parentLayer addSublayer:videoLayer];
            [parentLayer addSublayer:overlayLayer];
            break;
            
        case 2:
            [overlayLayer setFrame:CGRectMake(0, 0*videoHeight, 220*videoWidth, 100*videoHeight)];
            overlayLayer.delegate = self;
            [overlayLayer setMasksToBounds:YES];
            [overlayLayer setNeedsDisplay];
            path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(30*videoWidth, 50*videoHeight)];
            [path addLineToPoint:CGPointMake(170*videoWidth, 50*videoHeight)];
            pathOverlayLayer.frame = CGRectMake(75*videoWidth, 100*videoHeight, 220*videoWidth, 100*videoHeight);
            [pathOverlayLayer setMasksToBounds:YES];
            pathOverlayLayer.path = path.CGPath;
            pathOverlayLayer.strokeColor = [[UIColor whiteColor] CGColor];
            pathOverlayLayer.lineWidth = 25.0f;
            pathOverlayLayer.fillColor = nil;
            pathOverlayLayer.lineJoin = kCALineJoinBevel;
            pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            pathAnimation.duration = 0.35;
            pathAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
            pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
            pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
            [pathOverlayLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
            
            fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fade.duration=5.0;
            fade.beginTime = 2;
            fade.fromValue=[NSNumber numberWithFloat:1.0];
            fade.toValue=[NSNumber numberWithFloat:0.0];
            fade.beginTime = AVCoreAnimationBeginTimeAtZero;
            fade.removedOnCompletion = NO;
            fade.fillMode = kCAFillModeForwards;
            [pathOverlayLayer addAnimation:fade forKey:@"animateOpacity"];
            [parentLayer addSublayer:videoLayer];
            [pathOverlayLayer addSublayer:overlayLayer];
            [parentLayer addSublayer:pathOverlayLayer];
        default:
            break;
    }
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
}

-(void)addTheme:(int)Theme{

   
    UIBezierPath *path = [UIBezierPath bezierPath];
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    CAShapeLayer *pathLayer1;
    CABasicAnimation *pathAnimation;
    CABasicAnimation *pathAnimation1;
    switch (Theme) {
        case 0:
            [layer removeFromSuperlayer];
            [pathLayer removeFromSuperlayer];
            break;
        case 1:
            [layer removeFromSuperlayer];
            [pathLayer removeFromSuperlayer];
            if(isPortrait)
            {
                NSLog(@"in Portraight");
                [layer setFrame:CGRectMake(70, 210, 176, 70)];
            }
            else
            {
                [layer setFrame:CGRectMake(70, 210, 200, 70)];
            }
            [self.view.layer addSublayer:layer];
            layer.delegate = self;
            [layer setNeedsDisplay];
            break;
        case 2:
            [layer removeFromSuperlayer];
            [pathLayer removeFromSuperlayer];
            if(isPortrait)
            {
            [layer setFrame:CGRectMake(0, -15, 220, 50)];
            [self.view.layer addSublayer:layer];
            layer.delegate = self;
            [layer setNeedsDisplay];
            
            [path moveToPoint:CGPointMake(30 , 0)];
            [path addLineToPoint:CGPointMake(170, 0)];
            pathLayer.frame = CGRectMake(75, 360, 220, 50);
            pathLayer.path = path.CGPath;
            pathLayer.strokeColor = [[UIColor whiteColor] CGColor];
            pathLayer.lineWidth = 25.0f;
            pathLayer.fillColor = nil;
            pathLayer.lineJoin = kCALineJoinBevel;
            [self.view.layer addSublayer:pathLayer];
            [pathLayer addSublayer:layer];
        
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            pathAnimation.duration = 0.35;
            pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
            pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
            [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
            }
            else
            {
                [layer setFrame:CGRectMake(0, 0, 250, 50)];
                [self.view.layer addSublayer:layer];
                layer.delegate = self;
                [layer setNeedsDisplay];
                
                [path moveToPoint:CGPointMake(33.0,10.0)];
                [path addLineToPoint:CGPointMake(240, 10.0)];
                pathLayer.frame = CGRectMake(5, 320, 250, 50);
                pathLayer.path = path.CGPath;
                pathLayer.strokeColor = [[UIColor whiteColor] CGColor];
                pathLayer.lineWidth = 25.0f;
                pathLayer.fillColor = nil;
                pathLayer.lineJoin = kCALineJoinBevel;
                [self.view.layer addSublayer:pathLayer];
                [pathLayer addSublayer:layer];
                //    pathLayer.delegate = self;
                //    [pathLayer setNeedsDisplay];
                pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                pathAnimation.duration = 0.35;
                pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
                pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
                [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
            }
            break;
        case 3:
            [layer removeFromSuperlayer];
            [pathLayer removeFromSuperlayer];
            
            if(isPortrait)
            {
                [layer setFrame:CGRectMake(0, -15, 220, 50)];
                [self.view.layer addSublayer:layer];
                layer.delegate = self;
                [layer setNeedsDisplay];
                
                [path moveToPoint:CGPointMake(30 , 0)];
                [path addLineToPoint:CGPointMake(172, 0)];
                pathLayer.frame = CGRectMake(75, 360, 220, 50);
                pathLayer.path = path.CGPath;
                pathLayer.strokeColor = [[UIColor whiteColor] CGColor];
                pathLayer.lineWidth = 25.0f;
                pathLayer.fillColor = nil;
                pathLayer.lineJoin = kCALineJoinBevel;
                [self.view.layer addSublayer:pathLayer];
                
                CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                pathAnimation.duration = 0.35;
                pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
                pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
                [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
                
                [path1 moveToPoint:CGPointMake(30 ,0)];
                [path1 addLineToPoint:CGPointMake(172, 0)];
                
                pathLayer1 = [CAShapeLayer layer];
                pathLayer1.frame = CGRectMake(0, 30, 220, 50);
                pathLayer1.path = path.CGPath;
                pathLayer1.strokeColor = [[UIColor blackColor] CGColor];
                pathLayer1.lineWidth = 25.0f;
                pathLayer1.fillColor = nil;
                pathLayer1.lineJoin = kCALineJoinBevel;
                [pathLayer addSublayer:pathLayer1];
                pathAnimation1 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                pathAnimation1.duration = 0.35;
                pathAnimation1.fromValue = [NSNumber numberWithFloat:0.0f];
                pathAnimation1.toValue = [NSNumber numberWithFloat:1.0f];
                [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];

                [pathLayer addSublayer:layer];

            }
            else
            {
                [layer setFrame:CGRectMake(0, 0, 250, 50)];
                [self.view.layer addSublayer:layer];
                layer.delegate = self;
                [layer setNeedsDisplay];
                
                [path moveToPoint:CGPointMake(30 , 0)];
                [path addLineToPoint:CGPointMake(170, 0)];
                pathLayer.frame = CGRectMake(10, 240, 250, 50);
                pathLayer.path = path.CGPath;
                [pathLayer setContents:(id)[UIImage imageNamed:@"star.png"]];
                pathLayer.strokeColor = [[UIColor whiteColor] CGColor];
                pathLayer.lineWidth = 3.0f;
                pathLayer.fillColor = nil;
                pathLayer.lineJoin = kCALineJoinBevel;
                [self.view.layer addSublayer:pathLayer];
                [pathLayer addSublayer:layer];
                pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                pathAnimation.duration = 0.35;
                pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
                pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
                [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
            }
            break;
        case 4:
            [layer removeFromSuperlayer];
            [pathLayer removeFromSuperlayer];
            if(isPortrait)
            {
                NSLog(@"in Portraight");
                [layer setFrame:CGRectMake(70, 210, 176, 70)];
            }
            else
            {
                [layer setFrame:CGRectMake(70, 230, 200, 70)];
            }
            [self.view.layer addSublayer:layer];
            layer.delegate = self;
            [layer setNeedsDisplay];
            
            break;
        case 5:
            [layer removeFromSuperlayer];
            if(pathLayer)
            {
                [pathLayer removeFromSuperlayer];
            }
            if(isPortrait)
            {
            [layer setFrame:CGRectMake(75, 320, 220, 100)];
            [self.view.layer addSublayer:layer];
            layer.delegate = self;
            [layer setNeedsDisplay];
            }
            else
            {
                [layer setFrame:CGRectMake(7, 320, 250, 100)];
                [self.view.layer addSublayer:layer];
                layer.delegate = self;
                [layer setNeedsDisplay];
            }
            break;
        default:
            break;
    }
    
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{

    NSLog(@"theme = %d",theme);
    if(saveVideoClicked)
    {
        switch (theme) {
            case 1:
                CGContextBeginPath(ctx);
                CGContextMoveToPoint(ctx, 1.0f*videoWidth, 5.0f*videoHeight);
                CGContextAddLineToPoint(ctx, 200*videoWidth, 5.0f*videoHeight);
                CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
                CGContextClosePath(ctx);
                CGContextDrawPath(ctx, kCGPathFillStroke);
                CGContextBeginPath(ctx);
                CGContextMoveToPoint(ctx, 1.0f*videoWidth, 25.0f*videoHeight);
                CGContextAddLineToPoint(ctx, 200.0f*videoWidth, 25.0f*videoHeight);
                CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
                CGContextClosePath(ctx);
                CGContextDrawPath(ctx, kCGPathFillStroke);
                
                UIGraphicsPushContext(ctx);
                [@"Saurabh" drawAtPoint:CGPointMake(33*videoWidth, 06*videoHeight) withFont:[UIFont systemFontOfSize:18*videoWidth]];
                [@"Delhi" drawAtPoint:CGPointMake(33*videoWidth, 26*videoHeight) withFont:[UIFont systemFontOfSize:18*videoWidth]];
                UIGraphicsPopContext();
                break;
            case 2:
                UIGraphicsPushContext(ctx);
                [@"Saurabh" drawAtPoint:CGPointMake(33*videoWidth, 30*videoHeight) withFont:[UIFont systemFontOfSize:18*videoWidth]];
                [@"Delhi" drawAtPoint:CGPointMake(33*videoWidth, 60*videoHeight) withFont:[UIFont systemFontOfSize:18*videoWidth]];
                UIGraphicsPopContext();
                break;
            case 3:
                UIGraphicsPushContext(ctx);
                [@"Saurabh" drawAtPoint:CGPointMake(33*videoWidth, 0) withFont:[UIFont systemFontOfSize:18*videoWidth]];
                [@"Delhi" drawAtPoint:CGPointMake(33*videoWidth, 27*videoHeight) withFont:[UIFont systemFontOfSize:18*videoWidth]];
                UIGraphicsPopContext();
                break;
            case 4:
                UIGraphicsPushContext(ctx);
                [@"27/08/1991" drawAtPoint:CGPointMake(50*videoWidth, 0) withFont:[UIFont systemFontOfSize:18*videoWidth]];
                UIGraphicsPopContext();
                CGContextBeginPath(ctx);
                CGContextMoveToPoint(ctx, 1.0f*videoWidth, 20.0f*videoHeight);
                CGContextAddLineToPoint(ctx, 170*videoWidth, 20.0f*videoHeight);
                CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
                CGContextClosePath(ctx);
                CGContextDrawPath(ctx, kCGPathFillStroke);
                UIGraphicsPushContext(ctx);
                [@"Delhi" drawAtPoint:CGPointMake(50*videoWidth, 25*videoHeight) withFont:[UIFont systemFontOfSize:18*videoWidth]];
                UIGraphicsPopContext();
                break;
            case 5:
                UIGraphicsPushContext(ctx);
                [@"\"Saurabh\"" drawAtPoint:CGPointMake(5*videoWidth, 0) withFont:[UIFont systemFontOfSize:18*videoWidth]];
                [@"\"Unibera\"" drawAtPoint:CGPointMake(5*videoWidth, 20*videoHeight) withFont:[UIFont systemFontOfSize:18*videoWidth]];
                [@"\"11/11/13\"" drawAtPoint:CGPointMake(5*videoWidth, 45*videoHeight) withFont:[UIFont systemFontOfSize:18*videoWidth]];
                UIGraphicsPopContext();
                break;
            default:
                break;
                
                saveVideoClicked = NO;
    }
    }
    else
    {
    switch (theme) {
        case 1:
            CGContextBeginPath(ctx);
            CGContextMoveToPoint(ctx, 1.0f, 5.0f);
            CGContextAddLineToPoint(ctx, 200, 5.0f);
            CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
            CGContextClosePath(ctx);
            CGContextDrawPath(ctx, kCGPathFillStroke);
            CGContextBeginPath(ctx);
            CGContextMoveToPoint(ctx, 1.0f, 25.0f);
            CGContextAddLineToPoint(ctx, 200.0f, 25.0f);
            CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
            CGContextClosePath(ctx);
            CGContextDrawPath(ctx, kCGPathFillStroke);
            
            UIGraphicsPushContext(ctx);
            [@"Saurabh" drawAtPoint:CGPointMake(33, 06) withFont:[UIFont systemFontOfSize:18]];
            [@"Delhi" drawAtPoint:CGPointMake(33, 26) withFont:[UIFont systemFontOfSize:18]];
            UIGraphicsPopContext();
            break;
        case 2:
            UIGraphicsPushContext(ctx);
            [@"Saurabh" drawAtPoint:CGPointMake(33, 0) withFont:[UIFont systemFontOfSize:18]];
            [@"Delhi" drawAtPoint:CGPointMake(33, 27) withFont:[UIFont systemFontOfSize:18]];
            UIGraphicsPopContext();
            break;
        case 3:
            UIGraphicsPushContext(ctx);
            [@"Saurabh" drawAtPoint:CGPointMake(33, 0) withFont:[UIFont systemFontOfSize:18]];
            [@"Delhi" drawAtPoint:CGPointMake(33, 27) withFont:[UIFont systemFontOfSize:18]];
            UIGraphicsPopContext();
            break;
        case 4:
            UIGraphicsPushContext(ctx);
            [@"27/08/1991" drawAtPoint:CGPointMake(50, 0) withFont:[UIFont systemFontOfSize:18]];
            UIGraphicsPopContext();
            CGContextBeginPath(ctx);
            CGContextMoveToPoint(ctx, 1.0f, 20.0f);
            CGContextAddLineToPoint(ctx, 170, 20.0f);
            CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
            CGContextClosePath(ctx);
            CGContextDrawPath(ctx, kCGPathFillStroke);
            UIGraphicsPushContext(ctx);
            [@"Delhi" drawAtPoint:CGPointMake(50, 25) withFont:[UIFont systemFontOfSize:18]];
            UIGraphicsPopContext();
            break;
        case 5:
            UIGraphicsPushContext(ctx);
            [@"\"Saurabh\"" drawAtPoint:CGPointMake(5, 0) withFont:[UIFont systemFontOfSize:18]];
            [@"\"Unibera\"" drawAtPoint:CGPointMake(5, 20) withFont:[UIFont systemFontOfSize:18]];
            [@"\"11/11/13\"" drawAtPoint:CGPointMake(5, 45) withFont:[UIFont systemFontOfSize:18]];
            UIGraphicsPopContext();
            break;
        default:
            break;
    }
    }
    
}


- (IBAction)titleAuthorPlace:(UIButton *)sender {
    
    UIAlertView *alert;
    switch (sender.tag) {
        case 1:
            alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Title of the Video" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alert show];
            TAG = 0;
            break;
        case 2:
            alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Author of the Video" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alert show];
            TAG = 1;
            break;
        case 3:
            alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Place of the Video" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alert show];
            TAG = 2;
            break;
        default:
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if(buttonIndex)
    {
        UITextField *text = [alertView textFieldAtIndex:0];
        [titleAuthorPlaceArray replaceObjectAtIndex:TAG withObject:text.text];
        NSLog(@"titleAuthorPlaceArray = %@",titleAuthorPlaceArray);
    }
}

- (IBAction)saveButton:(UIButton *)sender {

//    saveVideoClicked = YES;
//    AVMutableComposition *mixComposition = [AVMutableComposition composition];
//    int transition;
//    CMTime time = kCMTimeZero;
//    NSMutableArray *instructionArray = [[NSMutableArray alloc]init];
//    AVAssetTrack *videoTrack, *audioTrack;
//    audioTrack = nil;
//    videoTrack = nil;
//    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    AVMutableVideoCompositionLayerInstruction *prevVideolayerInstruction;
//    for(int i=0;i<cellArray.count;i++)
//    {
//        MyCell *cell = cellArray[i];
//        NSLog(@"cellVolume = %f",cell.audioVolume);
//        AVMutableCompositionTrack *videoCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//        AVMutableCompositionTrack *audioCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//        AVMutableVideoCompositionLayerInstruction *videolayerInstruction;
//        MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:cell.url];
//        UIImage *image = [moviePlayer thumbnailImageAtTime:01.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
//        [moviePlayer pause];
//        [moviePlayer release];
//        NSLog(@"imageSizeWidth = %f , height = %f",image.size.width,image.size.height);
//        AVAsset *asset = [AVAsset assetWithURL:cell.url];
//        videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//        if([asset tracksWithMediaType:AVMediaTypeAudio].count)
//            audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
//        NSLog(@"videoTrack time %f",CMTimeGetSeconds(videoTrack.timeRange.duration));
//        CGAffineTransform a;
//        if(image.size.width > image.size.height)
//            a = CGAffineTransformConcat(CGAffineTransformScale(CGAffineTransformIdentity, 700/image.size.width, 700/image.size.width), CGAffineTransformMakeTranslation(0, 90));
//        else
//            a = CGAffineTransformConcat(CGAffineTransformScale(CGAffineTransformIdentity, 700/image.size.height, 700/image.size.height), CGAffineTransformMakeTranslation(150,0));
//        if(!savePreviousAsset)
//        {
//            if(image.size.height > image.size.width)
//                isPortrait = YES;
//            [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
//            
//            if(audioTrack)
//            {
//                [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:audioTrack atTime:kCMTimeZero error:nil];
//            }
//            videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
//            [videolayerInstruction setTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) atTime:kCMTimeZero];
////            CMTime transTime = CMTimeSubtract(asset.duration, CMTimeMake(2, 1));
////            [videolayerInstruction setTransformRampFromStartTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) toEndTransform:CGAffineTransformTranslate(CGAffineTransformScale(CGAffineTransformConcat(videoTrack.preferredTransform, a), 0.1, 0.1), 2000, 2000) timeRange:CMTimeRangeMake(transTime, CMTimeMake(2, 1))];
//        }
//        else
//        {
//            NSLog(@"videoCompopsitionTrack time is = %f",CMTimeGetSeconds(videoCompositionTrack.timeRange.duration));
//            
//            [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:time error:nil];
//            
//            NSLog(@"videoCompopsitionTrack time is = %f",CMTimeGetSeconds(videoCompositionTrack.timeRange.duration));
//            
//            
//            if(audioTrack)
//            {
//                [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:audioTrack atTime:time error:nil];
//                
//            }
//            
//            videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
//            CMTime subTime =CMTimeSubtract(time, CMTimeMake(2, 1));
//            NSLog(@"Time = %f and subTime = %f",CMTimeGetSeconds(time), CMTimeGetSeconds(subTime));
//            //            [videolayerInstruction setTransformRampFromStartTransform:CGAffineTransformTranslate( CGAffineTransformConcat(videoTrack.preferredTransform, a), 320, 0) toEndTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) timeRange:CMTimeRangeMake(time, CMTimeMake(2, 1))];
//            
//            switch (transition) {
//                case 0:
//                    NSLog(@"transition = %d",transition);
//                    [videolayerInstruction setTransform: CGAffineTransformConcat(videoTrack.preferredTransform, a) atTime:savePreviousAsset.duration];
//                    break;
//                case 1:
//                    NSLog(@"in case 1");
//                    NSLog(@"transition = %d",transition);
//                    //                    [videolayerInstruction setTransformRampFromStartTransform:CGAffineTransformTranslate( CGAffineTransformConcat(videoTrack.preferredTransform, a), 320, 0) toEndTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) timeRange:CMTimeRangeMake(time, CMTimeMake(2, 1))];
//                    //                    [videolayerInstruction setTransformRampFromStartTransform:CGAffineTransformTranslate(CGAffineTransformScale(CGAffineTransformConcat(videoTrack.preferredTransform, a), 0.45, 0.45), 320, 300) toEndTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) timeRange:CMTimeRangeMake(time, CMTimeMake(2, 1))];
//                    [videolayerInstruction setTransform: CGAffineTransformConcat(videoTrack.preferredTransform, a) atTime:savePreviousAsset.duration];
//                    break;
//                case 2:
//                    NSLog(@"transition = %d",transition);
//                    [videolayerInstruction setTransformRampFromStartTransform:CGAffineTransformTranslate( CGAffineTransformConcat(videoTrack.preferredTransform, a), -320, 0) toEndTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) timeRange:CMTimeRangeMake(time, CMTimeMake(2, 1))];
//                    break;
//                case 3:
//                    [videolayerInstruction setTransformRampFromStartTransform:CGAffineTransformTranslate( CGAffineTransformConcat(videoTrack.preferredTransform, a), 0, -315) toEndTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) timeRange:CMTimeRangeMake(time, CMTimeMake(2, 1))];
//                    break;
//                case 4:
//                    [videolayerInstruction setTransformRampFromStartTransform:CGAffineTransformTranslate( CGAffineTransformConcat(videoTrack.preferredTransform, a), 0, 315) toEndTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) timeRange:CMTimeRangeMake(time, CMTimeMake(2, 1))];
//                    break;
//                default:
//                    break;
//            }
//            [prevVideolayerInstruction setOpacity:0 atTime:time];
//        }
//        NSLog(@"before time is = %f",CMTimeGetSeconds(time));
//        NSLog(@"videoCompopsitionTrack time is = %f",CMTimeGetSeconds(videoCompositionTrack.timeRange.duration));
//        time = CMTimeAdd(time, asset.duration);
//        NSLog(@"After time is = %f",CMTimeGetSeconds(time));
//        NSLog(@"videoCompositionTrack time = %f",CMTimeGetSeconds(videoCompositionTrack.timeRange.duration));
//        [instructionArray addObject:videolayerInstruction];
//        savePreviousAsset = asset;
//        prevVideolayerInstruction = videolayerInstruction;
//        transition = cell.transition;
//        audioTrack = nil;
//        videoTrack = Nil;
//    }
//    
//    //------------ audioMix----------------------------
//    NSArray *tracksToDuck = [mixComposition tracksWithMediaType:AVMediaTypeAudio];
//    NSLog(@"Total audio added : %d",tracksToDuck.count);
//    NSMutableArray *trackMixArray = [NSMutableArray array];
//    for (NSInteger i = 0; i < [tracksToDuck count]; i++) {
//        
//        AVMutableAudioMixInputParameters *trackMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:[tracksToDuck objectAtIndex:i]];
//        [trackMix setVolume:((MyCell*)[cellArray objectAtIndex:i]).audioVolume atTime:kCMTimeZero];
//        NSLog(@"Currently volume set of track id : %d",((AVMutableCompositionTrack*)[tracksToDuck objectAtIndex:i]).trackID);
//        [trackMixArray addObject:trackMix];
//    }
//    
//    NSArray *inArray = [[instructionArray reverseObjectEnumerator] allObjects];
//    [instructionArray release];
//    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
//    audioMix.inputParameters = trackMixArray;
//    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, time);
//    mainInstruction.layerInstructions = inArray;
//    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
//    mainCompositionInst.renderSize = CGSizeMake(700,700);
//    mainCompositionInst.instructions = [NSArray arrayWithObjects:mainInstruction, nil];
//    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
//    [self applyVideoEffectsToComposition:mainCompositionInst size:mainCompositionInst.renderSize];
//    
//    //------------------Export Session-----------------------------------------------------------------
//    
//    AVAssetExportSession *exportSession1;
//    NSString *tempDir = NSTemporaryDirectory();
//    NSString *tmpVideoPath = [tempDir stringByAppendingPathComponent:@"finalMovie.mov"];
//    [self deleteTmpFile:tmpVideoPath];
//    exportSession1 = [[AVAssetExportSession alloc]
//                        initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
//    
//        NSURL *furl1 = [NSURL fileURLWithPath:tmpVideoPath];
//        exportSession1.outputURL = furl1;
//    
//        exportSession1.outputFileType = AVFileTypeQuickTimeMovie;
//        exportSession1.audioMix = audioMix;
//        exportSession1.timeRange = mainInstruction.timeRange;
//        exportSession1.videoComposition = mainCompositionInst;
//        [exportSession1 exportAsynchronouslyWithCompletionHandler:^{
//    
//           NSLog(@"Status = %d",[exportSession1 status]);
//            
//            switch ([exportSession1 status]) {
//                case AVAssetExportSessionStatusFailed:
//                    NSLog(@"Export failed: %@", [[exportSession1 error] description]);
//                    break;
//                case AVAssetExportSessionStatusCancelled:
//                    NSLog(@"Export canceled");
//                    break;
//                default:
//                    NSLog(@"Done");
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        UISaveVideoAtPathToSavedPhotosAlbum(exportSession1.outputURL.path, nil, nil, nil);
//                    });
//                    
//                    break;
//            }
//            
//        }];
//    NSLog(@"Ended");
}

-(void)removeLayers{
    
    if(theme == 0)
    {
        NSLog(@"in 0");
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        pathAnimation.duration = 2.0;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:200.0f];
        pathAnimation.delegate = self;
        [layer addAnimation:pathAnimation forKey:@"translation"];

    }
    else
    {
        NSLog(@"in else remove Layers");
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.duration=2.0;
//        animation.repeatCount=5;
        // animate from fully visible to invisible
        animation.fromValue=[NSNumber numberWithFloat:1.0];
        animation.toValue=[NSNumber numberWithFloat:0.0];
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        [layer addAnimation:animation forKey:@"animateOpacity"];
    }
}

- (IBAction)backButton:(UIButton *)sender {
    
    [playerView pause];
    [playerView removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
