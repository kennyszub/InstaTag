//
//  TagViewController.h
//  InstaTag
//
//  Created by Ken Szubzda on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BoxContentSDK/BOXContentSDK.h>

@interface TagViewController : UIViewController
- (instancetype)initWithClient:(BOXContentClient *)client;
@end
