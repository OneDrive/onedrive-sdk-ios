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


#import <Foundation/Foundation.h>
#import <OneDriveSDK/OneDriveSDK.h>

typedef void (^shareCompletionHandler)(ODPermission *permission, NSError *error);
typedef void (^deleteItemCompletion)(NSError *error);

@interface ODXActionController : NSObject

+ (void)shareItem:(ODItem *)item
       withClient:(ODClient *)client
   viewController:(UIViewController *)viewController
       completion:(shareCompletionHandler)completion;

+ (void)createNewFolderWithParentId:(NSString*)parentId
                             client:(ODClient *)client
                     viewController:(UIViewController *)parentViewController
                         completion:(ODItemCompletionHandler)completion;

+ (void)deleteItem:(ODItem *)item
        withClient:(ODClient *)client
    viewController:(UIViewController *)parentViewcontroller
        completion:(deleteItemCompletion)completion;

+ (void) createLocalPlainTextFileWithParent:(ODItem *)parent
                                     client:(ODClient *)client
                             viewController:(UIViewController *)parentViewController;

+ (void) uploadNewFileWithParent:(ODItem *)parent
                          client:(ODClient *)client
                  viewController:(UIViewController *)parentViewController
                            path:(NSURL*)filePath
               completionHandler:(ODItemUploadCompletionHandler)completionHandler;

+ (void) updateFileContent:(ODItem *)item
            viewControlelr:(UIViewController *)parentViewController
                    client:(ODClient *)client
                      path:(NSURL*)filePath
                completion:(ODItemUploadCompletionHandler)completionHandler;

+ (void) moveItem:(ODItem *)item
       withClient:(ODClient *)client
   viewController:(UIViewController *)parentViewController
   completion:(void(^)(ODItem *response, NSError *error))completionHandler;

+ (void) copyItem:(ODItem *)item
       withClient:(ODClient *)client
   viewController:(UIViewController *)parentViewController
        completion:(void (^)(ODItem *item, ODAsyncOperationStatus *status, NSError *error))completionHandler;

+ (void)renameItem:(ODItem *)item
        withClient:(ODClient *)client
    viewController:(UIViewController *)parentViewController
   completion:(void(^)(ODItem *response, NSError *error))completionHandler;

@end
