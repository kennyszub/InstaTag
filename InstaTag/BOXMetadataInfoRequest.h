//
//  BOXMetadataInfoRequest.h
//  InstaTag
//
//  Created by Helen Kuo on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import "BOXRequest.h"

@interface BOXMetadataInfoRequest : BOXRequest
- (instancetype)initWithFileID:(NSString *)fileID;
- (void)performRequestWithCompletion:(BOXMetadataBlock)completionBlock;
@end
