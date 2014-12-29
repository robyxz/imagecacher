//
//  AVAsset+Thumbnail.h
//  Qwikword
//
//  Created by Roberto Sartori on 01/10/14.
//  Copyright (c) 2014 Rawfish. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

typedef void(^ThumbnailComplete)(UIImage* thumbnail);

@interface AVAsset (Thumbnail)

-(UIImage*)getThumbnailSync;
-(void)getThumbnailAsync:(ThumbnailComplete)complete;

@end
