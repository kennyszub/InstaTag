//
//  BOXItemPickerHelper.h
//  BoxContentSDK
//
//  Created on 5/1/13.
//  Copyright (c) 2013 Box Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BOXItem;
@class BOXContentClient;
@class BOXRequest;

typedef void (^BOXThumbnailDownloadBlock)(UIImage *image);

/**
 * A helper class for manipulating thumbnails and SDK model objects.
 *
 * Typedefs
 * ========
 * <pre><code>typedef void (^BOXThumbnailDownloadBlock)(UIImage *image);</code></pre>
 */
@interface BOXItemPickerHelper : NSObject

@property (nonatomic, readwrite, strong) BOXContentClient *client;

- (id)initWithClient:(BOXContentClient *)client;

/**
 * Returns a readable string of the last update date of the item.
 *
 * @param item The item to calculate a date string for.
 */
- (NSString *)dateStringForItem:(BOXItem *)item;

/**
 * Retrieves the cached item thumbnail or downloads the thumbnail if required.
  * @param item The thumbnail's corresponding item.
  * @param cachePath The path where to look for and cache the thumbnail.
  * @param refreshed Callback returning the refreshed cached image.
 */
- (BOXRequest *)thumbnailForItem:(BOXItem *)item
               cachePath:(NSString *)cachePath
               refreshed:(BOXThumbnailDownloadBlock)refreshed;

/**
 * Cancels all occuring thumbnail download operations.
 */
- (void)cancelThumbnailOperations;

/**
 * Purges the dictionnary containing the in-memory thumbnail images. No op if the user uses cached files on disk.
 */
- (void)purgeInMemoryCache;

/**
 * Return the in memory cached thumbnail for an item.
 *
 * @param item The item to return the cached thumbnail for.
 */
- (UIImage *)inMemoryCachedThumbnailForItem:(BOXItem *)item;

@end
