//
//  ICImageCacher.h
//  image_cacher
//
//  Created by Roberto Sartori on 29/12/14.
//  Copyright (c) 2014 Roberto Sartori. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

typedef enum {
    ICCacheSourceMemory     = 0,
    ICCacheSourceLocal      = 1,
    ICCacheSourceWeb        = 2,
    ICCacheSourceUndefined  = 99
} tICCacheSource;

// completion handlers
typedef void (^DCModel_imageCompletionHandler)(UIImage *image, tICCacheSource source);
typedef void (^DCModel_cleanCacheCompletionHandler)(BOOL success);

// Class
@interface ICImageCacher : NSObject

+(ICImageCacher *)shared;
-(NSManagedObjectContext *)managedObjectContext;
-(void)saveContext;

-(NSString *)getChacheSize;

-(void)cleanImageCache;
-(void)getImageWithURL:(NSString *)imageURL withCompletionHandler:(DCModel_imageCompletionHandler)handler;
-(void)getThumbnailForVideoWithURL:(NSString *)imageURL withCompletionHandler:(DCModel_imageCompletionHandler)handler;
-(void)fetchImageWithURL:(NSString *)imageURL withCompletionHandler:(DCModel_imageCompletionHandler)handler;
-(BOOL)saveImage:(UIImage *)image withURL:(NSString *)imageURL;
-(void)deleteImageWithURL:(NSString *)imageURL;

@end
