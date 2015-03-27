//
//  BOXItemPickerTableViewCell.m
//  BoxContentSDK
//
//  Copyright (c) 2014 Box. All rights reserved.
//

#import "BOXItemPickerTableViewCell.h"
#import "BOXItemPickerHelper.h"
#import "UIImage+BOXAdditions.h"
#import "BOXItem+BOXAdditions.h"
#import "BOXFile.h"
#import <QuartzCore/QuartzCore.h>
#import "BOXRequest.h"

@interface BOXItemPickerTableViewCell ()

@property (nonatomic) BOXRequest *request;

@end

@implementation BOXItemPickerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[self resizeableImageForCell:self]];
        backgroundImageView.frame = self.frame;
        backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.backgroundView = backgroundImageView;
    }
    
    return self;
}

- (void)prepareForReuse {
    [self.request cancel];
    self.request = nil;
    
    _item = nil;
}

- (void)setItem:(BOXItem *)item
{
    if (item == nil || self.item == item) {
        return;
    }
    
    _item = item;
    
    [self renderThumbnail];
}

- (UIImage *)resizeableImageForCell:(UITableViewCell *)cell
{
    static UIImage *_image = nil;
    
    if (!_image) {
        CGSize imageSize = CGSizeMake(1.0f, 3.0f);
        UIGraphicsBeginImageContextWithOptions(imageSize, YES, [[UIScreen mainScreen] scale]);
        
        UIColor *topColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        UIColor *middleColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        UIColor *bottomColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
        
        [topColor set];
        UIRectFill(CGRectMake(0.0f, 0.0f, imageSize.width, 1.0f));
        
        [middleColor set];
        UIRectFill(CGRectMake(0.0f, 1.0f, imageSize.width, 1.0f));
        
        [bottomColor set];
        UIRectFill(CGRectMake(0.0f, 2.0f, imageSize.width, 1.0f));
        
        _image = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(1.0f, 0.0f, 1.0f, 0.0f) resizingMode:UIImageResizingModeStretch];	

        UIGraphicsEndImageContext();
    }
    return _image;
}

- (void)renderThumbnail
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = [[self.item icon] imageWith2XScaleIfRetina];
    });
    
    if (self.showThumbnails && [self.item isKindOfClass:[BOXFile class]]) {
        __block BOXItem *currentItem = self.item;
        __weak BOXItemPickerTableViewCell *me = self;
        
        // Load thumbnail via the API if necessary
        self.request = [self.helper thumbnailForItem:self.item cachePath:self.cachePath refreshed:^(UIImage *image) {
            if (image && me.item == currentItem)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    me.imageView.image = [image imageWith2XScaleIfRetina];
                    
                    CATransition *transition = [CATransition animation];
                    transition.duration = 0.3f;
                    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    transition.type = kCATransitionFade;
                    
                    [me.imageView.layer addAnimation:transition forKey:nil];
                });
            }
        }];
    }
}

@end
