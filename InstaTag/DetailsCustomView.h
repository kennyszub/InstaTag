//
//  DetailsCustomView.h
//  InstaTag
//
//  Created by Helen Kuo on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BoxContentSDK/BOXContentSDK.h>

@interface DetailsCustomView : UIView
@property (nonatomic, strong) BOXFile *file;
@property (nonatomic, readwrite, strong) BOXContentClient *client;
@end
