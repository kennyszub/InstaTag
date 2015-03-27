//
//  UIImage+BOXAdditions.m
//  BoxContentSDK
//
//  Created on 6/3/13.
//  Copyright (c) 2013 Box. All rights reserved.
//
//  NOTE: this file is a mirror of BoxCocoaSDK/Categories/NSImage+BOXAdditions.m. Changes made here should be reflected there.
//

#import "UIImage+BOXAdditions.h"

@implementation UIImage (BOXAdditions)

+ (UIImage *) imageNamed:(NSString *)string inBoxSDKResourcesBundle:(NSBundle *)bundle
{
    NSString *str = [[bundle resourcePath] stringByAppendingPathComponent:[bundle pathForResource:string ofType:nil]];
    return [UIImage imageWithContentsOfFile:[str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", string]]];
}

- (UIImage *)imageWith2XScaleIfRetina;
{
    UIImage *image = self;
    if ([UIScreen mainScreen].scale == 2.0)
    {
        image = [UIImage imageWithCGImage:image.CGImage scale:2.0f orientation:image.imageOrientation];
    }

    return image;
}

@end
