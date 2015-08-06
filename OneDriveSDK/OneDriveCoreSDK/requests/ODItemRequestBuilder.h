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

@class ODItemRequest, ODPermissionRequestBuilder, ODPermissionsCollectionRequestBuilder, ODItemRequestBuilder, ODVersionsCollectionRequestBuilder, ODChildrenCollectionRequestBuilder, ODThumbnailSetRequestBuilder, ODThumbnailsCollectionRequestBuilder, ODItemContentRequest, ODItemCreateSessionRequestBuilder, ODItemCopyRequestBuilder, ODItemCreateLinkRequestBuilder, ODItemAllPhotosRequestBuilder, ODItemDeltaRequestBuilder, ODItemSearchRequestBuilder;
#import "ODModels.h"
#import "ODRequestBuilder.h"

/**
* The header for type ODItemRequestBuilder.
*/


@interface ODItemRequestBuilder : ODRequestBuilder

- (ODPermissionsCollectionRequestBuilder *)permissions;

- (ODVersionsCollectionRequestBuilder *)versions;

- (ODChildrenCollectionRequestBuilder *)children;

- (ODItemRequestBuilder *)children:(NSString *)item;

- (ODThumbnailsCollectionRequestBuilder *)thumbnails;

- (ODThumbnailSetRequestBuilder *)thumbnails:(NSString *)thumbnailSet;

- (ODItemRequest *)request;

- (ODItemRequest *) requestWithOptions:(NSArray *)options;

- (ODItemContentRequest *) contentRequestWithOptions:(NSArray *)options;

- (ODItemContentRequest *) contentRequest;

- (ODItemCreateSessionRequestBuilder *)createSessionWithItem:(ODChunkedUploadSessionDescriptor *)item ;

- (ODItemCopyRequestBuilder *)copyWithName:(NSString *)name parentReference:(ODItemReference *)parentReference ;

- (ODItemCreateLinkRequestBuilder *)createLinkWithType:(NSString *)type ;

- (ODItemAllPhotosRequestBuilder *)allPhotos;

- (ODItemDeltaRequestBuilder *)deltaWithToken:(NSString *)token ;

- (ODItemSearchRequestBuilder *)searchWithQ:(NSString *)q ;

@end
