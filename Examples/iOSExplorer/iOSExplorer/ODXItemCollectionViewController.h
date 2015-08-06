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


#import <UIKit/UIKit.h>
#import <OneDriveSDK/OneDriveSDK.h>
#import "ODXItemCollectionViewCell.h"

@interface ODXItemCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property NSMutableDictionary *items;

@property NSMutableArray *itemsLookup;

@property (strong, nonatomic) ODClient *client;

@property NSString *storyBoardId;

@property ODItem *currentItem;

- (void)loadChildrenWithRequest:(ODChildrenCollectionRequest*)childrenRequests;

- (void)loadChildren;

- (ODXItemCollectionViewController *)collectionViewWithItem:(ODItem *)item;

- (void)showErrorAlert:(NSError*)error;

@end
