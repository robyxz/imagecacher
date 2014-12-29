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

// completion handlers
typedef void (^DCModel_imageCompletionHandler)(UIImage *image);
typedef void (^DCModel_cleanCacheCompletionHandler)(BOOL success);

// Class
@interface ICImageCacher : NSObject

+(ICImageCacher *)shared;
-(NSManagedObjectContext *)managedObjectContext;
-(void)saveContext;

-(NSString *)getChacheSize;

-(void)cleanImageCache;
-(UIImage *)getImageWithURL:(NSString *)imageURL withCompletionHandler:(DCModel_imageCompletionHandler)handler;
-(UIImage *)getThumbnailForVideoWithURL:(NSString *)imageURL withCompletionHandler:(DCModel_imageCompletionHandler)handler;
-(void)fetchImageWithURL:(NSString *)imageURL withCompletionHandler:(DCModel_imageCompletionHandler)handler;
-(BOOL)saveImage:(UIImage *)image withURL:(NSString *)imageURL;
-(void)deleteImageWithURL:(NSString *)imageURL;

@end
