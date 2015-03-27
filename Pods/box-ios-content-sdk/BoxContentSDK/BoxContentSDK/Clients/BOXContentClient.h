//
//  BOXClient.h
//  BoxContentSDK
//
//  Copyright (c) 2014 Box. All rights reserved.
//

#import "BOXOAuth2Session.h"

@class BOXAPIQueueManager;
@class BOXRequest;
@class BOXSharedLinkHeadersHelper;
@protocol BOXSharedLinkStorageProtocol;

@interface BOXContentClient : NSObject

/**
 *  Allows the SDK to associate shared links with Box Items.
 */
@property (nonatomic, readonly, strong) BOXSharedLinkHeadersHelper *sharedLinksHeaderHelper;

/**
 *  The SDK's OAuth2 session.
 */
@property (nonatomic, readonly, strong) BOXOAuth2Session *OAuth2Session;

/**
 *  The base URL for all API operations including OAuth2.
 */
@property (nonatomic, readwrite, strong) NSString *APIBaseURL;

/**
 *  The BoxContentSDK's queue manager. All API calls are scheduled by this queue manager. 
 *  The queueManager is shared with the OAuth2Session (for making authorization and refresh
 *  calls) and the filesManager and foldersManager (for making API calls).
 */
@property (nonatomic, readwrite, strong) BOXAPIQueueManager *queueManager;

/**
 *  The list of Box users that have established a session through the SDK.
 *
 *  @return array of BOXUserMini model objects
 */
+ (NSArray *)users;

/**
 *  The Box user associated with this SDK client. This will be nil if no user has been authenticated yet.
 */
@property (nonatomic, readonly, strong) BOXUserMini *user;

/**
 *  You may use this to retrieve a content client, only if your app allows for only one Box user to be authenticated at a time.
 *  If your app will support multiple Box users, use clientForUser: and clientForNewSession to retrieve content clients for each user.
 *  Treat this method as a singleton accessor.
 *
 *  @return An existing BOXContentClient if it already exists. Otherwise, a new BOXContentClient wil be created.
 */
+ (BOXContentClient *)defaultClient;

/**
 *  Get a BOXContentClient for a specific user that has an authenticated session. 
 *  You can obtain a list of users with through the 'users' method.
 *  NOTE: Unless you want to allow your app to manage multiple Box users at one time, it is simpler to use
 *  'defaultClient' instead of this method.
 *
 *  @param user A user with an existing session
 *
 *  @return BOXContentClient for the specified user
 */
+ (BOXContentClient *)clientForUser:(BOXUserMini *)user;

/**
 *  Get an unauthenticated BOXContentClient.
 *  NOTE: Unless you want to allow your app to manage multiple Box users at one time, it is simpler to use
 *  'defaultClient' instead of this method.
 *
 *  @return An unauthenticated BOXContentClient
 */
+ (BOXContentClient *)clientForNewSession;

/**
 * Client ID:
 * The client identifier described in [Section 2.2 of the OAuth2 spec](http://tools.ietf.org/html/rfc6749#section-2.2)
 * This is also known as an API key on Box. See the [Box OAuth2 documentation](http://developers.box.com/oauth/) for
 * information on where to find this value.
 *
 * Client Secret:
 * The client secret. This value is used during the authorization code grant and when refreshing tokens.
 * This value should be a secret. DO NOT publish this value.
 * See the [Box OAuth2 documentation](http://developers.box.com/oauth/) for
 * information on where to find this value.
 */
+ (void)setClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret;

/**
 *  Resource bundle for loading images, etc.
 *
 *  @return NSBundle
 */
+ (NSBundle *)resourcesBundle;

/** 
 *  Overides the default sharedLink delegate with the provided object.
 *  By default the SDK persists shared link information in memory only. Override this to implement your own custom persistence logic.
 *  @param delegate The object that will receive the BOXSharedLinkStorageProtocol delegate callbacks.
 **/ 
-(void)setSharedLinkStorageDelegate:(id <BOXSharedLinkStorageProtocol>)delegate;

@end
