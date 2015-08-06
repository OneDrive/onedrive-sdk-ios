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


#import "ODAsyncURLSessionDataTask.h"
#import "ODURLSessionDataTask.h"
#import "ODURLSessionTask+Protected.h"
#import "ODClient.h"
#import "ODConstants.h"
#import "NSJSONSerialization+ResponseHelper.h"
#import "ODAsyncOperationStatus.h"

@interface ODAsyncURLSessionDataTask()

@property (strong) ODAsyncActionCompletion asyncActionCompletion;

@property (strong) NSMutableURLRequest *monitorRequest;

@end


@implementation ODAsyncURLSessionDataTask

- (instancetype)initWithRequest:(NSMutableURLRequest *)request client:(ODClient *)client completion:(ODAsyncActionCompletion)completionHandler
{
    self = [super initWithRequest:request client:client];
    if (self){
        _asyncActionCompletion = completionHandler;
        _progress = [NSProgress progressWithTotalUnitCount:100];
    }
    return self;
}

- (NSURLSessionDataTask *)taskWithRequest:(NSMutableURLRequest *)request
{
    NSParameterAssert(request);
    
    [request setValue:ODHeaderRespondAsync forHTTPHeaderField:ODHeaderPrefer];
    [request setValue:ODHeaderApplicationJson forHTTPHeaderField:ODHeaderContentType];
    
    return [self.client.httpProvider dataTaskWithRequest:request
                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                      if (self.asyncActionCompletion){
                                          if (!error){
                                              // If there was a client error set it
                                              [NSJSONSerialization dictionaryWithResponse:response responseData:data error:&error];
                                          }
                                          [self onRequestStarted:response error:error completion:self.asyncActionCompletion];
                                      }
                                  }];
}

- (void)onRequestStarted:(NSURLResponse *)response
                   error:(NSError *)error
              completion:(void (^)(NSDictionary *response, ODAsyncOperationStatus *status, NSError *error))completion
{
    if (error){
        completion(nil, nil, error);
    }
    else {
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         NSInteger statusCode = httpResponse.statusCode;
        if (statusCode ==  ODAccepted){
            NSString *locationHeader = httpResponse.allHeaderFields[ODHeaderLocation];
            NSURL *monitorURL = [NSURL URLWithString:locationHeader];
            self.monitorRequest = [NSMutableURLRequest requestWithURL:monitorURL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:60];
            
            [self sendMonitorRequest:self.monitorRequest completion:completion];
        }
        else {
            // If the response was not ODAccepted and unknown error occurred
            completion(nil, nil, [NSError errorWithDomain:ODErrorDomain code:ODUnknownError userInfo:@{ODHttpFailingResponseKey : httpResponse}]);
        }
    }
}

- (void)sendMonitorRequest:(NSMutableURLRequest *)request completion:(void (^)(NSDictionary *response, ODAsyncOperationStatus *status, NSError *error))completion
{
    __block ODURLSessionDataTask *monitorRequest = [[ODURLSessionDataTask alloc] initWithRequest:request client:self.client completion:^(NSDictionary *response, NSError *error){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)monitorRequest.innerTask.response;
        [self onMonitorRequestResponse:response httpResponse:httpResponse error:error completion:completion];
    }];
    [monitorRequest execute];
}

- (void)onMonitorRequestResponse:(NSDictionary *)response
                    httpResponse:(NSHTTPURLResponse *)httpResponse
                           error:(NSError *)error
                      completion:(void (^)(NSDictionary *response, ODAsyncOperationStatus *status, NSError *error))completion
{
    ODAsyncOperationStatus *status = nil;
    if (!error){
        // When an async action returns it will redirect to the final location
        if (httpResponse.statusCode == ODOK){
            _state = ODTaskCompleted;
            self.progress.completedUnitCount = 100;
            completion(response, nil, nil);
        }
        else if (response && httpResponse.statusCode == ODAccepted){
            status = [[ODAsyncOperationStatus alloc] initWithDictionary:response];
            self.progress.completedUnitCount = status.percentageComplete;
            completion(nil, status, nil);
            // if the response was a valid status report send another one
            [self sendMonitorRequest:self.monitorRequest completion:completion];
        }
        else {
            NSError *unknownError = [NSError errorWithDomain:ODErrorDomain code:ODUnknownError userInfo:@{ODHttpFailingResponseKey : httpResponse }];
            completion(nil, nil, unknownError);
        }
    }
    else {
        completion(nil, nil, error);
    }
}

@end

