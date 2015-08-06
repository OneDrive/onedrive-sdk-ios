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


@class ODAccountSession, ADTokenCacheStoreItem, ODServiceInfo;

#import <Foundation/Foundation.h>

/**
 Static helper class to be used when making authentication requests
 */
@interface ODAuthHelper : NSObject

/**
 Creates a dictionary with the expected authentication values
 @param response the response of the authentication service
 @param data the data from the response from the authentication service
 @param error a reference to an error. It will be set if there was an error parsing the response
 @return A dictionary containing the expected authentication values
 @see https://dev.onedrive.com/auth/msa_oauth.htm for more info
 */
+ (NSDictionary *)sessionDictionaryWithResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError * __autoreleasing *)error;

/**
 Creates a URLRequest with the given information
 @param method the http method
 @param url the url of the request to be made
 @param params a dictionary of parameters to be send in the request
 @param headers a dictionary of http headers to be used
 @return an NSURLRequest object
 */
+ (NSURLRequest *)requestWithMethod:(NSString *)method URL:(NSURL *)url parameters:(NSDictionary *)params headers:(NSDictionary *)headers;

/**
 Appends the auth headers to a given request with the given token
 @param request the request to append the headers
 @param token the auth token needed for the request
 */
+ (void)appendAuthHeaders:(NSMutableURLRequest *)request token:(NSString *)token;

/**
 Constructs an ODAccountSession object with the response from the token/refresh request
 @param session the dictionary returned in the body of the response from the token/refresh request, must not be nil
 @param  serviceInfo the serviceInfo for the account session, must not be nil
 @return a constructed ODAccountSession object
 @see sessionDictionaryWithResponse:data:error:
 */
+ (ODAccountSession *)accountSessionWithResponse:(NSDictionary *)session
                                       serviceInfo:(ODServiceInfo *)serviceInfo;

/**
 Parses URL parameters from a given URL into a dictionary
 @param  url the URL to parse
 @return a dictionary of query parameters
 @see encodeQueryParameters:
 */
+ (NSDictionary *) decodeQueryParameters:(NSURL *)url;

/**
 Encodes query parameters into a string
 @param  params a dictionary of query parameters
 @return a string representation of query parameters
 @see decodeQueryParameters:
 */
+ (NSString *)encodeQueryParameters:(NSDictionary *)params;

/**
 Checks if the given ODAccountSession should be refreshed
 @param session the ODAccountSession to check
 @return YES if it should be refreshed, NO if it is still valid
 @see https://dev.onedrive.com/auth/msa_oauth.htm for a detailed description of the refresh flow
 */
+ (BOOL)shouldRefreshSession:(ODAccountSession *)session;

/**
 Parses the code from the redirected code flow url
 @param  url the url redirect to by the authentication service
 @return NSString the code from the redirect url
 @see https://dev.onedrive.com/auth/msa_oauth.htm
 */
+ (NSString *)codeFromCodeFlowRedirectURL:(NSURL *)url;

@end
