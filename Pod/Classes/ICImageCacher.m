//
//  ICImageCacher.m
//  image_cacher
//
//  Created by Roberto Sartori on 29/12/14.
//  Copyright (c) 2014 Roberto Sartori. All rights reserved.
//

#import "ICImageCacher.h"
#import "ICCachedImage.h"

#import "AVAsset+Thumbnail.h"
#import "AVAssetTrack+VideoOrientation.h"

#define MAX_CACHED_IMAGES   50

static ICImageCacher    *shared_ICImageCacher;

@interface ICImageCacher()

// Core data components
@property (nonatomic, retain) NSManagedObjectModel              *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext            *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator      *persistentStoreCoordinator;

@property (nonatomic, retain) NSString                          *persistentString;
@property (nonatomic, retain) NSURL                             *persistentURL;

// image caching data
@property (nonatomic, strong) NSMutableDictionary   *imagesURLCache;
@property (nonatomic, strong) NSMutableDictionary   *callbacksForImageCaching;
@property (nonatomic, strong) NSMutableArray        *lastAccessedURLs;

@end

@implementation ICImageCacher

+(ICImageCacher *)shared {
    static dispatch_once_t token_once_ICImageCacher;
    dispatch_once(&token_once_ICImageCacher, ^{
        shared_ICImageCacher = [[ICImageCacher alloc] init];
        
        // register for model changes notifications
    });
    
    return shared_ICImageCacher;
}

#pragma CLASS

-(id) init {
    self = [super init];
    if (self) {
        [self setupManagedObjectContext];
        self.imagesURLCache             = [NSMutableDictionary dictionary];
        self.callbacksForImageCaching   = [NSMutableDictionary dictionary];
        self.lastAccessedURLs           = [NSMutableArray array];
        
    }
    return self;
}

- (void)setupManagedObjectContext {
    
    // prepare the persistent coordinator
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    NSURL *documentDirectoryURL = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    self.persistentString       = [NSString stringWithFormat:@"%@.sqlite", @"ICImageCacher"];
    self.persistentURL          = [documentDirectoryURL URLByAppendingPathComponent:self.persistentString];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ICImageCacher" withExtension:@"momd"];
    
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSError *error = nil;
    NSPersistentStore *persistentStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                                       configuration:nil
                                                                                                 URL:self.persistentURL
                                                                                             options:nil
                                                                                               error:&error];
    if (persistentStore) {
        self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    } else {
        // failed to initialize, unrecoverable error. Raise exception
        [[NSException exceptionWithName:@"initError" reason:@"ICImageCacher failed to initialize, persistent store not creted" userInfo:nil] raise];
        return;
    }
}


-(void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        BOOL chancesToBeSaved = [managedObjectContext hasChanges];
        if (chancesToBeSaved) {
            if (![managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                abort();
            } else {
                
            }
        }
    }
}

-(NSString *)getChacheSize {
    
    NSArray *allStores = [self.persistentStoreCoordinator persistentStores];
    unsigned long long totalBytes = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSPersistentStore *store in allStores) {
        if (![store.URL isFileURL]) continue; // only file URLs are compatible with NSFileManager
        NSString *path = [[store URL] path];
        // NSDictionary has a category to assist with NSFileManager attributes
        totalBytes += [[fileManager attributesOfItemAtPath:path error:NULL] fileSize];
    }
    
    unsigned long long kbytes = totalBytes / 1024;
    if (kbytes / 1024 > 0) {
        return [NSString stringWithFormat:@"%.2f Mb", ((double)kbytes) / 1024.];
    } else {
        return [NSString stringWithFormat:@"%li kb", (long)kbytes];
    }
}

-(NSManagedObjectContext *)managedObjectContext {
    return _managedObjectContext;
}

-(void)dealloc {

}

#pragma mark - Coredata background fetching

- (void)sr_executeFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSArray *objects, NSError *error))completion {
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundContext performBlock:^{
        backgroundContext.persistentStoreCoordinator = coordinator;
        
        // Fetch into shared persistent store in background thread
        NSError *error = nil;
        NSArray *fetchedObjects = [backgroundContext executeFetchRequest:request error:&error];
        
        [self.managedObjectContext performBlock:^{
            
            
            if (fetchedObjects) {
                // Collect object IDs
                NSMutableArray *mutObjectIds = [[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]];
                for (NSManagedObject *obj in fetchedObjects) {
                    [mutObjectIds addObject:obj.objectID];
                }
                
                // Fault in objects into current context by object ID as they are available in the shared persistent store
                NSMutableArray *mutObjects = [[NSMutableArray alloc] initWithCapacity:[mutObjectIds count]];
                for (NSManagedObjectID *objectID in mutObjectIds) {
                    NSManagedObject *obj = [self.managedObjectContext objectWithID:objectID];
                    [mutObjects addObject:obj];
                }
                
                if (completion) {
                    NSArray *objects = [mutObjects copy];
                    completion(objects, nil);
                }
            } else {
                if (completion) {
                    completion(nil, error);
                }
            }
        }];
    }];
}

#pragma mark - Image caching

-(void)updateLastAccessedURLs:(NSString *)imageURL {
    // find the url index
    NSArray *elements = [self.lastAccessedURLs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == '%@'", imageURL]];
    if (elements.count == 1) {
        // found, move elemnt to the end
        NSString *element = elements[0];
        [self.lastAccessedURLs removeObject:element];
        [self.lastAccessedURLs addObject:element];
    } else {
        if (elements.count == 0) {
            // url not present, add it
            [self.lastAccessedURLs addObject:imageURL];
        }
    }
    
    //limit the number of cached images
    if (self.lastAccessedURLs.count > MAX_CACHED_IMAGES) {
        // clean the oldest image
        NSString *oldestImageURL = self.lastAccessedURLs[0];
        [self.imagesURLCache removeObjectForKey:oldestImageURL];
        [self.lastAccessedURLs removeObjectAtIndex:0];
    }
}

-(void)cleanImageCache {
    // select all images and remove them
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CachedImage"
                                              inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    
    NSError *e;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&e];
    
    for (NSManagedObject *obj in result) {
        [self.managedObjectContext deleteObject:obj];
    }
    
    [self saveContext];
    
    [self.imagesURLCache removeAllObjects];
}

-(void)getImageWithURL:(NSString *)imageURL withCompletionHandler:(DCModel_imageCompletionHandler)handler {
    
    // IMAGES HAVE ALSO TO BE FETCHED FROM THE PERSISTENT CACHE
    UIImage *image = self.imagesURLCache[imageURL];
    if (image) {
        handler(image, ICCacheSourceMemory);
    } else {
        // check if image is caching, if yes then queue the callback
        NSMutableArray *callbacks = self.callbacksForImageCaching[imageURL];
        if (callbacks) {
            // image is caching now, queue the handler
            [callbacks addObject:handler];
        } else {
            // image is not caching, create the handler queue
            callbacks = [NSMutableArray array];
            [callbacks addObject:handler];
            self.callbacksForImageCaching[imageURL] = callbacks;
        }
        
        // fetch from CoreData in background
        [self fetchImageWithURL:imageURL withCompletionHandler:^(UIImage *image, tICCacheSource source) {
            
            if (image) {
                // image fetched from coredata
                self.imagesURLCache[imageURL] = image;
                [self updateLastAccessedURLs:imageURL];
                
                // process the handler queue
                for (DCModel_imageCompletionHandler queuedHandler in self.callbacksForImageCaching[imageURL]) {
                    queuedHandler(image ,source);
                }
                [self.callbacksForImageCaching removeObjectForKey:imageURL];
            } else {
                // fetch image from the URL
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                    UIImage *downloadedImage = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (downloadedImage) {
                            [[ICImageCacher shared] saveImage:downloadedImage withURL:imageURL];
                            
                            // save into memory cache
                            self.imagesURLCache[imageURL] = downloadedImage;
                            [self updateLastAccessedURLs:imageURL];
                            
                            // call the callbacks queued for this image URL
                            for (DCModel_imageCompletionHandler queuedHandler in self.callbacksForImageCaching[imageURL]) {
                                queuedHandler(downloadedImage, ICCacheSourceWeb);
                            }
                            [self.callbacksForImageCaching removeObjectForKey:imageURL];
                            
                        } else {
                            // no image in cache for this url and I was not able to download it. failed.
                            for (DCModel_imageCompletionHandler queuedHandler in self.callbacksForImageCaching[imageURL]) {
                                queuedHandler(nil, ICCacheSourceUndefined);
                            }
                            [self.callbacksForImageCaching removeObjectForKey:imageURL];
                        }
                    });
                });
            }
        }];
    }
}

-(void)fetchImageWithURL:(NSString *)imageURL withCompletionHandler:(DCModel_imageCompletionHandler)handler {
    
    // fetch the image from the local cache
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CachedImage"
                                              inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF.imageURL == '%@'", imageURL]];
    
    [self sr_executeFetchRequest:request completion:^(NSArray *objects, NSError *error) {
        if (objects) {
            if (objects.count == 1) {
                // image loaded
                ICCachedImage *cachedImage = objects[0];
                UIImage *img = [UIImage imageWithData:cachedImage.image];
                if (img) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(img, ICCacheSourceCoreData);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(nil, ICCacheSourceUndefined);
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(nil, ICCacheSourceUndefined);
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil, ICCacheSourceUndefined);
            });
        }
    }];
};

-(void)getThumbnailForVideoWithURL:(NSString *)imageURL withCompletionHandler:(DCModel_imageCompletionHandler)handler {
    // IMAGES HAVE ALSO TO BE FETCHED FROM THE PERSISTENT CACHE
    UIImage *image = self.imagesURLCache[imageURL];
    if (image) {
        handler (image, ICCacheSourceMemory);
    } else {
        // fetch from CoreData in background
        [self fetchImageWithURL:imageURL withCompletionHandler:^(UIImage *image, tICCacheSource source) {
            
            if (image) {
                // image fetched from coredata
                self.imagesURLCache[imageURL] = image;
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(image, source);
                });
            } else {
                // fetch image from the URL
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    
                    // produce the first frame image
                    // substityte https with http if necessary
                    NSString *finalURL;
                    NSString *startingURL = [imageURL substringToIndex:5];
                    if ([startingURL isEqualToString:@"https"]) {
                        finalURL = [NSString stringWithFormat:@"http%@", [imageURL substringFromIndex:5]];
                    } else {
                        finalURL = imageURL;
                    }
                    
                    AVAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:finalURL]];
                    
                    UIImage *thumbnail = [asset getThumbnailSync];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (thumbnail) {
                            // save manually because remove link is not an image (cache can't consider it valid data to be cached)
                            [[ICImageCacher shared] saveImage:thumbnail withURL:imageURL];
                            
                            // save into memory cache
                            self.imagesURLCache[imageURL] = thumbnail;
                            [self updateLastAccessedURLs:imageURL];
                            
                            handler(thumbnail, ICCacheSourceWeb);
                        } else {
                            handler(nil, ICCacheSourceUndefined);
                        }
                    });
                });
            }
        }];
    }
}

-(BOOL)saveImage:(UIImage *)image withURL:(NSString *)imageURL {
    // fetch the image from the local cache
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CachedImage"
                                              inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF.imageURL == '%@'", imageURL]];
    
    NSError *e;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&e];
    
    ICCachedImage *cachedImage;
    if (result.count > 1) {
        return false;
    } else {
        if (result.count == 1) {
            cachedImage = result[0];
        } else {
            cachedImage = [NSEntityDescription insertNewObjectForEntityForName:@"CachedImage" inManagedObjectContext:self.managedObjectContext];
        }
    }
    
    // IMAGES HAVE ALSO TO BE SAVED INTO THE PERSISTENT CACHE
    cachedImage.imageURL = imageURL;
    cachedImage.image = [NSData dataWithData:UIImageJPEGRepresentation(image, 1)];
    
    [self saveContext];
    
    return YES;
}

-(void)deleteImageWithURL:(NSString *)imageURL {
    // fetch the image from the local cache
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CachedImage"
                                              inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF.imageURL == '%@'", imageURL]];
    
    NSError *e;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&e];
    
    if (result.count > 0) {
        for (id entity in result) {
            [self.managedObjectContext deleteObject:entity];
        }
        
        [self saveContext];
    }
}

@end
