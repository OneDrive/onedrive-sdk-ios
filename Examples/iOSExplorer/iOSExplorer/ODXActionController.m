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


#import "ODXActionController.h"
#import "ODXTextViewController.h"

@implementation ODXActionController

+ (void)shareItem:(ODItem *)item
       withClient:(ODClient *)client
   viewController:(UIViewController *)viewController
       completion:(shareCompletionHandler)completion
{
   UIAlertController *shareViewController = [ODXActionController shareControllerWithViewCompletion:^(UIAlertAction *action){
                                                             [[[[[client drive] items:item.id] createLinkWithType:@"view"] request] executeWithCompletion:completion];
                                                         }
                                                                                    editCompletion:^(UIAlertAction *action){
                                                             [[[[[client drive] items:item.id] createLinkWithType:@"edit"] request] executeWithCompletion:completion];
                                                         }];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [viewController presentViewController:shareViewController animated:YES completion:nil];
    });
}

+ (UIAlertController *)shareControllerWithViewCompletion:(void (^)(UIAlertAction *action))viewCompletion
                                          editCompletion:(void (^)(UIAlertAction *))editCompletion
{
    UIAlertController *shareController = [UIAlertController alertControllerWithTitle:@"What kind of Link?"
                                               message:nil
                                               preferredStyle:UIAlertControllerStyleAlert];
    
    shareController.title = @"What Kind of Link?";
    
    UIAlertAction *viewAction = [UIAlertAction actionWithTitle:@"View Only"
                                                         style:UIAlertActionStyleDefault
                                                       handler:viewCompletion];
    
    UIAlertAction *editAction = [UIAlertAction actionWithTitle:@"Edit"
                                                         style:UIAlertActionStyleDefault
                                                       handler:editCompletion];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action){}];
    [shareController addAction:viewAction];
    [shareController addAction:editAction];
    [shareController addAction:cancel];
    return shareController;
}

+ (void)createNewFolderWithParentId:(NSString*)parentId
                             client:(ODClient *)client
                     viewController:(UIViewController *)viewController
                         completion:(ODItemCompletionHandler)completion;
{
    UIAlertController *newFolder = [UIAlertController alertControllerWithTitle:@"Create New Folder" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [newFolder addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"New Folder";
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            UITextField *folderName =  newFolder.textFields.firstObject;
            ODItem *newFolder = [[ODItem alloc] initWithDictionary:@{[ODNameConflict rename].key : [ODNameConflict rename].value}];
            newFolder.name = folderName.text;
            newFolder.folder = [[ODFolder alloc] init];
            [[[[[client drive] items:parentId] children] request] addItem:newFolder withCompletion:completion];
        }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [newFolder addAction:ok];
    [newFolder addAction:cancel];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [viewController presentViewController:newFolder animated:YES completion:nil];
    });
}

+ (void)deleteItem:(ODItem *)item
        withClient:(ODClient *)client
    viewController:(UIViewController *)parentViewController
        completion:(deleteItemCompletion)completion;
{
    UIAlertController *deleteController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Are you sure you want to delete %@",item.name]
                                                                              message:@"This action is final"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [[[[client drive] items:item.id] requestWithOptions:@[[ODIfMatch entityTags:item.eTag]]] deleteWithCompletion:completion];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [deleteController addAction:deleteAction];
    [deleteController addAction:cancelAction];
   
    dispatch_async(dispatch_get_main_queue(), ^(){
        [parentViewController presentViewController:deleteController animated:YES completion:nil];
    });
}
                   

+ (void) createLocalPlainTextFileWithParent:(ODItem *)parent
                                     client:(ODClient *)client
                             viewController:(UIViewController *)parentViewController;
{
    UIAlertController *newFile = [UIAlertController alertControllerWithTitle:@"Create New Text file" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [newFile addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"NewFile";
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *fileName =  newFile.textFields.firstObject;
        NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSData *textFile = [@"Foo Bar Baz Qux" dataUsingEncoding:NSUTF8StringEncoding];
        NSString *filePath = [documentDirectory stringByAppendingPathComponent:fileName.text];
        
        [textFile writeToFile:filePath atomically:YES];
        ODXTextViewController *newController = [parentViewController.storyboard instantiateViewControllerWithIdentifier:@"FileViewController"];
        newController.filePath = filePath;
        newController.client = client;
        newController.parentItem = parent;
        dispatch_async(dispatch_get_main_queue(), ^(){
            [parentViewController.navigationController pushViewController:newController animated:YES];
        });
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [newFile addAction:ok];
    [newFile addAction:cancel];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [parentViewController presentViewController:newFile animated:YES completion:nil];
    });
}

+ (void) uploadNewFileWithParent:(ODItem *)parent
                          client:(ODClient *)client
                  viewController:(UIViewController *)parentViewController
                            path:(NSURL*)filePath
               completionHandler:(ODItemUploadCompletionHandler)completionHandler;
{
    NSString *fileName = [[filePath lastPathComponent] stringByRemovingPercentEncoding];
    if (![[fileName pathExtension] isEqualToString:@"txt"]){
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"txt"];
    }
    
    [ODXActionController uploadFileWithContentRequest:[[[[client drive] items:parent.id] itemByPath:fileName] contentRequest] fileURL:filePath completion:completionHandler];
}

+ (void) updateFileContent:(ODItem *)item
            viewControlelr:(UIViewController *)parentViewController
                    client:(ODClient *)client
                      path:(NSURL *)filePath
                completion:(ODItemUploadCompletionHandler)completionHandler;
{
    [ODXActionController uploadFileWithContentRequest:[[[client drive] items:item.id] contentRequestWithOptions:@[[ODIfMatch entityTags:item.cTag]]] fileURL:filePath completion:completionHandler];
}

+ (void)uploadFileWithContentRequest:(ODItemContentRequest*)contentRequest
                              fileURL:(NSURL*)fileURL
                           completion:(ODItemUploadCompletionHandler)completion
{
    [contentRequest uploadFromFile:fileURL completion:completion];
}

+ (void) moveItem:(ODItem *)item
       withClient:(ODClient *)client
   viewController:(UIViewController *)parentViewController
   completion:(void(^)(ODItem *response, NSError *error))completionHandler;
{
    
    UIAlertController *moveItemController = [UIAlertController alertControllerWithTitle:@"Move Item" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [moveItemController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Enter Path from root";
    }];
    
    UIAlertAction *moveAction= [UIAlertAction actionWithTitle:@"Move" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *textField = moveItemController.textFields.firstObject;
        NSString *servicePath = textField.text;
        NSString *fullPath = [NSString stringWithFormat:@"/drive/root:/%@", servicePath];
        ODItemReference *parentRef = [[ODItemReference alloc] init];
        parentRef.path = fullPath;
        ODItem *updatedItem = [[ODItem alloc] init];
        updatedItem.parentReference = parentRef;
        [[[[client drive] items:item.id] request] update:updatedItem withCompletion:completionHandler];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [moveItemController addAction:moveAction];
    [moveItemController addAction:cancelAction];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [parentViewController presentViewController:moveItemController animated:YES completion:nil];
    });
}

+ (void) copyItem:(ODItem *)item
       withClient:(ODClient *)client
   viewController:(UIViewController *)parentViewController
       completion:(void (^)(ODItem *item, ODAsyncOperationStatus *status, NSError *error))completionHandler;
{
    [ODXActionController copyItem:item withClient:client conflictBehaviour:nil viewController:parentViewController completion:completionHandler];
}

+ (void) copyItem:(ODItem *)item
       withClient:(ODClient *)client
conflictBehaviour:(ODNameConflict *)conflictBehaviour
   viewController:(UIViewController *)parentViewController
       completion:(void (^)(ODItem *item, ODAsyncOperationStatus *status, NSError *error))completionHandler;
{
    UIAlertController *copyItemController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@" Copy %@", item.name]
                                                                                message:nil
                                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    [copyItemController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Enter Path from root";
    }];
    
    UIAlertAction *moveAction= [UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *textField = copyItemController.textFields.firstObject;
        NSString *servicePath = textField.text;
        NSString *fullPath = [NSString stringWithFormat:@"/drive/root:/%@", servicePath];
        ODItemReference *parentRef = [[ODItemReference alloc] init];
        parentRef.path = fullPath;
        item.parentReference = parentRef;
        ODItemCopyRequest *copyRequest = [[[[client drive] items:item.id] copyWithName:item.name parentReference:parentRef] request];
        if (conflictBehaviour){
            copyRequest = [copyRequest nameConflict:conflictBehaviour];
        }
        [copyRequest executeWithCompletion:completionHandler];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [copyItemController addAction:moveAction];
    [copyItemController addAction:cancelAction];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [parentViewController presentViewController:copyItemController animated:YES completion:nil];
    });
}

+ (void)renameItem:(ODItem *)item
        withClient:(ODClient *)client
    viewController:(UIViewController *)parentViewController
   completion:(void(^)(ODItem *response, NSError *error))completionHandler
{
    UIAlertController *renameItemController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@" Rename %@", item.name]
                                                                                  message:nil
                                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    [renameItemController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Enter New Name";
    }];
    
    UIAlertAction *rename= [UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *textField = renameItemController.textFields.firstObject;
        NSString *newName = textField.text;
        ODItem *updatedItem= [[ODItem alloc] init];
        updatedItem.name = newName;
        [[[[client drive] items:item.id] request] update:updatedItem withCompletion:completionHandler];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [renameItemController addAction:rename];
    [renameItemController addAction:cancelAction];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [parentViewController presentViewController:renameItemController animated:YES completion:nil];
    });
    
}

@end
