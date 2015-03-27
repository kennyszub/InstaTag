//
//  BOXMetadata.h
//  InstaTag
//
//  Created by Helen Kuo on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import "BOXModel.h"

@interface BOXMetadata : BOXModel
@property (nonatomic, readwrite, strong) NSString *properties;
@property (nonatomic, readwrite, strong) NSString *type;
@property (nonatomic, readwrite, strong) NSString *parent;
@property (nonatomic, readwrite, strong) NSString *metadataId;
@end
