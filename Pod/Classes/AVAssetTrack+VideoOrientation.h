//
//  AVAssetTrack+VideoOrientation.h
//  Qwikword
//
//  Created by Roberto Sartori on 30/09/14.
//  Copyright (c) 2014 Rawfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    LBVideoOrientationUp,               //Device starts recording in Portrait
    LBVideoOrientationDown,             //Device starts recording in Portrait upside down
    LBVideoOrientationLeft,             //Device Landscape Left  (home button on the left side)
    LBVideoOrientationRight,            //Device Landscape Right (home button on the Right side)
    LBVideoOrientationNotFound = 99     //An Error occurred or AVAsset doesn't contains video track
} LBVideoOrientation;

@interface AVAssetTrack (VideoOrientation)

@property (nonatomic, readonly) LBVideoOrientation videoOrientation;

@end
