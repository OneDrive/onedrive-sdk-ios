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

#import <Foundation/Foundation.h>
#import "ODAuthConstants.h"

NSString * const OD_AUTH_ERROR_DOMAIN = @"com.microsoft.onedrivesdk.autherror";
NSString * const OD_AUTH_ERROR_KEY = @"ODAuthErrorKey";

NSString * const OD_API_HEADER_AUTHORIZATION = @"Authorization";
NSString * const OD_API_HEADER_CONTENTTYPE = @"Content-Type";
NSString * const OD_API_HEADER_CONTENTTYPE_FORMENCODED = @"application/x-www-form-urlencoded";
NSString * const OD_API_HEADER_APPLICATION_JSON = @"application/json";
NSString * const OD_API_HEADER_ACCEPT = @"accept";

NSString * const OD_AUTH_ACCESS_TOKEN = @"access_token";
NSString * const OD_AUTH_CODE = @"code";
NSString * const OD_AUTH_CLIENTID = @"client_id";
NSString * const OD_AUTH_EXPIRES = @"expires_in";
NSString * const OD_AUTH_GRANT_TYPE = @"grant_type";
NSString * const OD_AUTH_GRANT_TYPE_AUTHCODE = @"authorization_code";
NSString * const OD_AUTH_REDIRECT_URI = @"redirect_uri";
NSString * const OD_AUTH_REFRESH_TOKEN = @"refresh_token";
NSString * const OD_AUTH_RESPONSE_TYPE = @"response_type";
NSString * const OD_AUTH_SCOPE = @"scope";
NSString * const OD_AUTH_TOKEN = @"token";
NSString * const OD_AUTH_SECRET = @"client_secret";
NSString * const OD_AUTH_USER_ID = @"user_id";
NSString * const OD_AUTH_TOKEN_ID = @"id_token";
NSString * const OD_AUTH_USER_NAME = @"username";
NSString * const OD_AUTH_USER_EMAIL = @"user_email";

NSString * const OD_DISCOVERY_AUTH_SERVICE = @"authorization_service";
NSString * const OD_DISCOVERY_TOKEN_SERVICE = @"token_service";
NSString * const OD_DISCOVERY_RESROUCE = @"discovery_resource";
NSString * const OD_DISCOVERY_SERVICE = @"discovery_service";
NSString * const OD_DISCOVERY_ACCOUNT_TYPE = @"account_type";

NSString * const MSAEndpointHost = @"login.live.com";
NSString * const MSAAuthURL = @"https://login.live.com/oauth20_authorize.srf";
NSString * const MSATokenURL = @"https://login.live.com/oauth20_token.srf";
NSString * const MSARedirectURL = @"https://login.live.com/oauth20_desktop.srf";
NSString * const ODLocalRedirectURL = @"https://localhost:5000";
NSString * const MSALogOutURL = @"https://login.live.com/oauth20_logout.srf";

NSString * const OD_microsoftAccounnt_ENDPOINT = @"https://api.onedrive.com/v1.0";