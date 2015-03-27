//
//  BOXItem+BOXAdditions.m
//  BoxContentSDK
//
//  Created on 6/4/13.
//  Copyright (c) 2013 Box. All rights reserved.
//
//  NOTE: this file is a mirror of BoxCocoaSDK/Categories/BoxItem+BOXCocoaAdditions.m. Changes made here should be reflected there.
//

#import "BOXItem+BOXAdditions.h"
#import "UIImage+BOXAdditions.h"
#import "BOXFolder.h"
#import "BOXContentSDK.h"

@implementation BOXItem (BOXAdditions)

- (UIImage *)icon
{
    UIImage *icon = nil;

    //FIXME: Collaborated folders and grey folders
    if ([self isKindOfClass:[BOXFolder class]])
    {
        icon = [UIImage imageNamed:@"icon-folder" inBoxSDKResourcesBundle:[BOXContentClient resourcesBundle]];
        return icon;
    }
    
    NSString *extension = [[self.name pathExtension] lowercaseString];
    
    if ([extension isEqualToString:@"docx"]) 
    {
        extension = @"doc";
    }
    if ([extension isEqualToString:@"pptx"]) 
    {
        extension = @"ppt";
    }
    if ([extension isEqualToString:@"xlsx"]) 
    {
        extension = @"xls";
    }
    if ([extension isEqualToString:@"html"]) 
    {
        extension = @"htm";
    }
    if ([extension isEqualToString:@"jpeg"])
    {
        extension = @"jpg";
    }
    
    NSString *str = [NSString stringWithFormat:@"icon-file-%@", extension];
    icon = [UIImage  imageNamed:str inBoxSDKResourcesBundle:[BOXContentClient resourcesBundle]];
    
    if (!icon)
    {
        icon = [UIImage imageNamed:@"icon-file-generic" inBoxSDKResourcesBundle:[BOXContentClient resourcesBundle]];
    }
    
    return icon;
}

@end
