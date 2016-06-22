# Get started with the OneDrive SDK for iOS

[![Build Status](https://travis-ci.org/OneDrive/onedrive-sdk-ios.svg?branch=master)](https://travis-ci.org/OneDrive/onedrive-sdk-ios)

Integrate the [OneDrive API](https://dev.onedrive.com/README.htm) into your iOS app!

## 1. Installation

### Install via Cocoapods
* [Install Cocoapods](http://guides.cocoapods.org/using/getting-started.html) - Follow the getting started guide to install Cocoapods.
* Add the following to your Podfile : `pod 'OneDriveSDK'`
* Run the command `pod install` to install the latest OneDriveSDK pod.
* Add `#import <OneDriveSDK/OneDriveSDK.h>` to all files that need to reference the SDK.

## 2. Getting started

### 2.1 Register your application

Register your application by following [these](https://dev.onedrive.com/app-registration.htm) steps.

### 2.2 Set up Keychain Sharing Entitlements in your Xcode Project

Click on your project in the Navigator pane in Xcode. Click on your application target and then the "Capabilities" tab. Scroll down to "Keychain Sharing" and flip the switch on. Add "com.microsoft.adalcache" to that list.

### 2.2 Setting your application Id and scopes

* You can set your application Id and scopes directly on the ODClient object. 

* For applications targeting OneDrive call the class method `[ODClient setMicrosoftAccountAppId:<applicationId> scopes:<scopes>]` with a specified `<applicationId>` and `<scopes>`. For more info about scopes, see [Authentication scopes](https://dev.onedrive.com/auth/msa_oauth.htm#authentication-scopes).

* For applications targeting OneDrive for Business call the class method `[ODClient setActiveDirectoryAppId:<applicationId> redirectURL:<redirectURL>]`  with specified `<applicationId>` and `<redirectURL>`.  Note: the redirect URL must match the redirect URL that you specified in the [Azure Management Portal](https://manage.windowsazure.com/).

### 2.3 Getting an authenticated ODClient object

* Once you have set the correct application Id and scopes, you must get an ODClient 
  object to make requests against the service. The SDK will store the account
  information for you, but when a user logs on for the first time, it will invoke UI to get the 
  user's account information.

* Get an authenticated ODClient via the clientWithCompletion method:

```objc
[ODClient clientWithCompletion:^(ODClient *client, NSError *error){
    if (!error){
        self.odClient = client;
    }
 }];
```

### 2.4 Making requests against the service

Once you have an ODClient that is authenticated you can begin to make calls against the service. The requests against the service look like our [REST API](https://dev.onedrive.com/README.htm). 

To retrieve a user's drive:

```objc
[[[odClient drive] request] getWithCompletion:^(ODDrive *drive, NSError *error){
    //Returns an ODDrive object or an error if there was one
}];
```


To get a user's root folder of their drive:

```objc
[[[[odClient drive] items:@"root"] request] getWithCompletion:^(ODItem *item, NSError *error){
    //Returns an ODItem object or an error if there was one
}];
```

For a general overview of how the SDK is designed, see [overview](docs/overview.md).

For a complete sample application, see [OneDriveAPIExplorer](Examples/iOSExplorer).

## 3. Documentation

For a more detailed documentation see:

* [Overview](docs/overview.md)
* [Auth] (docs/auth.md)
* [Items](docs/items.md)
* [Collections](docs/collections.md)
* [Errors](docs/errors.md)

## 4. Issues

For known issues, see [issues](https://github.com/OneDrive/onedrive-sdk-ios/issues).

## 5. License 

[License](LICENSE.txt)

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.




