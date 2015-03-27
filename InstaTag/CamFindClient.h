//
//  CamFindClient.h
//  InstaTag
//
//  Created by Ken Szubzda on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CamFindClient : NSObject
- (void)imageRequestWithURL:(NSURL *)url completion:(void (^)(NSString *token, NSError *error))completion;
- (void)imageResponseWithToken:(NSString *)token completion:(void (^)(NSString *keyWords, NSError *error))completion;
@end
