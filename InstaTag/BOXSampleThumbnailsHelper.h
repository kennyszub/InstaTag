//
//  BOXSampleThumbnailsHelper.h
//  InstaTag
//
//  Created by Helen Kuo on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BOXSampleThumbnailsHelper : NSObject

+ (instancetype)sharedInstance;

- (void)storeThumbnailForItemWithID:(NSString *)itemID userID:(NSString *)userID thumbnail:(UIImage *)thumbnail;
- (UIImage *)thumbnailForItemWithID:(NSString *)itemID userID:(NSString *)userID;

- (BOOL)shouldDownloadThumbnailForItemWithName:(NSString *)itemName;

@end
