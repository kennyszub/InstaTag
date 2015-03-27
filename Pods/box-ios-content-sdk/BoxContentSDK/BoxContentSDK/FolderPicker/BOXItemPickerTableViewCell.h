//
//  BOXItemPickerTableViewCell.h
//  BoxContentSDK
//
//  Copyright (c) 2014 Box. All rights reserved.
//

#import "BOXItemPickerHelper.h"

@class BOXItem;

@interface BOXItemPickerTableViewCell : UITableViewCell

@property (nonatomic, readwrite, strong) BOXItemPickerHelper *helper;
@property (nonatomic, readwrite, strong) BOXItem *item;
@property (nonatomic, readwrite, strong) NSString *cachePath;
@property (nonatomic, readwrite, assign) BOOL showThumbnails;
@property (nonatomic, readwrite, assign) BOOL enabled;

- (void)renderThumbnail;

@end
