//
//  AVAsset+Thumbnail.m
//  Qwikword
//
//  Created by Roberto Sartori on 01/10/14.
//  Copyright (c) 2014 Rawfish. All rights reserved.
//

#import "AVAsset+Thumbnail.h"
#import "AVAssetTrack+VideoOrientation.h"
#import <UIKit/UIKit.h>

@implementation AVAsset (Thumbnail)

-(UIImage*)getThumbnailSync {
    // picked a video, extract a frame
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:self];
    NSArray *tracks = [self tracksWithMediaType:AVMediaTypeVideo];
    
    if (tracks.count > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        LBVideoOrientation videoOrientation = [videoTrack videoOrientation];
        
        //                AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];
        //                CMTime time = videoTrack.minFrameDuration;
        int frameRate = (int)videoTrack.nominalFrameRate;
        
        CMTime time = CMTimeMake(1,frameRate);
        NSError *error;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
        if (error) {
            return nil;
        } else {
            UIImage *thumbnail = nil;
            
            switch (videoOrientation) {
                case LBVideoOrientationUp:
                    thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:UIImageOrientationRight];
                    break;
                case LBVideoOrientationDown:
                    thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:UIImageOrientationLeft];
                    break;
                case LBVideoOrientationLeft:
                    thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:UIImageOrientationDown];
                    break;
                case LBVideoOrientationRight:
                    thumbnail = [UIImage imageWithCGImage:imageRef];
                    break;
                    
                default:
                    break;
            }
            
            CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
            return thumbnail;
            
        }
    } else {
        return nil;
    }
}

-(void)getThumbnailAsync:(ThumbnailComplete)complete {
    // picked a video, extract a frame
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:self];
    NSArray *tracks = [self tracksWithMediaType:AVMediaTypeVideo];
    
    if (tracks.count >0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        LBVideoOrientation videoOrientation = [videoTrack videoOrientation];
        
        //                AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];
        //                CMTime time = videoTrack.minFrameDuration;
        int frameRate = (int)videoTrack.nominalFrameRate;
        
        CMTime time = CMTimeMake(1,frameRate);

        [imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]] completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
            
            if (!error && result == AVAssetImageGeneratorSucceeded) {
            
                UIImage *thumbnail = nil;
                
                switch (videoOrientation) {
                    case LBVideoOrientationUp:
                        thumbnail = [UIImage imageWithCGImage:image scale:1.0f orientation:UIImageOrientationRight];
                        break;
                    case LBVideoOrientationDown:
                        thumbnail = [UIImage imageWithCGImage:image scale:1.0f orientation:UIImageOrientationLeft];
                        break;
                    case LBVideoOrientationLeft:
                        thumbnail = [UIImage imageWithCGImage:image scale:1.0f orientation:UIImageOrientationDown];
                        break;
                    case LBVideoOrientationRight:
                        thumbnail = [UIImage imageWithCGImage:image];
                        break;
                        
                    default:
                        break;
                }
                // CGImageRef won't be released by ARC
                complete(thumbnail);
                CGImageRelease(image);

            }else {
                complete(nil);
            }
        }];
    } else {
        complete(nil);
    }
}

@end
