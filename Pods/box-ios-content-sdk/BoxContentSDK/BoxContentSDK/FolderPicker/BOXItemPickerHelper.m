//
//  BOXItemPickerHelper.m
//  BoxContentSDK
//
//  Created on 5/1/13.
//  Copyright (c) 2013 Box Inc. All rights reserved.
//

#import "BOXItemPickerHelper.h"
#import "BOXContentSDK.h"

//FIXME: Now there is @3x too.
#define BOX_IS_RETINA ([UIScreen mainScreen].scale == 2.0)

@interface BOXItemPickerHelper () 

@property (nonatomic, readwrite, strong) NSMutableDictionary *datesStringsCache;
@property (nonatomic, readwrite, strong) NSMutableDictionary *currentOperations;

// Dictionary only used when the user does not want to store thumbnails on the hard drive, in order no to request several times a thumbnail.
@property (nonatomic, readwrite, strong) NSMutableDictionary *inMemoryCache;

@end

@implementation BOXItemPickerHelper

- (id)initWithClient:(BOXContentClient *)client
{
    self = [super init];
    if (self != nil)
    {
        _client = client;
        _datesStringsCache = [NSMutableDictionary dictionary];
        _currentOperations = [NSMutableDictionary dictionary];
        _inMemoryCache = [NSMutableDictionary dictionary];
    }

    return self;
}

#pragma mark - Helper Methods

- (NSString *)dateStringForItem:(BOXItem *)item
{
    // Caching the dates string to avoid performance drop while formatting dates.
    NSString *dateString = [self.datesStringsCache objectForKey:item.modelID];

    if (dateString == nil)
    {
        dateString = [NSDateFormatter localizedStringFromDate:item.modifiedDate
                                                    dateStyle:NSDateFormatterShortStyle
                                                    timeStyle:NSDateFormatterShortStyle];
        if (dateString) {
            [self.datesStringsCache setObject:dateString forKey:item.modelID];
        }
    }
    
    return dateString;    
}

#pragma mark - Thumbnail Caching Management

- (BOXRequest *)thumbnailForItem:(BOXItem *)item
               cachePath:(NSString *)cachePath
               refreshed:(BOXThumbnailDownloadBlock)refreshed
{
    BOXAssert([item isKindOfClass:[BOXFile class]], @"We only fetch thumbnails for files, not folders.");
    
    NSString *cachedThumbnailPath = [cachePath stringByAppendingPathComponent:item.modelID];
    
    BOXRequest *request = nil;
    
    UIImage *image = [self cachedThumbnailForItem:item thumbnailPath:cachedThumbnailPath];
    if (image) {
        refreshed(image);
    } else {
        image = [self inMemoryCachedThumbnailForItem:item];
        if (image) {
            refreshed(image);
        } else {
            // We don't have the thumbnail in cache so we must retrieve it from Box
            BOXThumbnailSize size = BOX_IS_RETINA ? BOXThumbnailSize64 : BOXThumbnailSize32;
            request = [self.client fileThumbnailRequestWithID:item.modelID size:size];
            [(BOXFileThumbnailRequest *)request performRequestWithProgress:nil completion:^(UIImage *image, NSError *error) {
                if (!error) {
                    [self.currentOperations removeObjectForKey:item.modelID];
                    if (refreshed) {
                        refreshed(image);
                    }
                    
                    if (cachedThumbnailPath) {
                        [UIImagePNGRepresentation(image) writeToFile:cachedThumbnailPath atomically:YES];
                    } else {
                        // Storing the image in a memory cache that will be cleared once the user dismisses the folder picker.
                        [self.inMemoryCache setObject:image forKey:item.modelID];
                    }
                }
            }];
        }
    }
    return request;
}

- (UIImage *)cachedThumbnailForItem:(BOXItem *)item thumbnailPath:(NSString *)thumbnailPath
{
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:thumbnailPath];
    
    if (data) {
        return [UIImage imageWithData:data];
    }
    return nil;
}

- (void)cancelThumbnailOperations
{
    NSArray *keys = [self.currentOperations allKeys];
    for (NSString *str in keys) {
        BOXRequest *operation = [self.currentOperations objectForKey:str];
        [self.currentOperations removeObjectForKey:str];
        [operation cancel];
    }
}

#pragma mark - purge Management

- (void)purgeInMemoryCache
{
    [self.inMemoryCache removeAllObjects];
}

- (UIImage *)inMemoryCachedThumbnailForItem:(BOXItem *)item
{
    return [self.inMemoryCache objectForKey:item.modelID];
}

@end
