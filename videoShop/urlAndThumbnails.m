//
//  urlAndThumbnails.m
//  videoShop
//
//  Created by unibera1 on 9/26/13.
//  Copyright (c) 2013 unibera. All rights reserved.
//

#import "urlAndThumbnails.h"

@implementation urlAndThumbnails

static urlAndThumbnails *_sharedSettings = nil;

+(urlAndThumbnails *)sharedSettings{
    
    @synchronized([urlAndThumbnails class]){
        
        if(!_sharedSettings)
        {
            [[self alloc]init];
            return _sharedSettings;
        }
    }
    
    return _sharedSettings;
}

+(id)alloc
{
    @synchronized([urlAndThumbnails class]){
        
        NSAssert(_sharedSettings == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedSettings = [super alloc];
        return _sharedSettings;
    }
    return nil;
}

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        self.urlArray = [[NSMutableArray alloc]init];
        self.thumbnailArray = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)dealloc{

    [_sharedSettings release];
    
    [super dealloc];
}

@end
