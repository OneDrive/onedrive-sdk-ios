//
//  ODAADAccountBridge.m
//  OneDriveSDK
//
//  Created by Ace Levenberg on 7/6/15.
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

#import "ODAADAccountBridge.h"
#import "ADUserInformation.h"
#import "ADTokenCacheStoreItem.h"
#import "ODAccountSession.h"
#import "ODServiceInfo.h"

@implementation ODAADAccountBridge

+ (ADTokenCacheStoreItem *)cacheItemFromAccountSession:(ODAccountSession *)account
{
    NSParameterAssert(account);
    
    ADTokenCacheStoreItem *cacheItem = [[ADTokenCacheStoreItem alloc] init];
    cacheItem.clientId = account.serviceInfo.appId;
    cacheItem.authority = account.serviceInfo.authorityURL;
    cacheItem.resource = account.serviceInfo.resourceId;
    cacheItem.accessToken = account.accessToken;
    cacheItem.refreshToken = account.refreshToken;
    cacheItem.expiresOn = account.expires;
    cacheItem.userInformation = [ADUserInformation userInformationWithUserId:account.accountId error:nil];
    return cacheItem;
}

+ (ODAccountSession *)accountSessionFromCacheItem:(ADTokenCacheStoreItem *)cacheStoreItem serviceInfo:(ODServiceInfo *)serviceInfo
{
    NSParameterAssert(cacheStoreItem);
    
    return [[ODAccountSession alloc] initWithId:cacheStoreItem.userInformation.userId
                                            accessToken:cacheStoreItem.accessToken
                                          expires:cacheStoreItem.expiresOn
                                          refreshToken:cacheStoreItem.refreshToken
                                          serviceInfo:serviceInfo];
}

@end
