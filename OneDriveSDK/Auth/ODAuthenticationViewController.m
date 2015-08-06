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


#import "ODAuthenticationViewController.h"
#import "ODAuthHelper.h"
#import "ODAuthConstants.h"

@interface ODAuthenticationViewController() <UIWebViewDelegate>

@property UIWebView *webView;

@property NSURLRequest *initialRequest;

@property (strong, nonatomic) ODEndURLCompletion successCompletion;

@property (strong, nonatomic) NSURL *endURL;

@end

@implementation ODAuthenticationViewController

- (instancetype)initWithStartURL:(NSURL *)startURL
                          endURL:(NSURL *)endURL
                         success:(ODEndURLCompletion)sucessCompletion
{
    self = [super init];
    if (self){
        _endURL = endURL;
        _initialRequest = [NSURLRequest requestWithURL:startURL];
        _successCompletion = sucessCompletion;
        
    }
    return self;
}

- (void)cancel
{
    NSError *cancelError = [NSError errorWithDomain:OD_AUTH_ERROR_DOMAIN code:ODAuthCanceled userInfo:@{}];
    if (self.successCompletion){
        self.successCompletion(nil, cancelError);
    }
}

- (void)loadInitialRequest
{
    [self.webView loadRequest:self.initialRequest];
}

- (void)redirectWithStartURL:(NSURL *)startURL
                      endURL:(NSURL *)endURL
                      success:(ODEndURLCompletion)successCompletion
{
    self.endURL = endURL;
    self.successCompletion = successCompletion;
    self.initialRequest = [NSURLRequest requestWithURL:startURL];
    [self.webView loadRequest:self.initialRequest];
}

- (void)loadView
{
    self.webView = [[UIWebView alloc] init];
    [self.webView setScalesPageToFit:YES];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    self.view = self.webView;
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(cancel)];
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = cancel;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.webView loadRequest:self.initialRequest];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.webView stopLoading];
    self.webView.delegate = nil;
    [super viewWillDisappear:animated];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[request.URL absoluteString] hasPrefix:[self.endURL absoluteString]]){
        self.successCompletion(request.URL, nil);
        return NO;
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

@end
