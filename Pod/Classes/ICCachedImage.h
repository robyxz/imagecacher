//
//  ICCachedImage.h
//  Pods
//
//  Created by Roberto Sartori on 29/12/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ICCachedImage : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * imageURL;

@end
