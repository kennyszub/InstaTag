//
//  BOXMetadataUpdateRequest.m
//  InstaTag
//
//  Created by Helen Kuo on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import "BOXMetadataUpdateRequest.h"
#import "BOXAPIOperation.h"
#import "BOXRequest_Private.h"
#import "BOXMetadata.h"

@interface BOXMetadataUpdateRequest ()

@property (nonatomic, readonly, strong) NSString *fileID;
@property (nonatomic, readonly, strong) NSString *properties;

@end

@implementation BOXMetadataUpdateRequest

- (instancetype)initWithFileID:(NSString *)fileID properties:(NSString *)properties
{
    if (self = [super init]) {
        _fileID = fileID;
        _properties = properties;
    }
    return self;
}

- (BOXAPIOperation *)createOperation
{
    NSURL *URL = [self URLWithResource:@"files"
                                    ID:self.fileID
                           subresource:@"metadata/global/properties"
                                 subID:nil];
    
    NSMutableDictionary *bodyDictionary =
    [NSMutableDictionary dictionaryWithDictionary:@{@"op" : @"replace", @"path" : @"/instaTagProp", @"value" : self.properties}];
    NSLog(@"%@", @[bodyDictionary]);
    BOXAPIJSONPatchOperation *JSONoperation = [self JSONPatchOperationWithURL:URL HTTPMethod:BOXAPIHTTPMethodPUT queryStringParameters:nil bodyArray:@[bodyDictionary] JSONSuccessBlock:nil failureBlock:nil];
    
    return JSONoperation;
    
}

- (void)performRequestWithCompletion:(BOXMetadataBlock) completionBlock
{
    BOOL isMainThread = [NSThread isMainThread];
    BOXAPIJSONOperation *metadataOperation = (BOXAPIJSONPatchOperation *)self.operation;
    
    if (completionBlock) {
        metadataOperation.success = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSONDictionary) {
            BOXMetadata *metadata = [[BOXMetadata alloc] initWithJSON:JSONDictionary];
            [BOXDispatchHelper callCompletionBlock:^{
                completionBlock(metadata, nil);
            } onMainThread:isMainThread];
        };
        metadataOperation.failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary) {
            [BOXDispatchHelper callCompletionBlock:^{
                completionBlock(nil, error);
            } onMainThread:isMainThread];
        };
    }
    
    [self performRequest];
}

@end
