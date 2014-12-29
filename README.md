# ImageCacher

[![CI Status](http://img.shields.io/travis/Roberto Sartori/ImageCacher.svg?style=flat)](https://travis-ci.org/Roberto Sartori/ImageCacher)
[![Version](https://img.shields.io/cocoapods/v/ImageCacher.svg?style=flat)](http://cocoadocs.org/docsets/ImageCacher)
[![License](https://img.shields.io/cocoapods/l/ImageCacher.svg?style=flat)](http://cocoadocs.org/docsets/ImageCacher)
[![Platform](https://img.shields.io/cocoapods/p/ImageCacher.svg?style=flat)](http://cocoadocs.org/docsets/ImageCacher)

## Usage

ImageCacher helps you to easily cache web images from a given URL using [Core Data](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreData/cdProgrammingGuide.html) as persistent storage framework, [GCD](https://developer.apple.com/library/ios/documentation/Performance/Reference/GCD_libdispatch_Ref/) for background fetching and [blocks](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Blocks/Articles/00_Introduction.html) for asynch operations.

ImageCacher strategy is straightforward: you ask for an image given its URL, the singleton class will then:

 * search the image into an internal memory queue as first attempt, it will return the image immediatly in case of success
 * fetch the image in background form the persistent caching database, it will return the image in a completion block in case of success
 * download the image from the URL, save it to the persistent caching database and will return the image in a completion block

The 
```objective-c
    UIImage *image = [[ICImageChacher hared] getImageWithURL:<my url> withCompletionHandler^(UIImage *image) {
        // image cached from memory or coredata
        if (image) {
            // do something with the fetched image
        }
    }];
    // check if image was cached in memory and immediatly returned
    if (image) {
        // image was cached in memory, the completion block will not be invoked, use the image here
    }
```

## Requirements

## Installation

ImageCacher is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "ImageCacher"

## Author

Roberto Sartori, roberto@rawfish.it

## License

ImageCacher is available under the MIT license. See the LICENSE file for more info.

