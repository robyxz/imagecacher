# ImageCacher

[![CI Status](http://img.shields.io/travis/Roberto Sartori/ImageCacher.svg?style=flat)](https://travis-ci.org/Roberto Sartori/ImageCacher)
[![Version](https://img.shields.io/cocoapods/v/ImageCacher.svg?style=flat)](http://cocoadocs.org/docsets/ImageCacher)
[![License](https://img.shields.io/cocoapods/l/ImageCacher.svg?style=flat)](http://cocoadocs.org/docsets/ImageCacher)
[![Platform](https://img.shields.io/cocoapods/p/ImageCacher.svg?style=flat)](http://cocoadocs.org/docsets/ImageCacher)

## Usage

ImageCacher helps you to easily cache web images from a given URL using [Core Data](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreData/cdProgrammingGuide.html) as persistent storage framework, [GCD](https://developer.apple.com/library/ios/documentation/Performance/Reference/GCD_libdispatch_Ref/) for background fetching and [blocks](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Blocks/Articles/00_Introduction.html) for asynch operations.

ImageCacher strategy is straightforward: you ask for an image by specifying its URL, the singleton class then:

 * search the image into an internal memory structure as first attempt, it will call the handler immediatly before return with source = ICCacheSourceMemory
 * otherwise it will try to fetch the image in background form the caching database, it will call the handler in case of success at the end of the fetching operation (executed in background) with source = ICCacheSourceLocal
 * otherwise download the image from the URL, save it to the caching database and will call the handler with source = ICCacheSourceWeb
 * if URL is invalid or a fatal error occurs the handler il called with source = ICCacheSourceUnknown

The 
```objective-c
    [[ICImageChacher hared] getImageWithURL:<myurl> withCompletionHandler^(UIImage *image ,tICCacheSource source) {
        switch (source) {
        case ICCacheMemory:
            // image has been found into memory, handler is called WITHIN the selector execution
            break;

        case ICCacheLocal:
            // image has been found into local caching database
            break;

        case ICCacheWeb:
            // image has been downloaded for the first time, next time this url will be fetched from memory or from local cache
        }
    }];
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

