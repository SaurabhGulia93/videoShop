//
//  ViewController.m
//  videoShop
//
//  Created by unibera1 on 9/23/13.
//  Copyright (c) 2013 unibera. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<ELCImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UINavigationControllerDelegate,UIVideoEditorControllerDelegate,UIImagePickerControllerDelegate,MPMediaPickerControllerDelegate>

@end

@implementation ViewController
{
    NSArray *scrollItemImagesArray;
    NSURL *selectedUrl;
    MyCell *selectedCell;
    UIAlertView *alert;
    AVAsset *previousAsset;
//    NSMutableArray *cellArray;
    NSMutableDictionary *transitionDict;
    PlayerView *playerView;
    BOOL arrayLoaded;
    BOOL cellSelected;
    BOOL scrollButtonEnable;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_selectVideoView setHidden:NO];
//    NSString *bundleDirectory = [[NSBundle mainBundle] bundlePath];
//    NSString *outputFilePath = [bundleDirectory stringByAppendingPathComponent:@"thaiPhuketKaronBeach.MOV"];
//    if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputFilePath))
//    {
//        UISaveVideoAtPathToSavedPhotosAlbum(outputFilePath, nil, nil, nil);
//        NSLog(@"Saved");
//
//    }
//    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"YouTubeTest" ofType:@"m4v"];
//    UISaveVideoAtPathToSavedPhotosAlbum(videoPath, nil, nil, nil);
//    if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath))
//    {
//        NSLog(@"Saved");
//        
//    }
}

-(BOOL)prefersStatusBarHidden{

    return YES;
}

-(void)viewWillAppear:(BOOL)animated{

    if(!arrayLoaded)
    {
        [_indicator setHidden:YES];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    scrollItemImagesArray = [[NSArray alloc]init];
//    cellArray = [[NSMutableArray alloc]init];
    selectedUrl = [[NSURL alloc]init];
    transitionDict = [[NSMutableDictionary alloc]init];
    scrollItemImagesArray =@[@"trans-1.png",@"cut-1.png",@"rec-1.png",@"speed-1.png",@"music-1.png",@"del-1.png"];
    [scrollItemImagesArray retain];
    [self makeScrollView];
        
    for(int i = 0; i<20; i++)
    {
        [self.collectionView registerNib:[UINib nibWithNibName:@"MyCell" bundle:nil] forCellWithReuseIdentifier:[NSString stringWithFormat:@"Cell%d",i]];
    }
    
    }
    else
    {
        NSLog(@"in else of appear!!");
        if(_selectVideoView.isHidden)
        {
            [_selectVideoView setHidden:NO];
        }
        else
            [_selectVideoView setHidden:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated{

//    [_collectionView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated{

    if(playerView)
    {
        [playerView pause];
        [playerView removeFromSuperview];
        playerView = nil;
    }
    [_selectVideoView setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    MyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"Cell%d",indexPath.item] forIndexPath:indexPath];
    NSLog(@"cell Index = %d",indexPath.item);
    if(arrayLoaded)
    {
       if([[urlAndThumbnails sharedSettings].urlArray[indexPath.item] isKindOfClass:[NSURL class]])
       {
           NSNumber *num = [transitionDict objectForKey:[NSString stringWithFormat:@"%d",indexPath.item]];
           if(num)
           {
               cell.transition = [num intValue];
               NSLog(@"num intValue = %d",[num intValue]);
               [cell.thumbNailImageview setImage:[[urlAndThumbnails sharedSettings].thumbnailArray objectAtIndex:indexPath.item]];
               [cell.backGroundImage setImage:nil];
               cell.url =[[urlAndThumbnails sharedSettings].urlArray objectAtIndex:indexPath.item];
               cell.audioVolume = 1;
               cell.cellIndex = indexPath.item;
               cell.videoScaleFactor = 1;
           }
           else
           {
               cell.transition = 0;
               [cell.thumbNailImageview setImage:[[urlAndThumbnails sharedSettings].thumbnailArray objectAtIndex:indexPath.item]];
               [cell.backGroundImage setImage:nil];
               cell.url =[[urlAndThumbnails sharedSettings].urlArray objectAtIndex:indexPath.item];
               cell.audioVolume = 1;
               cell.cellIndex = indexPath.item;
               cell.videoScaleFactor = 1;
           }
           
       }
        else
        {
            cell.transition = -1;
            [cell.thumbNailImageview setImage:[[urlAndThumbnails sharedSettings].thumbnailArray objectAtIndex:indexPath.item]];
            [cell.backGroundImage setImage:nil];
        }
        
    }
    else
    {
        [cell.thumbNailImageview setImage:[UIImage imageNamed:@"add-video-icon.png"]];
        [cell.backGroundImage setImage:nil];
    }
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    if(arrayLoaded)
    {
        NSLog(@"no. of cells = %d",[urlAndThumbnails sharedSettings].urlArray.count);
        return ([urlAndThumbnails sharedSettings].urlArray.count);
    }
    else
        return 4;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    MyCell *cell1 = (MyCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSLog(@"transitionSelected = %d",cell1.transition);
    NSLog(@"cellIndex = %d",cell1.cellIndex);
    if (arrayLoaded)
    {
        [_selectVideoView setHidden:YES];
        if(!cell1.isSelected)
        {
            if(selectedCell)
            {
                [selectedCell.backGroundImage setImage:nil];
                selectedCell.isSelected = NO;
                scrollButtonEnable = NO;
            }
            selectedCell = cell1;
            if(cell1.transition != -1)
            {
                [self prepareAVplayer:selectedCell.url];
            }
            [urlAndThumbnails sharedSettings].index = indexPath.item;
            scrollButtonEnable = YES;
            [cell1.backGroundImage setImage:[UIImage imageNamed:@"blueBackground.png"]];
            cell1.isSelected = YES;
        }
        else
        {
            [cell1.backGroundImage setImage:nil];
            cell1.isSelected = NO;
            scrollButtonEnable = NO;
            selectedCell = nil;
//            selectedUrl = nil;
            [playerView pause];
            [playerView removeFromSuperview];
            playerView  =nil;
            if(_selectVideoView.isHidden)
            {
                [_selectVideoView setHidden:NO];
            }
            else
                [_selectVideoView setHidden:YES];
        }
    }
    else
    {
        if(_selectVideoView.isHidden)
        {
            [_selectVideoView setHidden:NO];
        }
        else
            [_selectVideoView setHidden:YES];
    }

}

-(void)makeScrollView{

    for(int i=0;i<scrollItemImagesArray.count;i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setFrame:CGRectMake(17 + (i*45), 2, 43, 50)];
        [button setBackgroundImage:[UIImage imageNamed:[scrollItemImagesArray objectAtIndex:i]] forState:UIControlStateNormal];
        button.tag = i+1;
        [button addTarget:self action:@selector(scrollItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:button];
    }
}

-(void)scrollItemClicked:(UIButton *)button{
    
    NSLog(@"%d",button.tag);
    if(scrollButtonEnable)
    {
    switch (button.tag) {
        case 1:
            [self changeTransition];
            break;
        case 2:
            [self cutVideo:selectedCell.url];
            break;
        case 3:
            [self recordVoice:selectedCell.url];
            break;
        case 4:
            [self changeSpeed:selectedCell.url];
            break;
        case 5:
            [self changeMusic:selectedCell.url];
            break;
        case 6:
            [self delVideo:selectedCell.url];
            break;
        default:
            break;
        }
    }
    else{
        
        alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Select a video" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)delVideo:(NSURL *)url{
    
    NSLog(@"index = %d",selectedCell.cellIndex);
    if(selectedCell.transition == -1)
    {
        [transitionDict removeObjectForKey:[NSString stringWithFormat:@"%d",selectedCell.cellIndex-1]];
        [[urlAndThumbnails sharedSettings].urlArray removeObjectAtIndex:selectedCell.cellIndex];
        [[urlAndThumbnails sharedSettings].thumbnailArray removeObjectAtIndex:selectedCell.cellIndex];
    }
    else
    {
        if ([transitionDict objectForKey:[NSString stringWithFormat:@"%d",selectedCell.cellIndex]])
        {
            NSLog(@"selectedCell.cellIndex = %d",selectedCell.cellIndex);
            [[urlAndThumbnails sharedSettings].urlArray removeObjectAtIndex:selectedCell.cellIndex];
            [[urlAndThumbnails sharedSettings].thumbnailArray removeObjectAtIndex:selectedCell.cellIndex];
            NSLog(@"selectedCell.cellIndex = %d",selectedCell.cellIndex+1);
            [[urlAndThumbnails sharedSettings].urlArray removeObjectAtIndex:selectedCell.cellIndex];
            [[urlAndThumbnails sharedSettings].thumbnailArray removeObjectAtIndex:selectedCell.cellIndex];
            [transitionDict removeObjectForKey:[NSString stringWithFormat:@"%d",selectedCell.cellIndex]];
        }
        else{
        
            if(selectedCell.cellIndex == [[urlAndThumbnails sharedSettings].urlArray count]-1)
            {
                if([transitionDict objectForKey:[NSString stringWithFormat:@"%d",selectedCell.cellIndex-2]])
                {
                [[urlAndThumbnails sharedSettings].urlArray removeObjectAtIndex:selectedCell.cellIndex];
                [[urlAndThumbnails sharedSettings].thumbnailArray removeObjectAtIndex:selectedCell.cellIndex];
                [[urlAndThumbnails sharedSettings].urlArray removeObjectAtIndex:selectedCell.cellIndex-1];
                [[urlAndThumbnails sharedSettings].thumbnailArray removeObjectAtIndex:selectedCell.cellIndex-1];
                [transitionDict removeObjectForKey:[NSString stringWithFormat:@"%d",selectedCell.cellIndex-2]];
                
                }
                else
                {
                    [[urlAndThumbnails sharedSettings].urlArray removeObjectAtIndex:selectedCell.cellIndex];
                    [[urlAndThumbnails sharedSettings].thumbnailArray removeObjectAtIndex:selectedCell.cellIndex];
                }
            }
            else
            {
                [[urlAndThumbnails sharedSettings].urlArray removeObjectAtIndex:selectedCell.cellIndex];
                [[urlAndThumbnails sharedSettings].thumbnailArray removeObjectAtIndex:selectedCell.cellIndex];
            
            }
        }
        if(playerView)
        {
        [playerView pause];
        [playerView removeFromSuperview];
        playerView = nil;
        }
        if(_selectVideoView.isHidden)
        {
            [_selectVideoView setHidden:NO];
        }
        else
            [_selectVideoView setHidden:YES];

    }
    NSLog(@"[urlAndThumbnails sharedSettings].urlArray.count = %d",[urlAndThumbnails sharedSettings].urlArray.count);
    if(![urlAndThumbnails sharedSettings].urlArray.count)
    {
        arrayLoaded = NO;
    }
    scrollButtonEnable = NO;
    selectedCell.isSelected = NO;
    [self.collectionView reloadData];

}
-(void)recordVoice:(NSURL *)url{

    scrollButtonEnable = NO;
    selectedCell.isSelected = NO;
    [selectedCell.backGroundImage setImage:nil];
    if(selectedCell.transition == -1)
    {
        alert = [[[UIAlertView alloc]initWithTitle:@"" message:@"Plaese select a video" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]autorelease];
        [alert show];
    }
    else
    {
        voiceRecorderViewController *record = [[[voiceRecorderViewController alloc] initWithNibName:@"voiceRecorderViewController" url:selectedCell.url cell:selectedCell view:self bundle:nil] autorelease];
        [self presentViewController:record animated:YES completion:nil];
    }
}

-(void)changeSpeed:(NSURL *)url{

    scrollButtonEnable = NO;
    selectedCell.isSelected = NO;
    [selectedCell.backGroundImage setImage:nil];
    if(selectedCell.transition == -1)
    {
        alert = [[[UIAlertView alloc]initWithTitle:@"" message:@"Plaese select a video" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]autorelease];
        [alert show];
    }
    else
    {
    changeSpeedViewController *changeSpeed = [[[changeSpeedViewController alloc]initWithNibName:@"changeSpeedViewController" url:url cell:selectedCell view:self bundle:nil] autorelease];
    [self presentViewController:changeSpeed animated:YES completion:nil];
    }
}

-(void)changeMusic:(NSURL *)url{
    
    scrollButtonEnable = NO;
    selectedCell.isSelected = NO;
    [selectedCell.backGroundImage setImage:nil];
    if(selectedCell.transition == -1)
    {
        alert = [[[UIAlertView alloc]initWithTitle:@"" message:@"Plaese select a video" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]autorelease];
        [alert show];
    }
    else
    {
    _adjustSoundSlider.value = selectedCell.audioVolume;
    [UIView animateWithDuration:0.5 animations:^(void){
        
        [_adjustMusic setFrame:CGRectMake(0, 227, 320, 277)];
        
    }];
    }
}

-(void)cutVideo:(NSURL *)url{
    
    if(selectedCell.transition == -1)
    {
        alert = [[[UIAlertView alloc]initWithTitle:@"" message:@"Plaese select a video" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]autorelease];
        [alert show];
    }
    else
    {
        [self editVideo:url];
    }
    
    scrollButtonEnable = NO;
    selectedCell.isSelected = NO;
}

-(void)editVideo:(NSURL *)videoUrl{

    NSString *tempDir = NSTemporaryDirectory();
    NSString *tmpVideoPath = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"tmpMov%d.mov",selectedCell.cellIndex]];
    [self deleteTmpFile:tmpVideoPath];
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        
        self.exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:anAsset presetName:AVAssetExportPresetHighestQuality];
        
        NSURL *furl = [[NSURL fileURLWithPath:tmpVideoPath] autorelease];
        self.exportSession.outputURL = furl;
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        
        self.exportSession.timeRange = ((AVAssetTrack*)[[anAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]).timeRange;
        
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([self.exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    NSLog(@"Done");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self editTmp:tmpVideoPath];
                    });
                    
                    break;
            }
        }];
        
    }
}

-(void)editTmp:(NSString *)tmpVideoPath{

    UIVideoEditorController* videoEditor = [[[UIVideoEditorController alloc] init] autorelease];
    videoEditor.delegate = self;
    if ( [UIVideoEditorController canEditVideoAtPath:tmpVideoPath])
    {
        videoEditor.videoPath = tmpVideoPath;
        [self presentViewController:videoEditor animated:YES completion:nil];
    }
    else
    {
        NSLog( @"can't edit video at %@", tmpVideoPath );
    }

}

-(void)deleteTmpFile :(NSString *)tmp{
    
    NSLog(@"in deleteTmpFile edit");
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

-(void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath{
    
    NSLog(@"editedVideoPath = %@",editedVideoPath);
    if(editedVideoPath)
    {
        selectedCell.url =[NSURL fileURLWithPath:editedVideoPath];
        MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:[NSURL fileURLWithPath:editedVideoPath]];
        UIImage *image = [moviePlayer thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        [moviePlayer pause];
        [moviePlayer release];
        [[urlAndThumbnails sharedSettings].urlArray replaceObjectAtIndex:selectedCell.cellIndex withObject:[NSURL fileURLWithPath:editedVideoPath]];
        [[urlAndThumbnails sharedSettings].thumbnailArray replaceObjectAtIndex:selectedCell.cellIndex withObject:image];
    }
    [self dismissViewControllerAnimated:YES completion:^(void){
    
//        [self prepareAVplayer:[NSURL fileURLWithPath:editedVideoPath]];
        [self.collectionView reloadData];

    }];
}

-(void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor{

    [selectedCell.backGroundImage setImage:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)changeTransition{
    
    if(selectedCell.transition == -1)
    {
        alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please select video first" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }

    else if((selectedCell.cellIndex + 1 < [urlAndThumbnails sharedSettings].urlArray.count ) )
    {
        [UIView animateWithDuration:0.5 animations:^(void){
            
            [_transitionView setFrame:CGRectMake(0, 227, 320, 277)];
            
        }];
        
    }
    else{
        alert = [[UIAlertView alloc]initWithTitle:@"" message:@"it requires atleast 1 video on your right hand side" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    [selectedCell.backGroundImage setImage:nil];
    scrollButtonEnable = NO;
    selectedCell.isSelected = NO;
}

-(void)getVideos{
    
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName: nil bundle: nil];
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
	[elcPicker setDelegate:self];
    [self presentViewController:elcPicker animated:YES completion:nil];
    [elcPicker release];
    [albumController release];
}

- (void)displayPickerForGroup:(ALAssetsGroup *)group
{
	ELCAssetTablePicker *tablePicker = [[ELCAssetTablePicker alloc] initWithNibName: nil bundle: nil];
    tablePicker.singleSelection = YES;
    tablePicker.immediateReturn = YES;
    
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:tablePicker];
    elcPicker.delegate = self;
	tablePicker.parent = elcPicker;
    
    tablePicker.assetGroup = group;
    [tablePicker.assetGroup setAssetsFilter:[ALAssetsFilter allAssets]];
    
    [self presentViewController:elcPicker animated:YES completion:nil];
    [tablePicker release];
    [elcPicker release];
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    if(info.count)
    {
    for(NSMutableDictionary *dict in info) {
        
        [[urlAndThumbnails sharedSettings].urlArray addObject:[dict objectForKey:@"UIImagePickerControllerMediaURL"]];
        [[urlAndThumbnails sharedSettings].thumbnailArray addObject:[dict objectForKey:@"thumbnail"]];
    }
    NSLog(@"urlArray.count = %d",[urlAndThumbnails sharedSettings].thumbnailArray.count);
    arrayLoaded = YES;
    [_collectionView reloadData];
    [self dismissViewControllerAnimated:NO completion:^(void){
        
    }];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)mergeVideosButton:(UIButton *)sender {
    
    if([urlAndThumbnails sharedSettings].urlArray.count)
    {
        [self makeCellArray];
//        mergeVideosViewController *merge = [[[mergeVideosViewController alloc]initWithNibName:@"mergeVideosViewController" cellArray:cellArray bundle:nil]autorelease];
//        [self presentViewController:merge animated:YES completion:nil];
    }
    else{
    
        alert = [[[UIAlertView alloc]initWithTitle:@"" message:@"Select Video first" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil]autorelease];
        [alert show];
    }
}

-(void)makeCellArray{
    
    NSMutableArray *urls = [[NSMutableArray alloc]init];
    NSMutableArray *themesArray = [[NSMutableArray alloc]init];
    for(int i=0;i<[urlAndThumbnails sharedSettings].urlArray.count;i++)
    {
        if([[urlAndThumbnails sharedSettings].urlArray[i] isKindOfClass:[NSURL class]])
        {
            [urls addObject:[[urlAndThumbnails sharedSettings].urlArray objectAtIndex:i]];
            NSNumber *num = [transitionDict objectForKey:[NSString stringWithFormat:@"%d",i]];
            if(num)
            {
                NSLog(@"num intValue = %d",[num intValue]);
                [themesArray addObject:num];
            }
            else
            {
                [themesArray addObject:[NSNumber numberWithInt:0]];
            }
        }
    }
    NSLog(@"total = %d",[urlAndThumbnails sharedSettings].urlArray.count);
    NSLog(@"urls count= %d",[urls count]);
    NSLog(@"themesArray count = %d",[themesArray count]);
    for(int i=0;i<themesArray.count;i++)
    {
        NSNumber *num = [themesArray objectAtIndex:i];
        NSLog(@"themesArray[%d] = %d",i,[num intValue]);
    }
    mergeVideosViewController *merge = [[[mergeVideosViewController alloc]initWithNibName:@"mergeVideosViewController" urls:urls themeArray:themesArray bundle:Nil]autorelease];
    [self presentViewController:merge animated:YES completion:nil];
}

- (IBAction)LoadVIdeos:(UIButton *)sender {

    if(_selectVideoView.isHidden)
    {
        [_selectVideoView setHidden:NO];
    }
    else
        [_selectVideoView setHidden:YES];
}


- (IBAction)transitionButtonClicked:(UIButton *)sender {
    
    if(sender.tag)
    {
    if([transitionDict objectForKey:[NSString stringWithFormat:@"%d",selectedCell.cellIndex]])
    {
        [[urlAndThumbnails sharedSettings].urlArray replaceObjectAtIndex:selectedCell.cellIndex+1 withObject:[NSNumber numberWithInt:sender.tag]];
        [[urlAndThumbnails sharedSettings].thumbnailArray replaceObjectAtIndex:selectedCell.cellIndex+1 withObject:[UIImage imageNamed:@"add.png"]];
        [transitionDict setObject:[NSNumber numberWithInt:sender.tag] forKey:[NSString stringWithFormat:@"%d",selectedCell.cellIndex]];
    }
    else
    {
    [[urlAndThumbnails sharedSettings].urlArray insertObject:[NSNumber numberWithInt:sender.tag] atIndex:selectedCell.cellIndex+1];
    [[urlAndThumbnails sharedSettings].thumbnailArray insertObject:[UIImage imageNamed:@"add.png"] atIndex:selectedCell.cellIndex+1];
    [transitionDict setObject:[NSNumber numberWithInt:sender.tag] forKey:[NSString stringWithFormat:@"%d",selectedCell.cellIndex]];
    }
    [transitionDict retain];
    alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Transition Selected" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [UIView animateWithDuration:0.5 animations:^(void){
        
        [_transitionView setFrame:CGRectMake(0, 481, 320, 277)];
        
    }];
    [_collectionView reloadData];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^(void){
            
            [_transitionView setFrame:CGRectMake(0, 481, 320, 277)];
            
        }];
    }
}

-(void)prepareAVplayer:(NSURL *)url{
    
    [_indicator setHidden:NO];
    [_indicator startAnimating];

    if(playerView)
   {
    [playerView pause];
    [playerView removeFromSuperview];
    [playerView release];
   }
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction;
    AVAssetTrack *videoTrack, *audioTrack;
    videoTrack = nil;audioTrack = nil;
    MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:url];
    UIImage *image = [moviePlayer thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    [moviePlayer pause];
    [moviePlayer release];
//    NSLog(@"image width = %f height = %f",image.size.width,image.size.height);
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSLog(@"assest duration  = %f",CMTimeGetSeconds(asset.duration));
    videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    if([asset tracksWithMediaType:AVMediaTypeAudio].count)
        audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    if(audioTrack)
        [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    
    CGAffineTransform a;
    if(image.size.width > image.size.height)
        a = CGAffineTransformConcat(CGAffineTransformScale(CGAffineTransformIdentity, 700/image.size.width, 700/image.size.width), CGAffineTransformMakeTranslation(0, 85));
    else
        a = CGAffineTransformConcat(CGAffineTransformScale(CGAffineTransformIdentity, 700/image.size.height, 700/image.size.height), CGAffineTransformMakeTranslation(150,0));

    videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    [videolayerInstruction setTransform:CGAffineTransformConcat(videoTrack.preferredTransform, a) atTime:kCMTimeZero];

    NSArray *tracksToDuck = [mutableComposition tracksWithMediaType:AVMediaTypeAudio];
//    NSLog(@"Total audio added : %d",tracksToDuck.count);
    NSMutableArray *trackMixArray = [NSMutableArray array];
    for (NSInteger i = 0; i < [tracksToDuck count]; i++) {
        
        AVMutableAudioMixInputParameters *trackMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:[tracksToDuck objectAtIndex:i]];
        [trackMix setVolume:selectedCell.audioVolume atTime:kCMTimeZero];
        [trackMixArray addObject:trackMix];
    }
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = trackMixArray;
    
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    mainInstruction.layerInstructions = [NSArray arrayWithObject:videolayerInstruction];
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.renderSize = CGSizeMake(700,700);
    mainCompositionInst.instructions = [NSArray arrayWithObjects:mainInstruction, nil];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:mutableComposition];
    [avPlayerItem setAudioMix:audioMix];
    avPlayerItem.videoComposition = mainCompositionInst;
    playerView = [[PlayerView alloc]initWithFrame:CGRectMake(2, 60, 315, 290) playerItem:avPlayerItem];
    [self.view insertSubview:playerView belowSubview:self.transitionView];
    [avPlayerItem release];

    [_indicator stopAnimating];
    [_indicator setHidden:YES];
}

- (IBAction)chooseVideoAlbum:(UIButton *)sender {
    
    [self getVideos];
}

- (IBAction)recordVideo:(UIButton *)sender {
    
//    [_selectVideoView setHidden:YES];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie, nil];
    
    [self presentViewController:picker animated:YES completion:nil];
    [picker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [[urlAndThumbnails sharedSettings].urlArray addObject:info[UIImagePickerControllerMediaURL]];
    MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:info[UIImagePickerControllerMediaURL]];
    UIImage *image = [moviePlayer thumbnailImageAtTime:01.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    [[urlAndThumbnails sharedSettings].thumbnailArray addObject:image];
    [picker dismissViewControllerAnimated:YES completion:^(void){
        
        arrayLoaded = YES;
        [_collectionView reloadData];
    }];
    [moviePlayer release];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)audioChange:(UIButton *)sender {
    
    MPMediaPickerController *mediaPicker;
    switch (sender.tag) {
        case 1:
            mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
            mediaPicker.delegate = self;
            mediaPicker.prompt = @"Select songs to play";
            [self presentViewController:mediaPicker animated:YES completion:nil];
            [mediaPicker release];
            break;
        case 2:
            [UIView animateWithDuration:0.5 animations:^(void){
                
                [_adjustMusic setFrame:CGRectMake(0, 481, 320, 277)];
                
            }];
            break;
        default:
            break;
    }
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    
    MPMediaItem *mediaItem;
    mediaItem = nil;
    if (mediaItemCollection) {
        
        NSArray *items = [mediaItemCollection items];
        for( int n=0; n < items.count; n++ )    {
            mediaItem = [items objectAtIndex:n];
            NSLog(@"%@=========>",[mediaItem valueForProperty:MPMediaItemPropertyTitle]);
//            [saveImagesAndMusic sharedSettings].audioUrl = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [UIView animateWithDuration:0.5 animations:^(void){
        
        [_adjustMusic setFrame:CGRectMake(0, 481, 320, 277)];
        
    }];
    
    [self changedMusicVideo:[mediaItem valueForProperty:MPMediaItemPropertyAssetURL]];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)changedMusicVideo:(NSURL *)audioURL{

    [_indicator setHidden:NO];
    [_indicator startAnimating];
    NSString *tempDir = NSTemporaryDirectory();
    NSString *tmpVideoPath = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"changenMusicVideo%d.mov",selectedCell.cellIndex]];
    [self deleteTmpFile:tmpVideoPath];
    NSURL *changenMusicVideoUrl = [NSURL fileURLWithPath:tmpVideoPath];
    
    AVAsset *videoAsset = [AVAsset assetWithURL:selectedCell.url];
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    //  Video track
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    AVAsset *audioAsset = [AVAsset assetWithURL:audioURL];
    AVAssetTrack *audioTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    CMTimeRange audio_timeRange = videoTrack.timeRange;
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    
    NSLog(@"beginning export");
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=changenMusicVideoUrl;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        switch ([self.exportSession status]) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            default:
                NSLog(@"NONE");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [[urlAndThumbnails sharedSettings].urlArray replaceObjectAtIndex:selectedCell.cellIndex withObject:changenMusicVideoUrl];
                    selectedCell.url = changenMusicVideoUrl;
                    [_collectionView reloadData];
                    [_selectVideoView setHidden:NO];
                    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:mixComposition];
                    playerView = [[PlayerView alloc]initWithFrame:CGRectMake(2, 60, 315, 290) playerItem:avPlayerItem];
                    [self.view insertSubview:playerView belowSubview:self.transitionView];
                    [avPlayerItem release];
                    
                    [_indicator stopAnimating];
                    [_indicator setHidden:YES];
                });
                
                break;
        }
    }];

}


- (IBAction)adjustSoundButton:(UISlider *)sender {
    
    selectedCell.audioVolume = sender.value;
}

- (void)dealloc {
    
    [_bottomImageView release];
    [_collectionView release];
    [_addButton release];
    [_scrollView release];
    [_bottomView release];
    [_transitionView release];
    [_transitionImageView release];
    [_selectVideoView release];
    [_adjustMusic release];
    [_testImageView release];
    [_adjustSoundSlider release];
    [scrollItemImagesArray release];
    [selectedUrl release];
    [selectedCell release];
    [alert release];
    [previousAsset release];

//    [cellArray release];
    [transitionDict release];
    [playerView release];
    [_indicator release];
    [super dealloc];
}
@end
