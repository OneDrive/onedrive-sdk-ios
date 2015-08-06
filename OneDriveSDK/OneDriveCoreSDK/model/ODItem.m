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

#import "ODModels.h"
#import "ODCollection.h"

@interface ODObject()

@property (strong, nonatomic) NSMutableDictionary *dictionary;

@end


@interface ODItem()
{
    ODIdentitySet *_createdBy;
    NSDate *_createdDateTime;
    ODIdentitySet *_lastModifiedBy;
    NSDate *_lastModifiedDateTime;
    ODItemReference *_parentReference;
    ODAudio *_audio;
    ODDeleted *_deleted;
    ODFile *_file;
    ODFileSystemInfo *_fileSystemInfo;
    ODFolder *_folder;
    ODImage *_image;
    ODLocation *_location;
    ODOpenWithSet *_openWith;
    ODPhoto *_photo;
    ODSearchResult *_searchResult;
    ODSpecialFolder *_specialFolder;
    ODVideo *_video;
    ODCollection *_permissions;
    ODCollection *_versions;
    ODCollection *_children;
    ODCollection *_thumbnails;
}
@end

/**
* The implementation file for type item.
*/

@implementation ODItem	

- (ODIdentitySet *)createdBy
{
    if (!_createdBy){
        _createdBy = [[ODIdentitySet alloc] initWithDictionary:self.dictionary[@"createdBy"]];
    }
    return _createdBy;
}

- (void)setCreatedBy:(ODIdentitySet *)createdBy
{
    _createdBy = createdBy;
    self.dictionary[@"createdBy"] = createdBy; 
}

- (NSDate *)createdDateTime
{
    if(!_createdDateTime){
        _createdDateTime = [self dateFromString:self.dictionary[@"createdDateTime"]];
    }
    return _createdDateTime;
}

- (void)setCreatedDateTime:(NSDate *)createdDateTime
{
    _createdDateTime = createdDateTime;
    self.dictionary[@"createdDateTime"] = createdDateTime; 
}

- (NSString *)cTag
{
    return self.dictionary[@"cTag"];
}

- (void)setCTag:(NSString *)cTag
{
    self.dictionary[@"cTag"] = cTag;
}

- (NSString *)itemDescription
{
    return self.dictionary[@"description"];
}

- (void)setItemDescription:(NSString *)itemDescription
{
    self.dictionary[@"description"] = itemDescription;
}

- (NSString *)eTag
{
    return self.dictionary[@"eTag"];
}

- (void)setETag:(NSString *)eTag
{
    self.dictionary[@"eTag"] = eTag;
}

- (NSString *)id
{
    return self.dictionary[@"id"];
}

- (void)setId:(NSString *)id
{
    self.dictionary[@"id"] = id;
}

- (ODIdentitySet *)lastModifiedBy
{
    if (!_lastModifiedBy){
        _lastModifiedBy = [[ODIdentitySet alloc] initWithDictionary:self.dictionary[@"lastModifiedBy"]];
    }
    return _lastModifiedBy;
}

- (void)setLastModifiedBy:(ODIdentitySet *)lastModifiedBy
{
    _lastModifiedBy = lastModifiedBy;
    self.dictionary[@"lastModifiedBy"] = lastModifiedBy; 
}

- (NSDate *)lastModifiedDateTime
{
    if(!_lastModifiedDateTime){
        _lastModifiedDateTime = [self dateFromString:self.dictionary[@"lastModifiedDateTime"]];
    }
    return _lastModifiedDateTime;
}

- (void)setLastModifiedDateTime:(NSDate *)lastModifiedDateTime
{
    _lastModifiedDateTime = lastModifiedDateTime;
    self.dictionary[@"lastModifiedDateTime"] = lastModifiedDateTime; 
}

- (NSString *)name
{
    return self.dictionary[@"name"];
}

- (void)setName:(NSString *)name
{
    self.dictionary[@"name"] = name;
}

- (ODItemReference *)parentReference
{
    if (!_parentReference){
        _parentReference = [[ODItemReference alloc] initWithDictionary:self.dictionary[@"parentReference"]];
    }
    return _parentReference;
}

- (void)setParentReference:(ODItemReference *)parentReference
{
    _parentReference = parentReference;
    self.dictionary[@"parentReference"] = parentReference; 
}


- (NSInteger)size
{
    if (self.dictionary[@"size"]){
         return [self.dictionary[@"size"] intValue];
    }
    return [@(0) intValue];
}

- (void)setSize:(NSInteger)size
{
    self.dictionary[@"size"] = @(size);
}

- (NSString *)webUrl
{
    return self.dictionary[@"webUrl"];
}

- (void)setWebUrl:(NSString *)webUrl
{
    self.dictionary[@"webUrl"] = webUrl;
}

- (ODAudio *)audio
{
    if (!_audio){
        _audio = [[ODAudio alloc] initWithDictionary:self.dictionary[@"audio"]];
    }
    return _audio;
}

- (void)setAudio:(ODAudio *)audio
{
    _audio = audio;
    self.dictionary[@"audio"] = audio; 
}

- (ODDeleted *)deleted
{
    if (!_deleted){
        _deleted = [[ODDeleted alloc] initWithDictionary:self.dictionary[@"deleted"]];
    }
    return _deleted;
}

- (void)setDeleted:(ODDeleted *)deleted
{
    _deleted = deleted;
    self.dictionary[@"deleted"] = deleted; 
}

- (ODFile *)file
{
    if (!_file){
        _file = [[ODFile alloc] initWithDictionary:self.dictionary[@"file"]];
    }
    return _file;
}

- (void)setFile:(ODFile *)file
{
    _file = file;
    self.dictionary[@"file"] = file; 
}

- (ODFileSystemInfo *)fileSystemInfo
{
    if (!_fileSystemInfo){
        _fileSystemInfo = [[ODFileSystemInfo alloc] initWithDictionary:self.dictionary[@"fileSystemInfo"]];
    }
    return _fileSystemInfo;
}

- (void)setFileSystemInfo:(ODFileSystemInfo *)fileSystemInfo
{
    _fileSystemInfo = fileSystemInfo;
    self.dictionary[@"fileSystemInfo"] = fileSystemInfo; 
}

- (ODFolder *)folder
{
    if (!_folder){
        _folder = [[ODFolder alloc] initWithDictionary:self.dictionary[@"folder"]];
    }
    return _folder;
}

- (void)setFolder:(ODFolder *)folder
{
    _folder = folder;
    self.dictionary[@"folder"] = folder; 
}

- (ODImage *)image
{
    if (!_image){
        _image = [[ODImage alloc] initWithDictionary:self.dictionary[@"image"]];
    }
    return _image;
}

- (void)setImage:(ODImage *)image
{
    _image = image;
    self.dictionary[@"image"] = image; 
}

- (ODLocation *)location
{
    if (!_location){
        _location = [[ODLocation alloc] initWithDictionary:self.dictionary[@"location"]];
    }
    return _location;
}

- (void)setLocation:(ODLocation *)location
{
    _location = location;
    self.dictionary[@"location"] = location; 
}

- (ODOpenWithSet *)openWith
{
    if (!_openWith){
        _openWith = [[ODOpenWithSet alloc] initWithDictionary:self.dictionary[@"openWith"]];
    }
    return _openWith;
}

- (void)setOpenWith:(ODOpenWithSet *)openWith
{
    _openWith = openWith;
    self.dictionary[@"openWith"] = openWith; 
}

- (ODPhoto *)photo
{
    if (!_photo){
        _photo = [[ODPhoto alloc] initWithDictionary:self.dictionary[@"photo"]];
    }
    return _photo;
}

- (void)setPhoto:(ODPhoto *)photo
{
    _photo = photo;
    self.dictionary[@"photo"] = photo; 
}

- (ODSearchResult *)searchResult
{
    if (!_searchResult){
        _searchResult = [[ODSearchResult alloc] initWithDictionary:self.dictionary[@"searchResult"]];
    }
    return _searchResult;
}

- (void)setSearchResult:(ODSearchResult *)searchResult
{
    _searchResult = searchResult;
    self.dictionary[@"searchResult"] = searchResult; 
}

- (ODSpecialFolder *)specialFolder
{
    if (!_specialFolder){
        _specialFolder = [[ODSpecialFolder alloc] initWithDictionary:self.dictionary[@"specialFolder"]];
    }
    return _specialFolder;
}

- (void)setSpecialFolder:(ODSpecialFolder *)specialFolder
{
    _specialFolder = specialFolder;
    self.dictionary[@"specialFolder"] = specialFolder; 
}

- (ODVideo *)video
{
    if (!_video){
        _video = [[ODVideo alloc] initWithDictionary:self.dictionary[@"video"]];
    }
    return _video;
}

- (void)setVideo:(ODVideo *)video
{
    _video = video;
    self.dictionary[@"video"] = video; 
}

- (ODCollection *)permissions
{
    if (!_permissions && self.dictionary[@"permissions"]){
        NSMutableArray *permissionsCollection = [NSMutableArray array];
        NSArray *permissions = self.dictionary[@"permissions"];
        if ([permissions isKindOfClass:[NSArray class]]){
            for (NSDictionary *permission in permissions){
                [permissionsCollection addObject:[[ODPermission alloc] initWithDictionary:permission]];
             }
        }
        _permissions = nil;
        if ([permissionsCollection count] > 0){
            _permissions = [[ODCollection alloc] initWithArray:permissionsCollection nextLink:self.dictionary[@"@nextLink"] additionalData:self.dictionary];
        }
        
    }
    return _permissions;
}

 - (ODPermission *) permissions:(NSInteger)index
{
    ODPermission *permission = nil;
    if (self.permissions.value){
        permission = self.permissions.value[index];
    }

    return permission;
}

- (ODCollection *)children
{
    if (!_children && self.dictionary[@"children"]){
        NSMutableArray *itemsCollection = [NSMutableArray array];
        NSArray *children = self.dictionary[@"children"];
        if ([children isKindOfClass:[NSArray class]]){
            for (NSDictionary *item in children){
                [itemsCollection addObject:[[ODItem alloc] initWithDictionary:item]];
             }
        }
        _children = nil;
        if ([itemsCollection count] > 0){
            _children = [[ODCollection alloc] initWithArray:itemsCollection nextLink:self.dictionary[@"@nextLink"] additionalData:self.dictionary];
        }
        
    }
    return _children;
}

 - (ODItem *) children:(NSInteger)index
{
    ODItem *item = nil;
    if (self.children.value){
        item = self.children.value[index];
    }

    return item;
}

- (ODCollection *)thumbnails
{
    if (!_thumbnails && self.dictionary[@"thumbnails"]){
        NSMutableArray *thumbnailSetsCollection = [NSMutableArray array];
        NSArray *thumbnails = self.dictionary[@"thumbnails"];
        if ([thumbnails isKindOfClass:[NSArray class]]){
            for (NSDictionary *thumbnailSet in thumbnails){
                [thumbnailSetsCollection addObject:[[ODThumbnailSet alloc] initWithDictionary:thumbnailSet]];
             }
        }
        _thumbnails = nil;
        if ([thumbnailSetsCollection count] > 0){
            _thumbnails = [[ODCollection alloc] initWithArray:thumbnailSetsCollection nextLink:self.dictionary[@"@nextLink"] additionalData:self.dictionary];
        }
        
    }
    return _thumbnails;
}

 - (ODThumbnailSet *) thumbnails:(NSInteger)index
{
    ODThumbnailSet *thumbnailSet = nil;
    if (self.thumbnails.value){
        thumbnailSet = self.thumbnails.value[index];
    }

    return thumbnailSet;
}

@end
