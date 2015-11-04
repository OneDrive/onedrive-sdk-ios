# Collections in the OneDrive SDK for iOS

You can use the OneDrive SDK for iOS to work with item collections in OneDrive.

## Getting a collection

To retrieve a collection, like a folder's children, you call `getWithCompletion`:

```objc
[[[[[odClient drive] items:<item_id>] children] request] getWithCompletion:
    ^(ODCollection *children, ODChildrenCollectionRequest *nextRequest, NSError *error){
        // Returns an ODCollection, 
        // another children request if there are more children to get, 
        // or an error if one occurred.
}];
```

`children` is an `ODCollection` that contains three properties: 

|Name|Description|
|----|-----------|
|**value**|An `NSArray` of `ODItems`.|
|**nextLink**| An `NSURL` used to get to the next page of items, if another page exists.|
|**additionData**| An `NSDictionary` to any additional values returned by the service. In this case, none.|

The completion handler also takes an `ODChildrenCollectionRequest` called `nextRequest`. This is the same type returned by `[[[[[odClient drive] items:<item_id>] children] request]`.  If there is another page of items this object can be used to make the next page request on the collection. If there are no pages left this object will be nil.

## Adding to a collection

Some collections, like the children of a folder, can be changed. To add a folder to the children of an item you can call the `addItem` method:

```objc
ODItem *newFolder = [[ODIem alloc] init];
newFolder.name = <new_folder_name>;
newFolder.folder = [[ODFolder alloc] init];
[[[[[[odClient] drive] items:<item_id>] children] request] addItem:newFolder withCompletion:^(ODItem *item, NSError *error){
    //returns the new item or an error if there was one.
}];
```

## Expanding a collection

To expand a collection, you call expand on the `CollectionRequest` object with the string you want to expand:

```objc
ODChildrenCollectionRequest *request = [[[[[[odClient] drive] items:<item_id>] children] request] expand:@"thumbnails"];

[request getWithCompletion:^(ODCollection *children, ODChildrenCollectionRequest *nextRequest, NSError *error){
    // children will have an array of ODItems, that will have a non nil 
    // thumbnails property if there are thumbnails
}];
```

## Special collections

Some API calls will return collections with added properties.  These properties will always be in the additional data dictionary. These collections are also their own objects (subclasses of `ODCollection`) that will have these properties attached to them.  

To get the delta of an item you call:

```objc
[[[[[odClient drive] items:itemId] deltaWithToken:nil] request] 
executeWithCompletion:^(ODItemDeltaCollection *collection, ODItemDeltaRequest *nextReuqest, NSError *error){
        
}];
```
`ODItemDeltaRequest` is an `ODCollection` object with a `token` property and a `deltaLink` property. The token link can be used to pass into `deltaWithToken:` when you want to check for more changes. You can also construct a delta request with the `deltaLink` property. The `nextRequest` is an `ODItemDeltaRequest` to be used for paging purposes and will be nil when there are no more changes.

