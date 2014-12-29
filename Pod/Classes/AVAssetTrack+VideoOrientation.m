//
//  AVAssetTrack+VideoOrientation.m
//  Qwikword
//
//  Created by Roberto Sartori on 30/09/14.
//  Copyright (c) 2014 Rawfish. All rights reserved.
//

#import "AVAssetTrack+VideoOrientation.h"

@implementation AVAssetTrack (VideoOrientation)

static inline CGFloat RadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
};


- (LBVideoOrientation)videoOrientation
{

    CGAffineTransform txf       = [self preferredTransform];
    CGFloat videoAngleInDegree  = RadiansToDegrees(atan2(txf.b, txf.a));
    
    LBVideoOrientation orientation = 0;
    switch ((int)videoAngleInDegree) {
        case 0:
            orientation = LBVideoOrientationRight;
            break;
        case 90:
            orientation = LBVideoOrientationUp;
            break;
        case 180:
            orientation = LBVideoOrientationLeft;
            break;
        case -90:
            orientation	= LBVideoOrientationDown;
            break;
        default:
            orientation = LBVideoOrientationNotFound;
            break;
    }
    
    return orientation;
}

@end
