# OneDrive SDK for iOS overview

The OneDrive SDK for iOS is designed to look just like the [OneDrive API](https://github.com/onedrive/onedrive-api-docs/).  

## ODClient

When accessing the OneDrive APIs, all requests will be made through an ODClient object. For a more detailed explanation, see [Authentication](/docs/auth.md).

## Resource model


Resources, like [items](/docs/items.md) or drives, are represented by ODItem and ODDrive, respectively. These objects contain properties that represent the properties of a resource. These objects are just property bags and cannot make calls against the service-they are purely models.

To get the name of an item you would address the `name` property. It is possible for any of these properties to be nil at any time. To check if an item is a folder you can address the `folder` property. If the item is a folder an `ODFolder` object will be returned, and it contains all of the properties described by the [folder](https://github.com/OneDrive/onedrive-api-docs/blob/master/facets/folder_facet.md) facet.

See [Resource model](https://github.com/onedrive/onedrive-api-docs/#resource-model) for more info.

## Requests

To make requests against the service, you construct ODRequest objects using ODRequestBuilder objects depending on the calls you are making. This is meant to mimic creating the URL for any of the OneDrive APIs.

### 1. Request builders

To generate ODRequest you chain together calls on request builder objects. You get the first request builder from the `ODClient` object. To get a drive request builder you call:

|Task            | SDK               | URL                             |
|:---------------|:-----------------:|:--------------------------------|
|Get a drive     | [odClient drive]  | GET api.onedrive.com/v1.0/drive/|
 
The call will return an `ODDriveRequestBuilder` object. From drive we can continue to chain the requests to get everything else in the API, like an item.

|Task            | SDK                                | URL                                       |
|:---------------|:----------------------------------:|:------------------------------------------|
|Get an item     | [[odClient drive] items:@"1234"]   | GET api.onedrive.com/v1.0/drive/items/1234|


Here `[odCLient drive]` returns an `ODDriveRequestBuilder` that contains a method `items:` to get an `ODItemRequestBuilder`.

Similarly to get thumbnails:

|Task            | SDK                            | URL                      |
|----------------|--------------------------------|--------------------------|
| Get thumbnails | ... items:@:1234"] thumbnails] | .../items/1234/thumbnails|


Here, `[[odClient drive] items:<item_id>]` returns an `ODItemRequestBuilder` that contains the method `thumbnails`.

This returns a collection of [thumbnail sets](https://github.com/OneDrive/onedrive-api-docs/blob/master/resources/thumbnailSet.md). To index the collection directly you can call:

|Task               | SDK                                 | URL                        |
|-------------------|-------------------------------------|----------------------------|
| Get thumbnail Set | ... items:@"1234"] thumbnails:@"0"] | ...items/1234/thumbnails/0 |

To return a thumbnail set, and to get a specific [thumbnail](https://github.com/OneDrive/onedrive-api-docs/blob/master/resources/thumbnail.md), you can add the name of the thumbnail to the URL like this:

|Task             | SDK                         | URL                    |
|-----------------|-----------------------------|------------------------|
| Get a thumbnail | ... thumbnails:@"0"] small] | .../thumbnails/0/small |


### 2. Request calls

Once you have constructed the request you call the `request` method on the request builder. This will construct the request object needed to make calls against the service.

For an item you call:

```objc
ODItemRequest *itemRequest = [[[odClient drive] items:<item_id>] request];
```

All request builders have a `request` method that can generate a `ODRequest` object. Request objects may have different methods on them depending on the type of request. To get an item you call:

```objc
[itemRequest getWithCompletion:^(ODItem *item, NSError *error){
    // This will make the network request and return the item
    // or an error if there was one
}];
```

You could also chain this together with call above :
```objc
[[[[odClient drive] items:<item_id>] request] getWithCompletion:^(ODItem *item, NSError *error){

}];
```

See [items](/docs/items.md) for more info on items and [errors](/docs/errors.md) for more info on errors.

## Query options

If you only want to retrieve certain properties of a resource you can select them. Here's how to get only the names and ids of an item:

```objc
[[[[[odClient drive] items:<item_id>] request] select:@"name,id"] getWithCompletion:^(ODItem *item, NSError *error){
    // the item object will have nil properties for everything except name and id
}];

```
To expand certain properties on resources you can call a similar expand method, like this:

```objc
[[[[[odClient drive] items:<item_id>] request] expand:@"thumbnails"] getWithCompletion:^(ODItem *item, NSError *error){
    // the item object will have a non nil thumbnails property if thumbnails exist.
}];

```
