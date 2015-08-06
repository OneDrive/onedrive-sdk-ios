//
//  ODAADAccountBridge.h
//  OneDriveSDK
//
//  Created by Ace Levenberg on 7/6/15.
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

@class ADTokenCacheStoreItem, ODAccountSession, ODServiceInfo;

#import <Foundation/Foundation.h>

@interface ODAADAccountBridge : NSObject

/**
 *  Converts an ODAccountSession to an ADTokenCacheStoreItem for use with ADAL
 *  @param  account the account session to convert
 *  @warning account must not be nil
 *  @return ADTokenCacheStoreItem an equivalent representation for use with ADAL
 *  @see accountSessionFromCacheItem:ServiceInfo:
 */
+ (ADTokenCacheStoreItem *)cacheItemFromAccountSession:(ODAccountSession *)account;

/**
 *  Converts an ADTokenCacheStoreItem to an ODAccountSession
 *  @param  cacheStoreItem ADAL cache item to be used to convert
 *  @param serviceInfo the service info for the ODAccountSession
 *  @warning service info and cacheStoreItem must not be nil
 *  @return ODAccountSession the converted account session
 */
+ (ODAccountSession *)accountSessionFromCacheItem:(ADTokenCacheStoreItem *)cacheStoreItem serviceInfo:(ODServiceInfo *)serviceInfo;

@end
