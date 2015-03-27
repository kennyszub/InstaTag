//
//  BrowseCollectionViewCell.m
//  InstaTag
//
//  Created by Helen Kuo on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import "BrowseCollectionViewCell.h"
#import "BOXSampleThumbnailsHelper.h"
#import <BoxContentSDK/BOXContentSDK.h>
@interface BrowseCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (nonatomic, readwrite, strong) BOXFileThumbnailRequest *request;
@end
@implementation BrowseCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)prepareForReuse
{
    [self.request cancel];
    self.request = nil;
}

- (void)setFile:(BOXFile *)file {
    _file = file;
    [self updateThumbnail];
    
}

- (void)updateThumbnail
{
    UIImage *icon = nil;
    
    BOXSampleThumbnailsHelper *thumbnailsHelper = [BOXSampleThumbnailsHelper sharedInstance];
    
    // Try to retrieve the thumbnail from our in memory cache
    UIImage *image = [thumbnailsHelper thumbnailForItemWithID:self.file.modelID userID:self.client.user.modelID];
    
    if (image) {
        icon = image;
    }
    // No cached version was found, we need to query it from our API
    else {
        icon = [UIImage imageNamed:@"icon-file-generic"];
        
        if ([thumbnailsHelper shouldDownloadThumbnailForItemWithName:self.file.name]) {
            self.request = [[BOXContentClient defaultClient] fileThumbnailRequestWithID:self.file.modelID size:BOXThumbnailSize256];
            __weak UIImageView *weakThumbnail = self.thumbnailView;
            
            [self.request performRequestWithProgress:nil completion:^(UIImage *image, NSError *error) {
                if (error == nil) {
                    [thumbnailsHelper storeThumbnailForItemWithID:self.file.modelID userID:self.client.user.modelID thumbnail:image];
                    
                    weakThumbnail.image = image;
                    CATransition *transition = [CATransition animation];
                    transition.duration = 0.3f;
                    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    transition.type = kCATransitionFade;
                    [weakThumbnail.layer addAnimation:transition forKey:nil];
                }
            }];
        }
    }
    self.thumbnailView.image = icon;
}

@end
