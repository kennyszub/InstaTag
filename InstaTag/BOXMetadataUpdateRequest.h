//
//  BOXMetadataUpdateRequest.h
//  InstaTag
//
//  Created by Helen Kuo on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import "BOXRequest.h"

@interface BOXMetadataUpdateRequest : BOXRequest
- (instancetype)initWithFileID:(NSString *)fileID properties:(NSString *)properties;
- (void)performRequestWithCompletion:(BOXMetadataBlock)completionBlock;
@end
