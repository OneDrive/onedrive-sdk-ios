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


#import "ODAccountStore.h"
#import "ODAccountSession.h"
#import "ODAuthConstants.h"

static const NSString *ODAccountStoreFileName = @"oneDriveAccountStore.plist";

static const NSString *ODCurrentSession = @"currentSession";

static const NSString *ODAccountSessions = @"accountSessions";

@interface ODAccountStore()

@property NSString *accountStorePath;

@property NSMutableDictionary *accountSessions;

@property ODAccountSession *currentAccountSession;

@property ODKeychainWrapper *keychainWrapper;

@end

@implementation ODAccountStore

+ (instancetype)defaultAccountStore
{
    static ODAccountStore *defaultStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStore = [[ODAccountStore alloc] initWithStoreLocation:[ODAccountStore defaultStoreLocation]];
    });
    return defaultStore;
}

+ (NSString *)defaultStoreLocation
{
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [documents stringByAppendingPathComponent:[ODAccountStoreFileName copy]];
}

- (instancetype)initWithStoreLocation:(NSString *)filePath
{
    ODKeychainWrapper *keychainWrapper = [[ODKeychainWrapper alloc] init];
    return [self initWithStoreLocation:filePath keychainWrapper:keychainWrapper logger:nil];
}

- (instancetype)initWithStoreLocation:(NSString *)filePath keychainWrapper:(ODKeychainWrapper *)keychain logger:(id<ODLogger>)logger
{
    self = [super init];
    if (self){
        _keychainWrapper = keychain;
        _accountStorePath = filePath;
        _accountSessions = [NSMutableDictionary dictionary];
        _logger = logger;
    }
    return self;
}

- (instancetype)initWithKeychainWrapper:(ODKeychainWrapper *)keychainWrapper
{
    return [self initWithStoreLocation:[ODAccountStore defaultStoreLocation] keychainWrapper:keychainWrapper logger:nil];
}

- (ODAccountSession*)loadCurrentAccount
{
    if (!self.currentAccountSession){
        [self loadAccounts];
    }
    ODAccountSession *session = nil;
    @synchronized(self.accountSessions){
        if (self.currentAccountSession){
            session = [self.currentAccountSession copy];
        }
    }
    return session;
}

- (NSArray *)loadAccounts
{
    __block NSArray *accounts = nil;
    @synchronized(self.accountSessions){
        NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:self.accountStorePath];
        NSString *currentAccountId = nil;
        self.accountSessions = [NSMutableDictionary dictionary];
        if (dictionary){
            [dictionary[ODAccountSessions] enumerateKeysAndObjectsUsingBlock:^(NSString *accountId, ODServiceInfo *serviceInfo, BOOL *stop){
                [self.logger logWithLevel:ODLogVerbose message:@"Read account : %@ from accountStore", accountId];
                if (self.keychainWrapper){
                    ODAccountSession *sessionToAdd = [self.keychainWrapper readFromKeychainWithAccountId:accountId serviceInfo:serviceInfo];
                    if (sessionToAdd){
                        self.accountSessions[accountId] = sessionToAdd;
                    }
                    else {
                        [self.logger logWithLevel:ODLogWarn message:@"Failed to read session %@ from keychain", accountId];
                    }
                }
            }];
            currentAccountId = dictionary[ODCurrentSession];
        }
        else{
            [self.logger logWithLevel:ODLogWarn message:@"Failed to read from file %@", self.accountStorePath];
        }
        if (currentAccountId){
            [self.logger logWithLevel:ODLogVerbose message:@"Loading %@ as current account", currentAccountId];
            ODAccountSession *currentSession = self.accountSessions[currentAccountId];
            if (currentSession){
                self.currentAccountSession = currentSession;
            }
            else {
                [self.logger logWithLevel:ODLogError message:@"Failed load to load %@ as current account", currentAccountId];
            }
        }
        accounts = [[self.accountSessions allValues] copy];
    }
    return accounts;
}

- (void)storeAccount:(ODAccountSession *)account
{
    NSParameterAssert(account);
    
    @synchronized(self.accountSessions){
        self.accountSessions[account.accountId] = account;
    }
    [self storeAccounts];
}

- (void)storeCurrentAccount:(ODAccountSession *)account
{
    NSParameterAssert(account);
    
    @synchronized(self.accountSessions){
        self.accountSessions[account.accountId] = account;
        self.currentAccountSession = self.accountSessions[account.accountId];
    }
    [self storeAccounts];
}

- (void)deleteAccount:(ODAccountSession *)account
{
    NSParameterAssert(account);
    
    [self.logger logWithLevel:ODLogVerbose message:@"Removing %@ from account store", account.accountId];
    
    @synchronized(self.accountSessions){
        if (self.currentAccountSession && [self.currentAccountSession.accountId isEqualToString:account.accountId]){
            self.currentAccountSession = nil;
        }
        if (self.accountSessions && self.accountSessions[account.accountId]){
            [self.accountSessions removeObjectForKey:account.accountId];
        }
        else{
            [self.logger logWithLevel:ODLogWarn message:@"Attempting to remove an account that doesn't exist"];
        }
    }
    [self.keychainWrapper removeAccountFormKeychain:account];
    [self storeAccounts];
}

- (void)storeAccounts
{
    NSParameterAssert(self.accountSessions);
    
    @synchronized(self.accountSessions){
       NSMutableDictionary *allAccounts = [NSMutableDictionary dictionary];
       NSMutableDictionary *accounts = [NSMutableDictionary dictionary];
       if (self.currentAccountSession){
           allAccounts[ODCurrentSession] = self.currentAccountSession.accountId;
           [self.logger logWithLevel:ODLogVerbose message:@"Storing %@ as the current account", self.currentAccountSession.accountId];
       }
       [self.accountSessions enumerateKeysAndObjectsUsingBlock:^(NSString *id, ODAccountSession *session, BOOL *stop){
           [self.logger logWithLevel:ODLogVerbose message:@"Storing account %@", session.accountId];
           accounts[session.accountId] = session.serviceInfo;
           if (self.keychainWrapper){
               [self.keychainWrapper addOrUpdateAccount:session];
           }
       }];
        allAccounts[ODAccountSessions] = accounts;
        if (![NSKeyedArchiver archiveRootObject:allAccounts toFile:self.accountStorePath]){
            [self.logger logWithLevel:ODLogWarn message:@"Failed to archive accounts at %@", self.accountStorePath];
        }
    }
}

@end
