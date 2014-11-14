//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by ELC on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"
#import "ELCAlbumPickerController.h"

@implementation ELCImagePickerController

@synthesize delegate = _myDelegate;

- (void)cancelImagePicker
{
	if([_myDelegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
		[_myDelegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
	}
}

- (void)selectedAssets:(NSArray *)assets
{
	NSLog(@"In selected Asset");
   
    NSMutableArray *returnArray = [[[NSMutableArray alloc] init] autorelease];
	for(ALAsset *asset in assets) {

//        [urlAndThumbnails sharedSettings].string = [self writeVideoFileIntoTemp:@"video" andAsset:asset];
        NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
        [workingDictionary setObject:[asset valueForProperty:ALAssetPropertyAssetURL] forKey:@"UIImagePickerControllerMediaURL"];
        UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
        [workingDictionary setObject:image forKey:@"thumbnail"];
        
		
		[returnArray addObject:workingDictionary];
		
		[workingDictionary release];
	}    
	if(_myDelegate != nil && [_myDelegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
		[_myDelegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:[NSArray arrayWithArray:returnArray]];
	} else {
        [self popToRootViewControllerAnimated:NO];
    }
}

//-(NSString*) writeVideoFileIntoTemp:(NSString*)fileName andAsset:(ALAsset*)asset
//{
//    NSString * tmpfile = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
//    
//    
//    ALAssetRepresentation * rep = [asset defaultRepresentation];
//    
//    NSUInteger size = [rep size];
//    const int bufferSize = 1024*1024; // or use 8192 size as read from other posts
//    
//    NSLog(@"Writing to %@",tmpfile);
//    FILE* f = fopen([tmpfile cStringUsingEncoding:1], "wb+");
//    if (f == NULL) {
//        NSLog(@"Can not create tmp file.");
//        return 0;
//    }
//    
//    Byte * buffer = (Byte*)malloc(bufferSize);
//    int read = 0, offset = 0, written = 0;
//    NSError* err;
//    if (size != 0) {
//        do {
//            read = [rep getBytes:buffer
//                      fromOffset:offset
//                          length:bufferSize
//                           error:&err];
//            written = fwrite(buffer, sizeof(char), read, f);
//            offset += read;
//        } while (read != 0);
//        
//        
//    }
//    fclose(f);
//    return tmpfile;
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

#pragma mark -
#pragma mark Memory management

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"ELCImagePickerController");
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"ELC Image Picker received memory warning.");
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc
{
    NSLog(@"deallocing ELCImagePickerController");
    [super dealloc];
}

@end
