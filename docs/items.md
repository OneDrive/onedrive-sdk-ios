Items in the OneDrive SDK for iOS
=====

Items in the OneDrive SDK for iOS behave just like items through the API. For more information see the [Items Reference](https://dev.onedrive.com/README.htm#item-resource). All actions on items described there are available through the SDK.

The examples below assume that you have [Authenticated](/docs/auth.md) your app with an ODClient object.

* [Get an Item](#get-an-item)
* [Delete an Item](#delete-an-item)
* [Get Children for an Item](#get-children-for-an-item)
* [Downloading and uploading contents](#downloading-and-uploading-contents)
* [Moving and updating an Item](#moving-and-updating-an-item)
* [Copy an Item](#copy-an-item)

Get an Item
---------------
### 1. By ID

```objc
[[[[odClient drive] items:<item_id>] request] getWithCompletion:^(ODItem *item, NSError *error){
    //Returns an ODItem object or an error if there was one.
}];
```

### 2. By path

```objc
[[[[odClient root] itemByPath:@"Documents/Foo.txt"] request] getWithCompletion:^(ODItem *item, NSError *error){
    //Returns an ODItem object or an error if there was one.
}];

```

Access an item by path from a folder item:

```objc
[[[[odClient drive] items:<item_id>] itemByPath:@"relative/path/to/file.txt"] request] getWithCompletion:^(ODItem *item, NSError *error){
    //Returns an ODItem object or an error if there was one.
}];

```

Delete an Item
---------------
```objc
[[[[odClient drive] items:<item_id>] request] deleteWithCompletion:^(NSError *error){
    //Returns an error if there was one.
}];

```

Get Children for an Item
-------------------------

More info about collections [here](/docs/collections.md).

```objc
[[[[odClient drive] items:<item_id>] children] getWithCompletion:
    ^(ODCollection *children, ODChilrenCollectionRequest *nextRequest, NSError *error){
        // Returns an ODCollection,
        // another children request if there are more children to get,
        // and an error if one occurred.
    }];
```

Downloading and uploading contents
------------------------------

```objc
ODItemContentRequest *request = [[[odClient drive] items:<item_id>] contentRequest];

[request downloadWithCompletion:^(NSURL *filePath, NSURLResponse *urlResponse, NSError *error){
   // The file path to the item on disk. This is a temporary file and will be removed
   // after the block is done executing.
}];

[request uploadFromFile:<file_path> completion:^(ODItem *item, NSError *error){
    // Returns the item that was just uploaded.
}];

[request uploadFromData:<data_object> completion:*(ODItem *item, NSError *error){
    // Returns the item that was just uploaded from memory.
}];

```
Upload and download requests return an ODURLSessionProgressTask, which contain an NSProgress object to monitor.

Moving and updating an Item
--------------
To [move](https://dev.onedrive.com/items/move.htm) an item you must update its parent reference.

```objc
ODItem *updatedItem = [ODItem alloc] init];
updatedItem.id = <item_id>;
updatedItem.parentReference = [ODItemReference alloc] init];
updatedItem.parentReference.id = <new_parent_id>;

[[[[odClient drive] items:updatedItem.id] request] update:updatedItem withCompletion:
    ^(ODItem *newItem, NSError *error){

}];
```

To change an item's name or other property you could:

```objc
ODItem *updatedItem = [ODItem alloc] init];
updatedItem.id = <item_id>;
updatedItem.name = @"New Item Name!";

[[[[odClient drive] items:updatedItem.id] request] update:updatedItem withCompletion:
    ^(ODItem *newItem, NSError *error){

}];

```

Copy an Item
---------------
Copying and item is an async action described [here](https://dev.onedrive.com/items/copy.htm).

```objc
ODItemReference *newParent = [ODItemReference alloc] init];
newParent.id = <new_parent_id>;
ODItemCopyRequest *copyRequest = [[[[odClient drive] items:<item_id>] copyWithName:@"new item name" parentReference:newParent] request];

[copyRequest executeWithCompletion:^(ODItem *item, ODAsyncOperationStatus *status, NSError *error){
        // This handler will be called whenever there is an update
        // from the copy operation, the operation has finished, or there was an error.
        // only one of the parameters will be non nil at a time.
}];

```
The executeWithCompletion method returns an ODAsyncURLSessionDataTask, which can be used to monitor the request via the progress property.
