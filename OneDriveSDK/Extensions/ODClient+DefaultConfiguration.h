//  Copyright 2015 Microsoft Corporation
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


#import "ODClient.h"
#import "ODClient+Authentication.h"
#import "ODAccountStoreProtocol.h"

/**
 ## Default Application Configuration Notes
 @warning When using this category you must called one of the setAppId methods (described below) before you try and create a client object
 */
@interface ODClient (DefaultConfiguration)

/**
 The account Id of the user
 */
@property (readonly) NSString *accountId;

/**
 Loads the current client if one exists, if one doesn't it will pop UI and ask for login info
 @param completion the completion handler to be called when an authenticated client is created
 @see authenticatedClientWithCompletion: or loadCurrentClient:
 @warning to load a client from disk you must provide an accountStore @see ODAccountStoreProtocol.h the default store is the ODAccountStore object
 @warning This method may invoke UI, it will present a view controller on the root view controller unless one is specified in the default app configuration
 */
+ (void)clientWithCompletion:(ODClientAuthenticationCompletion)completion;

/**
 Creates and authenticates an ODClient object
 @param completion the completion handler to be called when authentication is completed
        the completion handler will be called with an ODClient object OR an NSError object one will always be nil
 @warning This method may invoke UI, it will present a view controller on the root view controller unless one is specified in the default app configuration
 */
+ (void)authenticatedClientWithCompletion:(ODClientAuthenticationCompletion)completion;

/**
 Sets the OneDrive microsoftAccounnt app information @see https://dev.onedrive.com/auth/msa_oauth.htm
 @param  microsoftAccounntAppId the application id, must not be nil
 @param  microsoftAccounntScopes the scopes to be used with authentication, must not be nil
 @param  microsoftAccounntFlags a user defined dictionary to be passed through to the client when authenticated with the OneDrive microsoftAccounnt authentication flow
 */
+ (void)setMicrosoftAccountAppId:(NSString *)microsoftAccounntAppId
                          scopes:(NSArray *)microsoftAccounntScopes
                           flags:(NSDictionary *)microsoftAccounntFlags;

/**
 Calls setmicrosoftAccounntAppId:scopes:flags: with no flags
 @param  microsoftAccounntAppId the application id, must not be nil
 @param  microsoftAccounntScopes the scopes to be used with authentication, must not be nil
 */
+ (void)setMicrosoftAccountAppId:(NSString *)microsoftAccounntAppId
                          scopes:(NSArray *)microsoftAccounntScopes;

/**
 Sets the OneDrive for Business app information
 @param  activeDirectoryAppId the application id, must not be nil
 @param  activeDirectoryScopes the scopes to be used with authentication, must not be nil
 @param  activeDirectoryRedirectURL the redirect url to be used with Azure Active Directory, must not be nil
 @param  activeDirectoryFlags a user defined dictionary to be passed through to the client when authenticated with the OneDrive for Business authentication flow
 @see https://dev.onedrive.com/auth/aad_oauth.htm
 */
+ (void)setActiveDirectoryAppId:(NSString *)activeDirectoryAppId
                         scopes:(NSArray *)activeDirectoryScopes
                    redirectURL:(NSString *)activeDirectoryRedirectURL
                          flags:(NSDictionary *)activeDirectoryFlags;

/**
 Calls the setBusinessAppId:scopes:redirectURL:flags: with nil flags
 @param  activeDirectoryAppId the application id, must not be nil
 @param  activeDirectoryScopes the scopes to be used with authentication, must not be nil;
 @param  activeDirectoryRedirectURL the redirect url to be used with Azure Active Directory, must not be nil
 */
+ (void)setActiveDirectoryAppId:(NSString *)activeDirectoryAppId
                         scopes:(NSArray *)activeDirectoryScopes
                    redirectURL:(NSString *)activeDirectoryRedirectURL;

/**
 Calls the above two methods to set both microsoftAccounnt and Business application info
 @param  microsoftAccounntAppId the application id, must not be nil
 @param  microsoftAccounntScopes the scopes to be used with authentication, must not be nil
 @param  microsoftAccounntFlags a user defined dictionary to be passed through to the client when authenticated with the OneDrive microsoftAccounnt authentication flow
 @param  activeDirectoryAppId the application id, must not be nil
 @param  activeDirectoryScopes the scopes to be used with authentication, must not be nil
 @param  activeDirectoryRedirectURL the redirect url to be used with Azure Active Directory , must not be nil
 @param  activeDirectoryFlags a user defined dictionary to be passed through to the client when authenticated with the OneDrive for Business authentication flow
 */
+ (void)setMicrosoftAccountAppId:(NSString *)microsoftAccounntAppId
          microsoftAccountScopes:(NSArray *)microsoftAccounntScopes
           microsoftAccountFlags:(NSDictionary *)microsoftAccounntFlags
           activeDirectoryAppId:(NSString *)activeDirectoryAppId
          activeDirectoryScopes:(NSArray *)activeDirectoryScopes
     activeDirectoryRedirectURL:(NSString *)activeDirectoryRedirectURL
           activeDirectoryFlags:(NSDictionary *)activeDirectoryFlags;

/**
 Sets the authentication provider
 @param authProvider the auth provider
 @see ODAuthProvider
 */
+ (void)setAuthProvider:(id <ODAuthProvider>)authProvider;

/**
 Sets the accountStore
 @param accountStore the accountStore
 @see ODAccountStoreProtocol
 */
+ (void)setAccountStore:(id <ODAccountStore>)accountStore;

/**
 Sets the httpProvider
 @see ODHttpProvider
 */
+ (void)setHttpProvider:(id <ODHttpProvider>)httpProvider;

/**
 Sets the parent parent view controller for the authentication view controller
 @param parentAuthController the parentViewController to set
 */
+ (void)setParentAuthController:(UIViewController *)parentAuthController;

/**
 Sets the default logger
 @param logger the logger to set
 @see ODLogger
 */
+ (void)setLogger:(id <ODLogger>)logger;

/**
 Loads the current client if there is one
 @return the current client
 @return nil if there is no current client
 @warning you must provide an ODAccountStore to read from using setAccountStore if you choose not to use the default store
 */
+ (ODClient *)loadCurrentClient;

/**
 Sets the current client
 @param client the client to set
 */
+ (void)setCurrentClient:(ODClient *)client;

/**
 Loads all of the clients if they exists
 @return an array of clients, may be empty if there are no clients
 @warning you must provide an ODAccountStore to read from using setAccountStore if you choose not use the default store
 */
+ (NSArray *)loadClients;

/**
 Loads the `ODClient` for the given account id
 */
+ (ODClient *)loadClientWithAccountId:(NSString *)accountId;

/**
 Sets the log level for the clients logger
 @param level the level of the logger
 */
- (void)setLogLevel:(ODLogLevel)level;

@end
