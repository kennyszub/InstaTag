//
//  BOXClient+Authentication.m
//  BoxContentSDK
//
//  Created by Rico Yao on 11/12/14.
//  Copyright (c) 2014 Box. All rights reserved.
//

#import <objc/runtime.h>
#import "BOXContentClient+Authentication.h"
#import "BOXContentClient+User.h"
#import "BOXAuthorizationViewController.h"
#import "BoxUser.h"
#import "BOXSharedLinkHeadersHelper.h"

#import "BOXUserRequest.h"

#define keychainDefaultIdentifier @"BoxCredential"
#define keychainRefreshTokenKey @"refresh_token"
#define keychainAccessTokenKey @"access_token"
#define keychainAccessTokenExpirationKey @"access_token_expiration"

@interface BOXContentClient ()
@end

@implementation BOXContentClient (Authentication)

#pragma mark - Authentication

- (void)authenticateWithCompletionBlock:(void (^)(BOXUser *user, NSError *error))completionBlock cancelBlock:(void (^)(void))cancelBlock
{
    if (self.OAuth2Session.refreshToken.length > 0 && self.OAuth2Session.accessToken.length > 0) {
        BOXUserRequest *userRequest = [self currentUserRequest];
        [userRequest performRequestWithCompletion:^(BOXUser *user, NSError *error) {
            if (error) {
                [self showAuthenticationViewControllerWithCompletionBlock:completionBlock cancelBlock:cancelBlock];
            } else {
                completionBlock(user, nil);
            }
        }];
        
    } else {
        [self showAuthenticationViewControllerWithCompletionBlock:completionBlock cancelBlock:cancelBlock];
    }
}

- (void)logOut
{
    [self.sharedLinksHeaderHelper removeStoredInformationForUserWithID:self.user.modelID];
    [self.OAuth2Session revokeCredentials];
    [self.queueManager cancelAllOperations];
}

+ (void)logOutAll
{
    NSArray *users = [BOXContentClient users];
    for (BOXUser *user in users) {
        BOXContentClient *client = [BOXContentClient clientForUser:user];
        [client logOut];
    }
    [BOXOAuth2Session revokeAllCredentials];
}

#pragma mark - Private Helpers

- (void)showAuthenticationViewControllerWithCompletionBlock:(void (^)(BOXUser *user, NSError *error))completionBlock cancelBlock:(void (^)(void))cancelBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOXAuthorizationViewController *authorizationController = [[BOXAuthorizationViewController alloc] initWithSDKClient:self completionBlock:^(BOXAuthorizationViewController *authViewController, BOXUser *user, NSError *error) {
            [[authViewController navigationController] dismissViewControllerAnimated:YES completion:nil];
            if (completionBlock) {
                completionBlock(user, error);
            }
        } cancelBlock:^(BOXAuthorizationViewController *authViewController) {
            [[authViewController navigationController] dismissViewControllerAnimated:YES completion:nil];
            if (cancelBlock) {
                cancelBlock();
            }
        }];
        UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:authorizationController];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        // if there are presented view controllers, we need to present the auth controller on the topmost presented view controller
        UIViewController *viewControllerToPresentOn = rootViewController;
        while (viewControllerToPresentOn.presentedViewController) {
            viewControllerToPresentOn = viewControllerToPresentOn.presentedViewController;
        }
        [viewControllerToPresentOn presentViewController:navController animated:YES completion:nil];
    });
}

#pragma mark - Keychain

- (void)setKeychainIdentifierPrefix:(NSString *)keychainIdentifierPrefix
{
    [[self.OAuth2Session class] setKeychainIdentifierPrefix:keychainIdentifierPrefix];
}

- (void)setKeychainAccessGroup:(NSString *)keychainAccessGroup
{
    [[self.OAuth2Session class] setKeychainAccessGroup:keychainAccessGroup];
}

@end
