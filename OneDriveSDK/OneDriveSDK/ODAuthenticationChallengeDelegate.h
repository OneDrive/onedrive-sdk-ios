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

/**
 Authentication challenge delegate for NTLM or other network authentication protocols. This essentially
 handles any [URLSession:didReceiveChallenge:completionHandler:] callbacks received by the ODHttpProvider.
 https://developer.apple.com/library/mac/documentation/Foundation/Reference/NSURLSessionDelegate_protocol/#//apple_ref/occ/intfm/NSURLSessionDelegate/URLSession:didReceiveChallenge:completionHandler:
 */
@protocol ODAuthenticationChallengeDelegate <NSObject>

/**
 Invoked when a request receives an authentication challenge. See [URLSession:didReceiveChallenge:completionHandler:] for more information.
 */
- (void)URLSession:(nonnull NSURLSession*)session didReceiveChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler;

/**
 Causes the delegate to forgets any cached credentials.
 @param completionHandler The completion handler to be called when sign out has completed.
 error should be non nil if there was no error, and should contain any error(s) that occurred.
 */
- (void) signOutWithCompletion:(void (^)(NSError *error))completionHandler;

@end
