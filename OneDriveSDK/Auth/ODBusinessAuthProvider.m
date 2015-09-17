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


#import "ODBusinessAuthProvider.h"
#import "ADAuthenticationContext.h"
#import "ODServiceInfo.h"
#import "ODAuthProvider+Protected.h"
#import "ODAuthHelper.h"
#import "ODAuthConstants.h"
#import "ODAccountSession.h"
#import "ODAADAccountBridge.h"

@interface ODBusinessAuthProvider(){
    @private
    ADAuthenticationContext *_authContext;
}

@end

@implementation ODBusinessAuthProvider

- (void) authenticateWithViewController:(UIViewController*)viewController completion:(void (^)(NSError *error))completionHandler
{
    self.authContext.parentController = viewController;
    [self.authContext acquireTokenWithResource:self.serviceInfo.resourceId
                                      clientId:self.serviceInfo.appId
                                   redirectUri:[NSURL URLWithString:self.serviceInfo.redirectURL]
                                promptBehavior:AD_PROMPT_ALWAYS
                                        userId:self.serviceInfo.userEmail
                          extraQueryParameters:nil
                               completionBlock:^(ADAuthenticationResult *result){
                              if (result.status == AD_SUCCEEDED){
                                  // If the resourceId being used is for the discovery service
                                  if ([self.serviceInfo.discoveryServiceURL containsString:self.serviceInfo.resourceId]){
                                      // Find the resourceIds needed
                                      [self discoverResourceWithAuthResult:result completion:^(NSString *resourceIds, NSError *error){
                                          //Refresh the token with the correct resource Ids
                                          if (result.tokenCacheStoreItem.refreshToken){
                                              [self.authContext acquireTokenByRefreshToken:result.tokenCacheStoreItem.refreshToken clientId:self.serviceInfo.appId resource:resourceIds completionBlock:^(ADAuthenticationResult *innerResult){
                                                  if (innerResult.status == AD_SUCCEEDED) {
                                                      innerResult.tokenCacheStoreItem.userInformation = result.tokenCacheStoreItem.userInformation;
                                                      
                                                      // the refresh response doesn't contain the user information so we must set it from the previous response
                                                      self.serviceInfo.resourceId = resourceIds;
                                                      [self setAccountSessionWithAuthResult:innerResult];
                                                      completionHandler(nil);
                                                  }
                                                  else {
                                                      completionHandler(innerResult.error);
                                                  }
                                              }];
                                          }
                                          else {
                                              NSError *error = [NSError errorWithDomain:OD_AUTH_ERROR_DOMAIN
                                                                                   code:ODServiceError
                                                                               userInfo:@{
                                                                                          NSLocalizedDescriptionKey : @"There was a problem logging you in",
                                                                                          OD_AUTH_ERROR_KEY : @" The auth result must have a refresh token" }];
                                              completionHandler(error);
                                          }
                                      }];
                                  }
                                  else {
                                      [self setAccountSessionWithAuthResult:result];
                                      completionHandler(nil);
                                  }
                              }
                              else {
                                  completionHandler(result.error);
                              }
    }];
}

- (void)setAccountSessionWithAuthResult:(ADAuthenticationResult *)result
{
    self.accountSession = [ODAADAccountBridge accountSessionFromCacheItem:result.tokenCacheStoreItem serviceInfo:self.serviceInfo];
    if (self.accountSession.refreshToken){
        [self.accountStore storeCurrentAccount:self.accountSession];
    }
}

-(void)discoverResourceWithAuthResult:(ADAuthenticationResult *)result completion:(void (^)(NSString *, NSError *))completion
{
    NSMutableURLRequest *discoveryRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.serviceInfo.discoveryServiceURL]];
    [ODAuthHelper appendAuthHeaders:discoveryRequest token:result.accessToken];
    [[self.httpProvider dataTaskWithRequest:discoveryRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
       if (!error){
           NSDictionary *responseObject = [ODAuthHelper sessionDictionaryWithResponse:response data:data error:&error];
           NSString *resourceIds = nil;
           if (responseObject){
               NSSet *capabilitySet = [self capabilitySetWithScopes:self.serviceInfo.scopes];
               resourceIds = [self resourceIdsWithCapabilities:capabilitySet discoveryResponse:responseObject];
           }
           completion(resourceIds, error);
        }
       else{
           completion(nil, error);
       }
    }] resume];
}

- (NSString *)resourceIdsWithCapabilities:(NSSet *)capabilities discoveryResponse:(NSDictionary *)discoveryResponse
{
    __block NSMutableArray *resourceIds = [NSMutableArray array];
    NSArray *values = discoveryResponse[@"value"];
    [values enumerateObjectsUsingBlock:^(NSDictionary *serviceResponse, NSUInteger index, BOOL *stop){
        if ([capabilities containsObject:serviceResponse[@"capability"]]){
            NSString *serviceResourceId = serviceResponse[@"serviceResourceId"];
            if (![resourceIds containsObject:serviceResourceId]){
                [resourceIds addObject:serviceResourceId];
            }
        }
    }];
    return [resourceIds componentsJoinedByString:@" "];
}

- (NSSet *)capabilitySetWithScopes:(NSArray *)scopes
{
    __block NSMutableSet *scopesSet = [NSMutableSet set];
    [self.serviceInfo.scopes enumerateObjectsUsingBlock:^(NSString *scope, NSUInteger index, BOOL *stop){
        // trim off the end part of the scopes if it exists
        // i.e. if the scope is MyFiles.readwrite we just want MyFiles
        NSRange prefixRange = [scope rangeOfString:@"."];
        NSString *capability = nil;
        if (prefixRange.location){
            capability = [scope substringToIndex:prefixRange.location];
        }
        else {
            capability = scope;
        }
        [scopesSet addObject:capability];
    }];
    return scopesSet;
}

- (void)refreshSession:(ODAccountSession *)session withCompletion:(void (^)(ODAccountSession *updatedSession, NSError *error))completionHandler
{
    [self.authContext acquireTokenByRefreshToken:session.refreshToken
                                        clientId:self.serviceInfo.appId
                                        resource:self.serviceInfo.resourceId
                                 completionBlock:^(ADAuthenticationResult *authResult){
                                     if (authResult.status == AD_SUCCEEDED){
                                         session.accessToken = authResult.accessToken;
                                         session.refreshToken = authResult.tokenCacheStoreItem.refreshToken;
                                         session.expires = authResult.tokenCacheStoreItem.expiresOn;
                                         completionHandler(session, nil);
                                     }
                                     else {
                                         completionHandler(nil, authResult.error);
                                     }
    }];
}

- (ADAuthenticationContext *)authContext
{
    if (!_authContext){
        _authContext = [ADAuthenticationContext authenticationContextWithAuthority:self.serviceInfo.authorityURL error:nil];
    }
    return _authContext;
}

- (NSURLRequest*)logoutRequest
{
    return nil;
}

@end
