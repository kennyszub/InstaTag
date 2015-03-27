//
//  MetadataViewController.h
//  InstaTag
//
//  Created by Helen Kuo on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BoxContentSDK/BOXContentSDK.h>

@interface MetadataViewController : UIViewController
- (instancetype)initWithClient:(BOXContentClient *)client files:(NSArray *)files startingIndex:(NSInteger) startingIndex;

@end
