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


#import "ODPasswordAuthChallengeDelegate.h"
#import <UIKit/UIKit.h>

@interface ODPasswordAuthChallengeDelegate ()

@property (nonatomic) NSURLCredentialPersistence persistence;

@end

@implementation ODPasswordAuthChallengeDelegate

+ (ODPasswordAuthChallengeDelegate*)delegateWithPersistence:(NSURLCredentialPersistence)persistence {
    return [[ODPasswordAuthChallengeDelegate alloc] initWithPersistence:persistence];
}

- (id)initWithPersistence:(NSURLCredentialPersistence)persistence {
    if (self = [super init]) {
        self.persistence = persistence;
    }
    return self;
}

- (void)signOutWithCompletion:(void (^)(NSError *))completionHandler {
    NSDictionary *credentials = [[NSURLCredentialStorage sharedCredentialStorage] allCredentials];
    [credentials enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        for (NSURLCredential *cred in [obj allValues]) {
            [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:cred forProtectionSpace:key options:@{NSURLCredentialStorageRemoveSynchronizableCredentials:@YES}];
        }
    }];
    
    completionHandler(nil);
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    NSString *authMethod = [[challenge protectionSpace] authenticationMethod];
    if (![authMethod isEqualToString:NSURLAuthenticationMethodNTLM]) {
        NSLog(@"WARNING: Network auth challenge was not NTLM as expected, cancelling request.");
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        return;
    }
    
    NSURLCredential *credential = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:challenge.protectionSpace];
    if (!credential)
    {
        [self promptForCredentialsWithCompletion:^(NSString *username, NSString *pass)
        {
            NSURLCredential *credential = [NSURLCredential credentialWithUser:username password:pass persistence:self.persistence];
            [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential forProtectionSpace:challenge.protectionSpace];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }];
    }
    else
    {
        if (challenge.previousFailureCount < 3) {
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
        else {
            // This credential is no good, remove it.
            NSLog(@"Credential is invalid and is being removed from credential store: {%@}", credential.user);
            
            [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:credential forProtectionSpace:challenge.protectionSpace];
            credential = nil;
            
            [self displayAlertWithTitle:@"Invalid Credentials" message:@"The provided domain/username and password are invalid." completion:^{
                completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
            }];
        }
    }
}

- (void)promptForCredentialsWithCompletion:(void(^)(NSString *username, NSString *pass))completion
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Login"
                                                                   message:@"Enter User Credentials"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        NSString *username = alert.textFields[0].text;
                                        NSString *pass = alert.textFields[1].text;
                                        completion(username, pass);
                                    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"DOMAIN\\username";
        textField.secureTextEntry = NO;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"password";
        textField.secureTextEntry = YES;
    }];
    [alert addAction:defaultAction];
    
    dispatch_async (dispatch_get_main_queue(), ^{
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
    });
}

- (void)displayAlertWithTitle:(NSString*)title message:(NSString*)message completion:(void(^)())completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completion();
    }];
    [alert addAction:okAction];
    
    dispatch_async (dispatch_get_main_queue(), ^{
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
    });
}

@end
