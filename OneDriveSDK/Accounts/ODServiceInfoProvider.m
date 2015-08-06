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


#import "ODServiceInfoProvider.h"
#import "ODAuthenticationViewController.h"
#import "ODAuthHelper.h"
#import "ODAuthConstants.h"
#import "ODAppConfiguration.h"
#import "ODMSAServiceInfo.h"
#import "ODAADServiceInfo.h"

@interface ODServiceInfoProvider()

@property (strong, nonatomic) ODAppConfiguration *appConfig;

@property (strong, nonatomic) disambiguationCompletion completionHandler;

@end

@implementation ODServiceInfoProvider

- (void)getServiceInfoWithViewController:(UIViewController *)viewController
                    appConfiguration:(ODAppConfiguration *)appConfig
                          completion:(disambiguationCompletion)completionHandler;
{
    NSParameterAssert(viewController);
    NSParameterAssert(appConfig);
    
    self.appConfig = appConfig;
    self.completionHandler = completionHandler;
    
    NSURL *endURL = [NSURL URLWithString:@"https://localhost:777"];
    NSURL *startURL =[NSURL URLWithString:@"https://api.office.com/discovery/v2.0/me/FirstSignIn?redirect_uri=https://localhost:777&scope=MyFiles"];
    [self.appConfig.logger logWithLevel:ODLogDebug message:@"ServiceInfo provider starting discovery service with URL:", startURL];
        __block ODAuthenticationViewController *discoveryViewController =
        [[ODAuthenticationViewController alloc] initWithStartURL:startURL
                                                            endURL:endURL
                                                           success:^(NSURL *endURL, NSError *error){
                                                               if (!error){
                                                                   [self.appConfig.logger logWithLevel:ODLogDebug message:@"discovered account from response : %@", endURL];
                                                                   ODServiceInfo *serviceInfo = [self serviceInfoFromDiscoveryResponse:endURL appConfig:self.appConfig error:&error];
                                                                   if (error){
                                                                       [self.appConfig.logger logWithLevel:ODLogError message:@"Error parsing authentication service response %@", error];
                                                                   }
                                                                   self.completionHandler(discoveryViewController, serviceInfo, error);
                                                               }
                                                               else {
                                                                   self.completionHandler(discoveryViewController, nil, error);
                                                               }
                                                               
                                                           }];
        dispatch_async(dispatch_get_main_queue(), ^(){
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:discoveryViewController];
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            UIViewController *viewControllerToPresentOn = viewController;
            while (viewControllerToPresentOn.presentedViewController) {
                viewControllerToPresentOn = viewControllerToPresentOn.presentedViewController;
            }
            [viewControllerToPresentOn presentViewController:navController animated:YES  completion:^{
                [discoveryViewController loadInitialRequest];
            }];
    });
    
}

- (ODServiceInfo *)serviceInfoFromDiscoveryResponse:(NSURL *)url appConfig:(ODAppConfiguration *)appConfig error:(NSError * __autoreleasing *)error
{
    NSDictionary *queryParams = [ODAuthHelper decodeQueryParameters:url];
    NSString *authRequestString = queryParams[OD_DISCOVERY_AUTH_SERVICE];
    NSString *tokenService = queryParams[OD_DISCOVERY_TOKEN_SERVICE];
    NSString *discoverResource = queryParams[OD_DISCOVERY_RESROUCE];
    NSString *discoveryService = queryParams[OD_DISCOVERY_SERVICE];
    NSInteger accountType = [queryParams[OD_DISCOVERY_ACCOUNT_TYPE] integerValue];
    NSString *userEmail = queryParams[OD_AUTH_USER_EMAIL];
  
    ODServiceInfo *serviceInfo = [self serviceInfoWithType:accountType appConfig:appConfig];
    if (serviceInfo){
        serviceInfo.userEmail = userEmail;
        serviceInfo.authorityURL = authRequestString;
        serviceInfo.tokenURL = tokenService;
        serviceInfo.resourceId = ([discoverResource isEqualToString:@""]) ? serviceInfo.resourceId : discoverResource ;
        serviceInfo.discoveryServiceURL = [NSString stringWithFormat:@"%@/services", discoveryService];
    }
    else {
        if (error){
            *error = [NSError errorWithDomain:OD_AUTH_ERROR_DOMAIN code:ODInvalidAccountType userInfo:@{}];
        }
    }
    return serviceInfo;
}

- (ODServiceInfo *)serviceInfoWithType:(ODAccountType)type appConfig:(ODAppConfiguration *)appConfig
{
    ODServiceInfo *serviceInfo = nil;
    switch (type) {
        case ODADAccount:
            if (appConfig.activeDirectoryAppId){
                serviceInfo = [[ODAADServiceInfo alloc] initWithClientId:appConfig.activeDirectoryAppId
                                                                  scopes:appConfig.activeDirectoryScopes
                                                             redirectURL:appConfig.activeDirectoryRedirectURL
                                                                   flags:appConfig.activeDirectoryFlags];
            }
            break;
        case ODMSAAccount:
            if (appConfig.microsoftAccountAppId){
                serviceInfo = [[ODMSAServiceInfo alloc] initWithClientId:appConfig.microsoftAccountAppId
                                                                  scopes:appConfig.microsoftAccountScopes
                                                                   flags:appConfig.microsoftAccountFlags];
            }
            break;
    }
    return serviceInfo;
}

@end
