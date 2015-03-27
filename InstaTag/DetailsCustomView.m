//
//  DetailsCustomView.m
//  InstaTag
//
//  Created by Helen Kuo on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import "DetailsCustomView.h"
#import "BOXMetadata.h"
#import "BOXMetadataInfoRequest.h"
#import "BOXSampleThumbnailsHelper.h"
@interface DetailsCustomView ()
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *metadataLabel;

@end

@implementation DetailsCustomView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    UINib *nib = [UINib nibWithNibName:@"DetailsCustomView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    
}

- (void)setFile:(BOXFile *)file {
    _file = file;
    self.metadataLabel.text = @"";
    BOXMetadataInfoRequest *request = [[BOXMetadataInfoRequest alloc] initWithFileID:file.modelID];
    [self.client prepareRequest:request];
    [request performRequestWithCompletion:^(BOXMetadata *metadata, NSError *error) {
        if (error == nil) {
            NSLog(@"%@", metadata.properties);
            self.metadataLabel.text = metadata.properties;
        } else {
            NSLog(@"error %@", error.description);
        }
    }];
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
            BOXFileThumbnailRequest *request = [[BOXContentClient defaultClient] fileThumbnailRequestWithID:self.file.modelID size:BOXThumbnailSize256];
            __weak UIImageView *weakThumbnail = self.thumbnailView;
            
            [request performRequestWithProgress:nil completion:^(UIImage *image, NSError *error) {
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
