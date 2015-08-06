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


#import "ODKeychainWrapper.h"
#import "ODAccountSession.h"
#import "ADKeychainTokenCacheStore.h"
#import "ADTokenCacheStoreKey.h"
#import "ADTokenCacheStoreItem.h"
#import "ADUserInformation.h"
#import "ODAuthConstants.h"
#import "ODAADAccountBridge.h"
#import "ODServiceInfo.h"


@interface ODKeychainWrapper ()

@property ADKeychainTokenCacheStore *keychainStore;

@end

@implementation ODKeychainWrapper

- (instancetype)init
{
    self = [super init];
    if (self){
        _keychainStore = [[ADKeychainTokenCacheStore alloc] initWithGroup:nil];
    }
    return self;
}


- (void)addOrUpdateAccount:(ODAccountSession *)account;
{
    NSParameterAssert(account);
    
    ADTokenCacheStoreItem *accountItem = [ODAADAccountBridge cacheItemFromAccountSession:account];
    ADAuthenticationError *authError = nil;
    [self.keychainStore addOrUpdateItem:accountItem error:&authError];
}


- (ODAccountSession *)readFromKeychainWithAccountId:(NSString *)accountId serviceInfo:(ODServiceInfo *)serviceInfo
{
    NSParameterAssert(accountId);
    
    ADTokenCacheStoreKey *accountKey = [self cacheKeyFromAccountId:accountId serviceInfo:serviceInfo];
    ADTokenCacheStoreItem *item =[self.keychainStore getItemWithKey:accountKey userId:accountId error:nil];
    ODAccountSession *session = nil;
    if (item){
        session = [ODAADAccountBridge accountSessionFromCacheItem:item serviceInfo:serviceInfo];
    }
    return session;
}


- (void)removeAccountFormKeychain:(ODAccountSession *)account
{
    NSParameterAssert(account);
    
    ADTokenCacheStoreItem *accountItem = [ODAADAccountBridge cacheItemFromAccountSession:account];
    ADTokenCacheStoreKey *key = [self cacheKeyFromAccountId:account.accountId serviceInfo:account.serviceInfo];
    [self.keychainStore removeItemWithKey:key userId:accountItem.userInformation.userId error:nil];
}

- (ADTokenCacheStoreKey *)cacheKeyFromAccountId:(NSString*)accountId serviceInfo:(ODServiceInfo *)serviceInfo
{
    NSParameterAssert(accountId);
    
    return [ADTokenCacheStoreKey keyWithAuthority:serviceInfo.authorityURL resource:serviceInfo.resourceId clientId:serviceInfo.appId error:nil];
}

@end
