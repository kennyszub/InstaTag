//
//  BOXClient+Authentication.h
//  BoxContentSDK
//
//  Created by Rico Yao on 11/12/14.
//  Copyright (c) 2014 Box. All rights reserved.
//

#import "BOXContentClient.h"
#import <UIKit/UIKit.h>

@class BOXUser;

@interface BOXContentClient (Authentication)

/**
 *  Authenticate a user. If necessary, this will present a UIViewController to allow the user to enter their credentials.
 *  If a user is already authenticated, then a UIViewController will not be presented and the completionBlock will be called.
 *
 *  @param completionBlock Called when the authentication has completed.
 *  @param cancelBlock     Called if the user cancels the authentication process.
 */
- (void)authenticateWithCompletionBlock:(void (^)(BOXUser *user, NSError *error))completionBlock cancelBlock:(void (^)(void))cancelBlock;

/**
 *  Log out the user associated with this BOXContentClient. It is a good practice to call this when the user's session is no longer necessary.
 */
- (void)logOut;

/**
 *  Log out all users that have ever been authenticated.
 */
+ (void)logOutAll;

/**
 *  By default, the Content SDK stores some information in the keychain to persist the user's session with a default prefix.
 *  You can override this prefix.
 *
 *  @param keychainIdentifierPrefix prefix for keychain entries.
 */
- (void)setKeychainIdentifierPrefix:(NSString *)keychainIdentifierPrefix;

/**
 *  By default, the Content SDK stores some information in the keychain to persist the user's session with no access group defined.
 *  You may need to set this if you need to use the SDK in multiple processes (e.g. extensions)
 *
 *  @param keychainAccessGroup keychain access group
 */
- (void)setKeychainAccessGroup:(NSString *)keychainAccessGroup;

@end
