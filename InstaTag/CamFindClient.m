//
//  CamFindClient.m
//  InstaTag
//
//  Created by Ken Szubzda on 3/27/15.
//  Copyright (c) 2015 OkStupid. All rights reserved.
//

#import "CamFindClient.h"
#import <UNIRest.h>

@implementation CamFindClient

- (void)imageRequestWithURL:(NSURL *)url completion:(void (^)(NSString *token, NSError *error))completion {
    // These code snippets use an open-source library. http://unirest.io/objective-c
    NSDictionary *headers = @{@"X-Mashape-Key": @"pKmiLBsqe2msh2MJPkwlz8WDB4OMp1WkSjxjsngJfwcQUfefOm"};
    NSDictionary *parameters = @{@"image_request[image]": url, @"image_request[language]": @"en", @"image_request[locale]": @"en_US"};
    [[UNIRest post:^(UNISimpleRequest *request) {
        [request setUrl:@"https://camfind.p.mashape.com/image_requests"];
        [request setHeaders:headers];
        [request setParameters:parameters];
    }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"Error uploading picture %@", error);
            completion(nil, error);
        } else {
            UNIJsonNode *body = response.body;
            NSString *token = body.JSONObject[@"token"];
            completion(token, nil);
        }
    }];
}

- (void)imageResponseWithToken:(NSString *)token completion:(void (^)(NSString *keyWords, NSError *error))completion {
    NSDictionary *headers = @{@"X-Mashape-Key": @"pKmiLBsqe2msh2MJPkwlz8WDB4OMp1WkSjxjsngJfwcQUfefOm", @"Accept": @"application/json"};
    [[UNIRest get:^(UNISimpleRequest *request) {
        [request setUrl:[NSString stringWithFormat:@"https://camfind.p.mashape.com/image_responses/%@", token]];
        [request setHeaders:headers];
    }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"Error getting picture response %@", error);
            completion(nil, error);
        } else {
            UNIJsonNode *body = response.body;
            NSString *status = body.JSONObject[@"status"];
            if ([status isEqualToString:@"completed"]) {
                completion(body.JSONObject[@"name"], nil);
            } else {
                NSError *error = [[NSError alloc] initWithDomain:@"Image response error" code:200 userInfo:@{@"reason" : body.JSONObject[@"status"]}];
                completion(nil, error);
            }
        }
    }];
}

@end
