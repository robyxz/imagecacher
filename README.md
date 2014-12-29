# ImageCacher

[![CI Status](http://img.shields.io/travis/Roberto Sartori/ImageCacher.svg?style=flat)](https://travis-ci.org/Roberto Sartori/ImageCacher)
[![Version](https://img.shields.io/cocoapods/v/ImageCacher.svg?style=flat)](http://cocoadocs.org/docsets/ImageCacher)
[![License](https://img.shields.io/cocoapods/l/ImageCacher.svg?style=flat)](http://cocoadocs.org/docsets/ImageCacher)
[![Platform](https://img.shields.io/cocoapods/p/ImageCacher.svg?style=flat)](http://cocoadocs.org/docsets/ImageCacher)

## Usage

ImageCacher helps you to cache web images from a given URL using CoreData framework and memory LAFO (Last Accessed First Out) memory queue strategy for memory caching. The basic operation is to get an image from an URL:

    UIImage *image = [[ICImageChacher] getImageWithURL:<my url> withCompletionHandler^(UIImage *image) {
        // image cached from memory or coredata
        if (image) {
            // do something with the fetched image
        }
    }];
    // check if image was cached in memory and immediatly returned
    if (image) {
        // image was cached in memory, the completion block will not be invoked, use the image here
    }

## Requirements

## Installation

ImageCacher is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "ImageCacher"

## Author

Roberto Sartori, roberto@rawfish.it

## License

ImageCacher is available under the MIT license. See the LICENSE file for more info.

