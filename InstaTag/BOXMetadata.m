//
//  BOXMetadata.m
//  InstaTag
//
//  Created by Helen Kuo on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import "BOXMetadata.h"

@implementation BOXMetadata

- (instancetype)initWithJSON:(NSDictionary *)JSONResponse
{
    
    if (self = [super initWithJSON:JSONResponse]) {
        
        self.properties = [NSJSONSerialization box_ensureObjectForKey:@"instaTagProp"
                                                   inDictionary:JSONResponse
                                                hasExpectedType:[NSString class]
                                                    nullAllowed:NO];
        
        self.type = [NSJSONSerialization box_ensureObjectForKey:@"$type"
                                                             inDictionary:JSONResponse
                                                          hasExpectedType:[NSString class]
                                                              nullAllowed:NO];
        self.parent = [NSJSONSerialization box_ensureObjectForKey:@"$parent"
                                                   inDictionary:JSONResponse
                                                hasExpectedType:[NSString class]
                                                    nullAllowed:NO];
        
        self.metadataId = [NSJSONSerialization box_ensureObjectForKey:@"$id"
                                                   inDictionary:JSONResponse
                                                hasExpectedType:[NSString class]
                                                    nullAllowed:NO];
    }
    
    return self;
}
@end
