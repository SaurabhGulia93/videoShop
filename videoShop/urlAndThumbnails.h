//
//  urlAndThumbnails.h
//  videoShop
//
//  Created by unibera1 on 9/26/13.
//  Copyright (c) 2013 unibera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface urlAndThumbnails : NSObject

@property (retain,nonatomic) NSMutableArray *urlArray;
@property (retain,nonatomic) NSMutableArray *thumbnailArray;
@property (nonatomic , assign) int index;
+(urlAndThumbnails*)sharedSettings;
@end
