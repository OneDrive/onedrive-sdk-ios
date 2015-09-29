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

#import "ODClient+DefaultConfiguration.h"
#import "ODAppConfiguration+DefaultConfiguration.h"
#import "ODAccountSession.h"
#import "ODAuthProvider.h"

@implementation ODClient (DefaultConfiguration)

+ (void)clientWithCompletion:(ODClientAuthenticationCompletion)completion
{
    NSParameterAssert(completion);
    
    ODClient *client = [ODClient loadCurrentClient];
    if (client){
        completion(client, nil);
    }
    else{
        [ODClient authenticatedClientWithCompletion:completion];
    }
}

+ (void)authenticatedClientWithCompletion:(ODClientAuthenticationCompletion)completion
{
    [ODClient authenticatedClientWithAppConfig:[ODAppConfiguration defaultConfiguration] completion:completion];
}

+ (void)setCurrentClient:(ODClient *)client
{
    ODAccountSession *currentSession = nil;
    id <ODLogger> logger = client.logger;
    id <ODAccountStore> accountStore = [ODAppConfiguration defaultConfiguration].accountStore;
    if ([client.authProvider respondsToSelector:@selector(accountSession)]){
        currentSession = [client.authProvider accountSession];
    }
    else{
        [logger logWithLevel:ODLogWarn message:@"Auth provider doesn't respond to accountSession"];
    }
    if (currentSession && accountStore){
        [accountStore storeCurrentAccount:currentSession];
        [logger logWithLevel:ODLogInfo message:@"Setting %@ as the current session", currentSession.accountId];
    }
    else {
        [logger logWithLevel:ODLogWarn message:@"No account store or account session"];
    }
}

+ (ODClient *)loadCurrentClient
{
    return [ODClient currentClientWithAppConfig:[ODAppConfiguration defaultConfiguration]];
}

+ (ODClient *)loadClientWithAccountId:(NSString *)accountId
{
    __block ODClient *foundClient = nil;
    [[ODClient loadClients] enumerateObjectsUsingBlock:^(ODClient *client, NSUInteger index, BOOL *stop){
        if ([client.accountId isEqualToString:accountId]){
            foundClient = client;
            *stop = YES;
        }
    }];
    return foundClient;
}

+ (NSArray *)loadClients
{
    return [ODClient clientsFromAppConfig:[ODAppConfiguration defaultConfiguration]];
}


+ (void)setMicrosoftAccountAppId:(NSString *)microsoftAccounntAppId
                          scopes:(NSArray *)microsoftAccounntScopes
                           flags:(NSDictionary *)microsoftAccounntFlags
{
    NSParameterAssert(microsoftAccounntAppId);
    NSParameterAssert(microsoftAccounntScopes);
    
    ODAppConfiguration *defaultConfig = [ODAppConfiguration defaultConfiguration];
    defaultConfig.microsoftAccountAppId = microsoftAccounntAppId;
    defaultConfig.microsoftAccountScopes = microsoftAccounntScopes;
    defaultConfig.microsoftAccountFlags = microsoftAccounntFlags;
}

+ (void)setMicrosoftAccountAppId:(NSString *)microsoftAccounntAppId scopes:(NSArray *)microsoftAccounntScopes
{
    [ODClient setMicrosoftAccountAppId:microsoftAccounntAppId scopes:microsoftAccounntScopes flags:nil];
}

+ (void)setActiveDirectoryAppId:(NSString *)activeDirectoryAppId
                         scopes:(NSArray *)activeDirectoryScopes
                    redirectURL:(NSString *)activeDirectoryRedirectURL
                          flags:(NSDictionary *)activeDirectoryFlags
{
    NSParameterAssert(activeDirectoryAppId);
    NSParameterAssert(activeDirectoryScopes);
    NSParameterAssert(activeDirectoryRedirectURL);
    
    ODAppConfiguration *defaultConfig = [ODAppConfiguration defaultConfiguration];
    defaultConfig.activeDirectoryAppId = activeDirectoryAppId;
    defaultConfig.activeDirectoryScopes = activeDirectoryScopes;
    defaultConfig.activeDirectoryRedirectURL = activeDirectoryRedirectURL;
    defaultConfig.activeDirectoryFlags = activeDirectoryFlags;
}

+ (void)setActiveDirectoryAppId:(NSString *)activeDirectoryAppId
                  scopes:(NSArray *)activeDirectoryScopes
             redirectURL:(NSString *)activeDirectoryRedirectURL
{
    [ODClient setActiveDirectoryAppId:activeDirectoryAppId scopes:activeDirectoryScopes redirectURL:activeDirectoryRedirectURL flags:nil];
}

+ (void)setMicrosoftAccountAppId:(NSString *)microsoftAccounntAppId
          microsoftAccountScopes:(NSArray *)microsoftAccounntScopes
           microsoftAccountFlags:(NSDictionary *)microsoftAccounntFlags
            activeDirectoryAppId:(NSString *)activeDirectoryAppId
           activeDirectoryScopes:(NSArray *)activeDirectoryScopes
      activeDirectoryRedirectURL:(NSString *)activeDirectoryRedirectURL
            activeDirectoryFlags:(NSDictionary *)activeDirectoryFlags
{
    [ODClient setMicrosoftAccountAppId:microsoftAccounntAppId scopes:microsoftAccounntScopes flags:microsoftAccounntFlags];
    [ODClient setActiveDirectoryAppId:activeDirectoryAppId scopes:activeDirectoryScopes redirectURL:activeDirectoryRedirectURL flags:activeDirectoryFlags];
}

+ (void)setAuthProvider:(id <ODAuthProvider>)authProvider
{
    [ODAppConfiguration defaultConfiguration].authProvider = authProvider;
}

+ (void)setAccountStore:(id <ODAccountStore>)accountStore
{
    [ODAppConfiguration defaultConfiguration].accountStore = accountStore;
}

+ (void)setHttpProvider:(id <ODHttpProvider>)httpProvider
{
    [ODAppConfiguration defaultConfiguration].httpProvider = httpProvider;
}

+ (void)setParentAuthController:(UIViewController *)parentAuthController
{
    [ODAppConfiguration defaultConfiguration].parentAuthController = parentAuthController;
}

+ (void)setLogger:(id <ODLogger>)logger
{
    [ODAppConfiguration defaultConfiguration].logger = logger;
}

+ (void)setDefaultLogLevel:(ODLogLevel)level
{
    [[ODAppConfiguration defaultConfiguration].logger setLogLevel:level];
}

- (void)setLogLevel:(ODLogLevel)level
{
    [self.logger setLogLevel:level];
}

- (NSString *)accountId
{
    return self.authProvider.accountSession.accountId;
}

@end
