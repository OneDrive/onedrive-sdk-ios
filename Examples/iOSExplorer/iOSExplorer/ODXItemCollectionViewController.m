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

#import "ODXItemCollectionViewController.h"
#import "ODXTextViewController.h"
#import "ODXActionController.h"
#import "ODXProgressViewController.h"

@interface ODXItemCollectionViewController()

@property UIBarButtonItem *signIn;

@property NSMutableDictionary *thumbnails;

@property BOOL selection;

@property NSMutableArray *selectedItems;

@property UIRefreshControl *refreshControl;

@property UIBarButtonItem *actions;

@property ODXProgressViewController *progressController;

@end

static void *ProgressObserverContext = &ProgressObserverContext;

@implementation ODXItemCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.items = [NSMutableDictionary dictionary];
    self.itemsLookup = [NSMutableArray array];
    self.thumbnails = [NSMutableDictionary dictionary];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.storyBoardId = @"ItemViewController";
    self.progressController = [[ODXProgressViewController alloc] initWithParentViewController:self];
    
    [self.collectionView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.collectionView.alwaysBounceVertical = YES;
    
    self.actions = [[UIBarButtonItem alloc] initWithTitle:@"Actions" style:UIBarButtonItemStylePlain target:self action:@selector(didSelectActionButton:)];
    if (!self.client){
        self.client = [ODClient loadCurrentClient];
    }
    if (!self.currentItem){
        self.title = @"OneDrive";
    }
    
    self.signIn = [[UIBarButtonItem alloc] initWithTitle:@"Sign in" style:UIBarButtonItemStylePlain target:self action:@selector(signInAction)];
    self.navigationItem.rightBarButtonItem = self.signIn;
    if (self.client){
        self.navigationItem.rightBarButtonItem = self.actions;
        [self loadChildren];
    }
}

- (void)refresh
{
    [self loadChildren];
}

- (void)signInAction
{
    [ODClient authenticatedClientWithCompletion:^(ODClient *client, NSError *error){
        if (!error){
            self.client = client;
            [self loadChildren];
            dispatch_async(dispatch_get_main_queue(), ^(){
                self.navigationItem.rightBarButtonItem = self.actions;
            });
        }
        else{
            [self showErrorAlert:error];
        }
    }];
}

- (void)signOutAction
{
    [self.client signOutWithCompletion:^(NSError *signOutError){
        self.items = nil;
        self.items = [NSMutableDictionary dictionary];
        self.itemsLookup = nil;
        self.itemsLookup = [NSMutableArray array];
        self.client = nil;
        self.currentItem = nil;
        self.title = @"OneDrive";
        dispatch_async(dispatch_get_main_queue(), ^(){
            self.navigationItem.hidesBackButton = YES;
            self.navigationItem.rightBarButtonItem = self.signIn;
            // Reload from main thread
            [self.collectionView reloadData];
        });
    }];
}

- (void)loadChildren
{
    NSString *itemId = (self.currentItem) ? self.currentItem.id : @"root";
    ODChildrenCollectionRequest *childrenRequest = [[[[self.client drive] items:itemId] children] request];
    if (![self.client serviceFlags][@"NoThumbnails"]){
        [childrenRequest expand:@"thumbnails"];
    }
    [self loadChildrenWithRequest:childrenRequest];
}


- (void)onLoadedChildren:(NSArray *)children
{
    if (self.refreshControl.isRefreshing){
        [self.refreshControl endRefreshing];
    }
    [children enumerateObjectsUsingBlock:^(ODItem *item, NSUInteger index, BOOL *stop){
        if (![self.itemsLookup containsObject:item.id]){
            [self.itemsLookup addObject:item.id];
        }
        self.items[item.id] = item;
    }];
    [self loadThumbnails:children];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.collectionView reloadData];
    });
}

- (void)loadThumbnails:(NSArray *)items{
    for (ODItem *item in items){
        if ([item thumbnails:0]){
            [[[[[[self.client drive] items:item.id] thumbnails:@"0"] small] contentRequest] downloadWithCompletion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                if (!error){
                    self.thumbnails[item.id] = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [self.collectionView reloadData];
                    });
                }
            }];
        }
    }
}

- (void)loadChildrenWithRequest:(ODChildrenCollectionRequest*)childrenRequests
{
    [childrenRequests getWithCompletion:^(ODCollection *response, ODChildrenCollectionRequest *nextRequest, NSError *error){
        if (!error){
            if (response.value){
                [self onLoadedChildren:response.value];
            }
            if (nextRequest){
                [self loadChildrenWithRequest:nextRequest];
            }
        }
        else if ([error isAuthenticationError]){
            [self showErrorAlert:error];
            [self onLoadedChildren:@[]];
        }
    }];
}

- (ODItem *)itemForIndex:(NSIndexPath *)indexPath
{
    NSString *itemId = self.itemsLookup[indexPath.row];
    return self.items[itemId];
}

#pragma mark CollectionView Methods 

- (ODXItemCollectionViewController *)collectionViewWithItem:(ODItem *)item;
{
    ODXItemCollectionViewController *newController = [self.storyboard instantiateViewControllerWithIdentifier:self.storyBoardId];
    newController.title = item.name;
    newController.currentItem = item;
    newController.client = self.client;
    return newController;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.itemsLookup count];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __block ODItem *item = [self itemForIndex:indexPath];
    if (item.folder){
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.navigationController pushViewController:[self collectionViewWithItem:item] animated:YES];
        });
    }
    else if (self.selection){
        if ([self.selectedItems containsObject:item]){
            [self.selectedItems removeObject:item];
        }
        else{
            [self.selectedItems addObject:item];
        }
        [self.collectionView reloadData];
    }
    else if (item.file){
    ODURLSessionDownloadTask *task = [[[[self.client drive] items:item.id] contentRequest] downloadWithCompletion:^(NSURL *filePath, NSURLResponse *response, NSError *error){
        [self.progressController hideProgress];
            if (!error) {
                if ([item.file.mimeType isEqualToString:@"text/plain"]) {
                    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                    NSString *newFilePath = [documentPath stringByAppendingPathComponent:item.name];
                    [[NSFileManager defaultManager] moveItemAtURL:filePath toURL:[NSURL fileURLWithPath:newFilePath] error:nil];
                    ODXTextViewController *newController = [self.storyboard instantiateViewControllerWithIdentifier:@"FileViewController"];
                    [newController setItemSaveCompletion:^(ODItem *newItem){
                        if (newItem){
                            if (![self.itemsLookup containsObject:newItem.id]){
                                [self.itemsLookup addObject:newItem.id];
                            }
                            self.items[newItem.id] = newItem;
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                [self.collectionView reloadData];
                            });
                        }
                    }];
                    newController.title = item.name;
                    newController.item = item;
                    newController.client = self.client;
                    newController.filePath = newFilePath;
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [super.navigationController pushViewController:newController animated:YES];
                    });
                }
            }
            else{
                [self showErrorAlert:error];
                [self.selectedItems removeObject:item];
            }
        }];
        task.progress.totalUnitCount = item.size;
        [self.progressController showProgressWithTitle:[NSString stringWithFormat:@"Downloading %@", item.name] progress:task.progress];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ODItem *item = [self itemForIndex:indexPath];
    
    ODXItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UIView *bgColorView = [[UIView alloc] init];
    // Reset the old image
    cell.imageView.image = nil;
    cell.backgroundColor = [UIColor blackColor];
    cell.label.textColor = [UIColor whiteColor];
    cell.label.backgroundColor = [UIColor clearColor];
    [cell.label setText:item.name];
    
    if (self.selection && [self.selectedItems containsObject:item]){
        cell.selected = YES;
    }
    if (self.thumbnails[item.id]){
        UIImage *image = self.thumbnails[item.id];
        cell.imageView.image = image;
    }
    
    bgColorView.backgroundColor = [UIColor grayColor];
    [cell setSelectedBackgroundView:bgColorView];
    
    if (item.folder){
        cell.backgroundColor = [UIColor blueColor];
    }
    return cell;
}


#pragma mark Action Methods

- (IBAction)didSelectActionButton:(UIBarButtonItem*)actionButton
{
    if (self.selection){
        [self showSelectionActionViewWithButton:actionButton];
    }
    else{
        [self showFolderActionViewWithButtonSource:actionButton];
    }
}


- (void)showFolderActionViewWithButtonSource:(UIBarButtonItem*)buttonSource
{
    UIAlertController *folderActions = [UIAlertController alertControllerWithTitle:@"Folder Actions!"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *shareFolder = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Share %@",self.currentItem.name]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action){
                                                            [ODXActionController shareItem:self.currentItem withClient:self.client viewController:self completion:^(ODPermission *response, NSError *error){
                                                                [self showShareLink:response.link.webUrl withError:error];
                                                            }];
                                                        }];
    
    UIAlertAction *createFolder = [UIAlertAction actionWithTitle:@"New Folder"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
                                                             NSString *itemId = (self.currentItem) ? self.currentItem.id : @"root";
                                                             [ODXActionController createNewFolderWithParentId:itemId client:self.client viewController:self completion:^(ODItem *item, NSError *error){
                                                                 if(!error){
                                                                     self.items[item.id] = item;
                                                                     [self loadThumbnails:@[item]];
                                                                     [self.collectionView reloadData];
                                                                 }
                                                                 else {
                                                                     [self showErrorAlert:error];
                                                                 }
                                                             }];
                                                         }];
    UIAlertAction *createFile = [UIAlertAction actionWithTitle:@"Upload Text File" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [ODXActionController createLocalPlainTextFileWithParent:self.currentItem client:self.client viewController:self];
    }];
    
    
    
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    UIAlertAction *deleteFolder = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        
        [ODXActionController deleteItem:self.currentItem withClient:self.client viewController:self completion:^(NSError *error){
            if (error){
                [self showErrorAlert:error];
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }];
    }];
    
    UIAlertAction *selection = [UIAlertAction actionWithTitle:@"Select Stuff" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.selectedItems = [NSMutableArray array];
        self.selection = YES;
    }];
    
     UIAlertAction *signOutAction = [UIAlertAction actionWithTitle:@"SignOut" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self signOutAction];
    }];
    
    [folderActions addAction:selection];
    [folderActions addAction:shareFolder];
    [folderActions addAction:createFolder];
    [folderActions addAction:createFile];
    [folderActions addAction:deleteFolder];
    [folderActions addAction:signOutAction];
    [folderActions addAction:cancel];
    [folderActions popoverPresentationController].barButtonItem = buttonSource;
    [self presentViewController:folderActions animated:YES completion:nil];
}

- (void)showSelectionActionViewWithButton:(UIBarButtonItem *)button
{
    UIAlertController *selectionActions = [UIAlertController alertControllerWithTitle:@"Item Actions!"
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelSelectionAction = [UIAlertAction actionWithTitle:@"Stop Selecting" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.selection = NO;
        self.selectedItems = nil;
        [self.collectionView reloadData];
    }];
    
    UIAlertAction *moveAction = [UIAlertAction actionWithTitle:@"Move" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if ([self.selectedItems count] != 1){
            UIAlertController *failedAction = [UIAlertController alertControllerWithTitle:@"Don't do that" message:@"You can't move multiple items" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
            
            [failedAction addAction:ok];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self presentViewController:failedAction animated:YES completion:nil];
            });
        }
        else{
            [ODXActionController moveItem:self.selectedItems.firstObject withClient:self.client viewController:self completion:^(ODItem *response, NSError *error){
                [self showMovedOrCopiedItem:response withError:error];
            }];
        }
    }];
    
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if ([self.selectedItems count] != 1){
            UIAlertController *failedAction = [UIAlertController alertControllerWithTitle:@"Don't do that" message:@"You can't copy multiple items" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
            
            [failedAction addAction:ok];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self presentViewController:failedAction animated:YES completion:nil];
            });
        }
        else {
            [ODXActionController copyItem:self.selectedItems.firstObject withClient:self.client viewController:self completion:^(ODItem *item, ODAsyncOperationStatus *status, NSError *error){
                if (item || error){
                    [self showMovedOrCopiedItem:item withError:error];
                }
            }];
        }
    }];
    
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if ([self.selectedItems count] != 1){
            UIAlertController *failedAction = [UIAlertController alertControllerWithTitle:@"Don't do that" message:@"You can't copy multiple items" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
            
            [failedAction addAction:ok];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self presentViewController:failedAction animated:YES completion:nil];
            });
        }
        else{
            [ODXActionController renameItem:self.selectedItems.firstObject withClient:self.client viewController:self completion:^(ODItem *response, NSError *error){
                ODItem *oldItem = self.selectedItems.firstObject;
                [self showRenamedItem:oldItem.name newName:response.name error:error];
            }];
        }
    }];

    
    [selectionActions addAction:cancelSelectionAction];
    [selectionActions addAction:moveAction];
    [selectionActions addAction:copyAction];
    [selectionActions addAction:renameAction];
    [selectionActions popoverPresentationController].barButtonItem = button;
    [self presentViewController:selectionActions animated:YES completion:nil];
}


#pragma mark Alert Methods

- (void)showRenamedItem:(NSString *)oldName newName:(NSString *)newName error:(NSError *)error
{
    if (!error){
        NSString *title = [NSString stringWithFormat:@"%@ renamed to %@", oldName, newName];
        UIAlertController *renamedController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
        
        [renamedController addAction:ok];
        [self presentViewController:renamedController animated:YES completion:nil];
    }
    else{
        [self showErrorAlert:error];
    }
}

- (void)showShareLink:(NSString *)link withError:(NSError *)error
{
    if (!error){
        UIAlertController *shareController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@" %@ sharing link", self.currentItem.name]
                                                                                 message:link
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [shareController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
        [self presentViewController:shareController animated:YES completion:nil];
    }
    else{
        [self showErrorAlert:error];
    }
}

- (void)showMovedOrCopiedItem:(ODItem*)item withError:(NSError *)error
{
    if (error){
        [self showErrorAlert:error];
    }
    else {
        ODItem *oldItem = self.items[item.id];
        if (oldItem && ![oldItem.parentReference.path isEqualToString:item.parentReference.path]){
            [self.items removeObjectForKey:item.id];
            [self.itemsLookup removeObject:item.id];
        }
        NSString *message = [NSString stringWithFormat:@"%@ now at %@", item.name, item.parentReference.path];
        UIAlertController *success = [UIAlertController alertControllerWithTitle:message message:@"Nice!" preferredStyle:UIAlertControllerStyleAlert];
        [success addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
        [self presentViewController:success animated:YES completion:nil];
    }
}

- (void)showErrorAlert:(NSError*)error
{
    NSString *errorMsg;
    if ([error isAuthCanceledError]) {
        errorMsg = @"Sign-in was canceled!";
    }
    else if ([error isAuthenticationError]) {
        errorMsg = @"There was an error in the sign-in flow!";
    }
    else if ([error isClientError]) {
        errorMsg = @"Oops, we sent a bad request!";
    }
    else {
        errorMsg = @"Uh oh, an error occurred!";
    }
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:errorMsg
                                                                        message:[NSString stringWithFormat:@"%@", error]
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [errorAlert addAction:ok];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:errorAlert animated:YES completion:nil];
    });
    
}

@end
