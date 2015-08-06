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


@class ODServiceInfo;

#import <Foundation/Foundation.h>

/**
 The `ODAccountSession` object is a property bag for storing information needed to make authentication requests
 @see https://dev.onedrive.com/auth/readme.htm
 */
@interface ODAccountSession : NSObject <NSCopying>

/**
 The access token for the user
*/
@property NSString *accessToken;

/**
 The time stamp indicating when the access token expires
 */
@property NSDate *expires;

/**
 The refreshed token to be used when refreshing the access token, this may be nil
 */
@property NSString *refreshToken;

/**
 The users accountId, this will be a unique string
 */
@property (readonly) NSString *accountId;

/**
 The ServiceInfo object to be used by the account session
 @see ODServiceInfo
 */
@property (readonly) ODServiceInfo *serviceInfo;

/**
 Creates an ODAccountSession
 @param accountId the accountId of the user, must not be nil
 @param accessToken the access token for the user, must not be nil
 @param expires the datetime stamp indicating when the token expires, must not be nil
 @param refreshToken the refresh token to be used to refresh the access token
 @param serviceInfo the serviceInfo object
 */
- (instancetype) initWithId:(NSString *)accountId
                accessToken:(NSString *)accessToken
                    expires:(NSDate *)expires
               refreshToken:(NSString *)refreshToken
                serviceInfo:(ODServiceInfo *)serviceInfo;

/**
 Creates an ODAccountSession from a dictionary
 @param dictionary a dictionary containing account session information, must not be nil
 @param serviceInfo the serviceInfo for the account session
 @see initWithId:token:expires:refresh:serviceInfo:
 @warning the dictionary must contain Strings for the following values:
 
 1. OD_AUTH_EXPIRES, ticks since 1970 represented as an NSString
 2. OD_AUTH_USER_ID, the accountId
 3. OD_AUTH_ACCESS_TOKEN, the access token

 It may also contain
 
 -  OD_AUTH_REFRESH_TOKEN, the refresh token to be used when the access token expires
 
 */
- (instancetype) initWithDictionary:(NSDictionary *)dictionary serviceInfo:(ODServiceInfo *)serviceInfo;

/**
 Creates an NSDictionary of the session containing all of the properties except the service info object
 @returns NSDictionary
 */
- (NSDictionary *)toDictionary;

/**
 The service info flags
 @returns NSDictionary of service info flags
 @see [ODServiceInfo flags]
 */
- (NSDictionary *)sessionFlags;

@end
