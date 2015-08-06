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


#import "ODTestCase.h"
#import "ODKeyChainWrapper.h"
#import "ODAccountStore.h"
#import "ODAccountSession.h"
#import "ODServiceInfo.h"

@interface ODAccountStore()

@property ODAccountSession *currentAccountSession;

@property NSMutableDictionary *accountSessions;

- (void)storeAccounts;

@end


@interface MockODKeyChainWrapper : ODKeychainWrapper

@property NSMutableDictionary *mockDictionary;

@end

@implementation MockODKeyChainWrapper


- (void)addOrUpdateAccount:(ODAccountSession *)account
{
    self.mockDictionary[account.accountId] = account;
}

- (ODAccountSession *)readFromKeychainWithAccountId:(NSString *)accountId serviceInfo:(ODServiceInfo *)serviceInfo
{
    return self.mockDictionary[accountId];
}

- (void)removeAccountFormKeychain:(ODAccountSession*)account
{
    [self.mockDictionary removeObjectForKey:account.accountId];
}

@end

@interface ODAccountStoreTests : ODTestCase

@property MockODKeyChainWrapper *mockWrapper;

@property ODAccountStore *accountStore;

@property ODAccountSession *accountSession;

@property NSString *accountId;

@property NSString *appId;

@property NSString *token;

@property NSDate *expires;

@property id mockServiceInfo;

@end

@implementation ODAccountStoreTests

- (void)setUp {
    [super setUp];
    self.mockWrapper =[[MockODKeyChainWrapper alloc] init];
    self.accountStore = [[ODAccountStore alloc] initWithKeychainWrapper:self.mockWrapper];
    self.accountId = @"foo";
    self.appId = @"bar";
    self.token = @"baz";
    self.expires = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    self.mockServiceInfo = OCMStrictClassMock([ODServiceInfo class]);
    self.accountSession = [[ODAccountSession alloc] initWithId:self.accountId accessToken:self.token expires:self.expires refreshToken:nil serviceInfo:self.mockServiceInfo];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLoadCurrentAccountNoStoredAccount{
     __block ODAccountStore *mockAccountStore = OCMPartialMock(self.accountStore);
    
    OCMExpect([mockAccountStore loadAccounts]);
    XCTAssertNil([mockAccountStore loadCurrentAccount]);
    OCMVerify(mockAccountStore);
}

- (void)testLoadCurrentAccountNoAccount{
    __block ODAccountStore *mockAccountStore = OCMPartialMock(self.accountStore);
    
    OCMStub([mockAccountStore loadAccounts])
    .andDo(^(NSInvocation *invocation){
        mockAccountStore.currentAccountSession = self.accountSession;
    });
    
    ODAccountSession *returnedSession = [mockAccountStore loadCurrentAccount];
    [self assertSession:returnedSession isEqual:self.accountSession];
}

- (void)testLoadCurrentAccountHasCurrentAccount{
    self.accountStore.currentAccountSession = self.accountSession;
    ODAccountSession *returnedSession = [self.accountStore loadCurrentAccount];
    
    [self assertSession:returnedSession isEqual:self.accountSession];
}

- (void)testLoadAccountsNoAccounts{
    [self loadAccountsWithAccountIds:nil mockKeyChainDictionary:nil];
    XCTAssertNil(self.accountStore.currentAccountSession);
}

- (void)testLoadAccountsNoCurrentAccount{
    NSString *accountId = [NSString stringWithFormat:@"%@_%@", self.accountSession.accountId, @"bar"];
    ODAccountSession *secondAccount = [[ODAccountSession alloc] initWithId:accountId
                                                                         accessToken:self.token
                                                                       expires:self.expires
                                                                       refreshToken:nil
                                                                   serviceInfo:self.mockServiceInfo];
    NSDictionary *mockKeyChain = @{ self.accountSession.accountId : self.accountSession, secondAccount.accountId : secondAccount };
    NSDictionary *accounts = @{self.accountSession.accountId : self.mockServiceInfo , secondAccount.accountId : self.mockServiceInfo };
    NSDictionary *accountIdDictionary = @{ @"accountSessions" : accounts };
    
    [self loadAccountsWithAccountIds:accountIdDictionary mockKeyChainDictionary:mockKeyChain];
    
    XCTAssertNil(self.accountStore.currentAccountSession);
}

- (void)testLoadAccountWithCurrent{
     NSString *accountId = [NSString stringWithFormat:@"%@_%@", self.accountSession.accountId, @"bar"];
    ODAccountSession *secondAccount = [[ODAccountSession alloc] initWithId:accountId
                                                                         accessToken:self.token
                                                                       expires:self.expires
                                                                       refreshToken:nil
                                                                   serviceInfo:self.mockServiceInfo];
    
    NSDictionary *mockKeyChain = @{ self.accountSession.accountId : self.accountSession, secondAccount.accountId : secondAccount };
    NSDictionary *accounts = @{self.accountSession.accountId : self.mockServiceInfo, secondAccount.accountId : self.mockServiceInfo };
    NSDictionary *accountIdDictionary = @{ @"currentSession" : self.accountId ,@"accountSessions" : accounts};
    
    [self loadAccountsWithAccountIds:accountIdDictionary mockKeyChainDictionary:mockKeyChain];
    
    XCTAssertNotNil(self.accountStore.currentAccountSession);
    XCTAssertEqualObjects(self.accountStore.currentAccountSession.accountId, self.accountId);
}

- (void)testStoreAccountNilAccount{
    XCTAssertThrows([self.accountStore storeAccount:nil]);
}

- (void)testStoreAccountWithValidAccount{
    ODAccountStore *mockStore = OCMPartialMock(self.accountStore);
    OCMStub([mockStore storeAccounts]);
    [mockStore storeAccount:self.accountSession];
    OCMVerify([mockStore storeAccounts]);
    XCTAssertNotNil(mockStore.accountSessions[self.accountSession.accountId]);
}

- (void)testStoreCurrentAccountWithValidAccount{
    ODAccountStore *mockStore = OCMPartialMock(self.accountStore);
    OCMStub([mockStore storeAccounts]);
    [mockStore storeCurrentAccount:self.accountSession];
    OCMVerify([mockStore storeAccounts]);
    XCTAssertNotNil(mockStore.currentAccountSession);
    XCTAssertNotNil(mockStore.accountSessions[self.accountSession.accountId]);
}

- (void)testDeleteAccountNilAccount{
    XCTAssertThrows([self.accountStore deleteAccount:nil]);
}

- (void)testDeleteAccountValidAccount{
    ODAccountStore *mockStore = OCMPartialMock(self.accountStore);
    mockStore.accountSessions = [NSMutableDictionary dictionaryWithObject:self.accountSession forKey:self.accountSession.accountId];
    OCMStub([mockStore storeAccounts]);
    
    [mockStore deleteAccount:self.accountSession];
    OCMVerify([mockStore storeAccounts]);
    
    XCTAssertNil(mockStore.accountSessions[self.accountSession.accountId]);
}

- (void)testDeleteCurrentAccount{
    ODAccountStore *mockStore = OCMPartialMock(self.accountStore);
    mockStore.accountSessions = [NSMutableDictionary dictionaryWithObject:self.accountSession forKey:self.accountSession.accountId];
    mockStore.currentAccountSession = self.accountSession;
    OCMStub([mockStore storeAccounts]);
    [mockStore deleteAccount:self.accountSession];
    
    OCMVerify([mockStore storeAccounts]);
    XCTAssertNil(mockStore.currentAccountSession);
    XCTAssertNil(mockStore.accountSessions[self.accountSession.accountId]);
}

- (void)teststoreAccountsWithCurrentAccount{
    self.accountStore.accountSessions = [NSMutableDictionary dictionaryWithObject:self.accountSession forKey:self.accountSession.accountId];
    self.accountStore.currentAccountSession = self.accountSession;
    id mockKeyChain = OCMPartialMock(self.mockWrapper);
    OCMExpect([mockKeyChain addOrUpdateAccount:self.accountSession]);
    id mockArchiver = OCMClassMock([NSKeyedArchiver class]);
    OCMExpect([mockArchiver archiveRootObject:[OCMArg any] toFile:[OCMArg any]]).andReturn(YES);
    
    [self.accountStore storeAccounts];
    OCMVerify([mockKeyChain addOrUpdateAccount:self.accountSession]);
    OCMVerify([mockArchiver archiveRootObject:[OCMArg any] toFile:[OCMArg any]]);
    [mockArchiver stopMocking];
}

/**
 * Calls loadAccounts with a mocked keychain wrapper and NSDictionary
 *  @param accountIds the Dictionary returned by dictionaryWithURL
 *  @param keyChainDictionary mock keychain as a dictionary
 *  @warning asserts the returned accounts contains the correct info (from accountIds)
 */
- (void)loadAccountsWithAccountIds:(NSDictionary *)accountIds mockKeyChainDictionary:(NSDictionary *)keyChainDictionary
{
    self.mockWrapper.mockDictionary = [keyChainDictionary mutableCopy];
    NSDictionary *accounts = accountIds[@"accountSessions"];
    id mockArchiver = [self mockArchiverWithDictionary:accountIds];
    NSArray *returnedAccounts = [self.accountStore loadAccounts];
    
    XCTAssertNotNil(returnedAccounts);
    //ignore the ServiceInfoObjects, they should always be from MockServiceInfo
    [self assertAccountArray:returnedAccounts expectedAccountIdArray:[accounts allKeys]];
    [mockArchiver stopMocking];
}

/**
 * mocks the ContentsOfURL dictionary class method
 *  @prams the dictionary to return
 *  @returns the mocked dictionary
 *  @warning you MUST call stopMocking on this object when you are done with it
 */
- (NSKeyedUnarchiver *)mockArchiverWithDictionary:(NSDictionary *)dictionary
{
    id mockArchiver = OCMStrictClassMock([NSKeyedUnarchiver class]);
    OCMStub(ClassMethod([mockArchiver unarchiveObjectWithFile:[OCMArg any]]))
    .andReturn(dictionary);
    return mockArchiver;
}

/**
 * asserts that the accountArray contains the same accounts as the accountIds
 *  @param accountArray the array of ODAccountSessions
 *  @param accountIds the array of accountIds
 *  @warning asserts if the arrays do not contain the same objects
 */
- (void)assertAccountArray:(NSArray *)accountArray expectedAccountIdArray:(NSArray *)accountIds
{
    XCTAssertTrue([accountArray count] == [accountIds count]);
    
    [accountArray enumerateObjectsUsingBlock:^(ODAccountSession *session, NSUInteger index, BOOL *stop){
        XCTAssertTrue([accountIds containsObject:session.accountId]);
    }];
}

/**
 * asserts that the first session is equal to the second session
 *  @param session the session to check
 *  @param expectedSession the expected session
 *  @warning this method asserts if the sessions are not equal
 */
- (void)assertSession:(ODAccountSession *)session isEqual:(ODAccountSession *)expectedSession
{
    NSDictionary *sessionDictionary = [session toDictionary];
    NSDictionary *expectedDictionary = [expectedSession toDictionary];
    [expectedDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop){
        XCTAssertEqualObjects(sessionDictionary[key], value);
    }];
}
@end
