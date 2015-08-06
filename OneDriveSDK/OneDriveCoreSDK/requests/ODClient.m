//  Copyright 2015 Microsoft Corporation
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal 
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/ or sell
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
//
//  This file was generated and any changes will be overwritten.

#import "ODODataEntities.h"

/**
* The implementation file for type ODClient.
*/

@implementation ODClient


-(instancetype)initWithURL:(NSString *)url httpProvider:(id<ODHttpProvider>)httpProvider authProvider:(id<ODAuthProvider>)authProvider
{
    self = [super init];
    if (self){
        _baseURL = [NSURL URLWithString:url];
        _httpProvider = httpProvider;
        _authProvider = authProvider;
    }
    return self;
}

-(ODDrivesCollectionRequestBuilder *)drives
{
    return [[ODDrivesCollectionRequestBuilder alloc] initWithURL:[self.baseURL URLByAppendingPathComponent:@"drives"] 
                                                        client:self];
}

-(ODDriveRequestBuilder*)drives:(NSString*)drive
{
    return [[self drives] drive:drive];
}

-(ODSharesCollectionRequestBuilder *)shares
{
    return [[ODSharesCollectionRequestBuilder alloc] initWithURL:[self.baseURL URLByAppendingPathComponent:@"shares"] 
                                                        client:self];
}

-(ODShareRequestBuilder*)shares:(NSString*)share
{
    return [[self shares] share:share];
}


@end
