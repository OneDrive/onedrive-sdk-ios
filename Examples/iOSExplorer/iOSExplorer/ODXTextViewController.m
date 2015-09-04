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


#import "ODXTextViewController.h"
#import <OneDriveSDK/OneDriveSDK.h>
#import "ODXActionController.h"
#import "ODXProgressViewController.h"

@interface ODXTextViewController ()

@property (strong, nonatomic) void(^itemSaveCompletion)(ODItem *item);

@property ODXProgressViewController *progressController;

@end

@implementation ODXTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = (self.item) ? self.item.name : [self.filePath lastPathComponent];
    self.progressController = [[ODXProgressViewController alloc] initWithParentViewController:self];
    [self.textView setText:[NSString stringWithContentsOfURL:[NSURL fileURLWithPath:self.filePath] encoding:NSUTF8StringEncoding error:nil]];
    UIBarButtonItem *save= [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveFile)];
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = save;
    save.enabled = YES;
}

- (void)saveFile
{
    self.text = self.textView.text;
    NSError *error = nil;
    if (![[self.filePath pathExtension] isEqualToString:@"txt"]){
        self.filePath = [[self.filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"txt"];
    }
    [self.text writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error){
        if (self.parentItem && !self.item){
            ODItemContentRequest *contentRequest = [[[[self.client drive] items:self.parentItem.id] itemByPath:[self.filePath lastPathComponent]] contentRequest];
            
            [self uploadContentRequest:contentRequest fromFile:[NSURL fileURLWithPath:self.filePath]];
            
        }
        else if(self.item){
            ODItemContentRequest *contentRequest = [[[[self.client drive] items:self.item.id] contentRequest] ifMatch:self.item.cTag];
            [self uploadContentRequest:contentRequest fromFile:[NSURL fileURLWithPath:self.filePath]];
        }
    }
}

- (void)uploadContentRequest:(ODItemContentRequest*)contentRequest fromFile:(NSURL *)url
{
    ODURLSessionUploadTask *task = [contentRequest uploadFromFile:url completion:^(ODItem *item, NSError *error){
        [self showUploadResponse:item contentRequest:contentRequest fromUrl:url error:error];
    }];
    [self.progressController showProgressWithTitle:[NSString stringWithFormat:@"Uploading!"] progress:task.progress];
}

- (void)showUploadResponse:(ODItem *)item
            contentRequest:(ODItemContentRequest*)request
                   fromUrl:(NSURL *)fileURL
                     error:(NSError *)error
{
    [self.progressController hideProgress];
    UIAlertController *responseController = nil;
    if (error){
        responseController = [UIAlertController alertControllerWithTitle:@"Fialed To Upload item" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self uploadContentRequest:request fromFile:fileURL];
        }];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
        
        [responseController addAction:tryAgain];
        [responseController addAction:ok];
    }
    else {
        NSString *title = [NSString stringWithFormat:@"Uploaded %@ !", item.name];
        NSString *message = [NSString stringWithFormat:@"Item Id : %@", item.id];
        responseController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (self.itemSaveCompletion){
                self.itemSaveCompletion(item);
            }
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
        
        [responseController addAction:ok];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self presentViewController:responseController animated:YES completion:nil];
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
