# OneDrive iOS SDK

[![Build Status](https://travis-ci.org/OneDrive/onedrive-sdk-ios.svg?branch=master)](https://travis-ci.org/OneDrive/onedrive-sdk-ios)

Integrate the [OneDrive API](https://dev.onedrive.com/README.htm) into your iOS app!

## 1. Installation

### Install via Cocoapods
* [Install Cocoapods](http://guides.cocoapods.org/using/getting-started.html) - Follow the getting started guide to install Cocoapods.
* Add the following to your Podfile : `pod 'OneDriveSDK'`
* Run the command `pod install` to install the latest OneDriveSDK pod.
* Add `#import <OneDriveSDK/OneDriveSDK.h>` to all files that need to reference the SDK.

## 2. Getting started

#### Note: iOS 9 App Transport Security (ATS)

If you are targeting iOS 9 with XCode 7, you need to temporarily enable PFS exceptions for the following domains:

* login.live.com
* login.microsoftonline.com
* login.windows.net
* secure.aadcdn.microsoftonline-p.com

To do this, add the following to your Info.plist :

```
<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSExceptionDomains</key>
		<dict>
			<key>login.windows.net</key>
			<dict/>
			<key>NSIncludeSubdomains</key>
			<true/>
			<key>NSExceptionRequiresForwardSecrecy</key>
			<false/>
			<key>secure.aadcdn.microsoftonline-p.com</key>
			<dict>
				<key>NSIncludeSubmdomains</key>
				<true/>
				<key>NSExceptionRequiresForwardSecrecy</key>
				<false/>
			</dict>
			<key>login.microsoftonline.com</key>
			<dict>
				<key>NSIncludeSubmdomains</key>
				<true/>
				<key>NSExceptionRequiresForwardSecrecy</key>
				<false/>
			</dict>
			<key>login.live.com</key>
			<dict>
				<key>NSIncludeSubmdomains</key>
				<true/>
				<key>NSExceptionRequiresForwardSecrecy</key>
				<false/>
			</dict>
		</dict>
	</dict>
```
You can also see [OneDriveAPIExplorer](Examples/iOSExplorer) for an example.

These domains enable MSA and standard AAD authentication. It's possible that an AAD domain has a multifactor auth flow or ADFS integration would send you to another domain. If you're targeting a customer set, you'll need to add exceptions for those domains to your app or disable ATS all together. To disable ATFS entirely add the following to your Info.plist:

**Warning** This it not the recommended approach and is only necessary if you wish to target all tenants that do not use standard AAD authentication and do not support Transport Layer Security v1.2.

```
<key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowArbitraryLoads</key>
        <true/>
    </dict>
```

### 2.1 Register your application

Register your application by following [these](https://dev.onedrive.com/app-registration.htm) steps.

### 2.2 Setting your application Id and scopes

* You can set your application Id and scopes directly on the ODClient object. 

* Call the class method `[ODClient setMicrosoftAccountAppId:<applicationId> scopes:<scopes>]` with a specified <applicationId> and <scopes>. For more info about scopes, see [Authentication scopes](https://dev.onedrive.com/auth/msa_oauth.htm#authentication-scopes).

### 2.3 Getting an authenticated ODClient object

* Once you have set the correct application Id and scopes, you must get an ODClient 
  object to make requests against the service. The SDK will store the account
  information for you, but when a user logs on for the first time, it will invoke UI to get the 
  user's account information.

* Get an authenticated ODClient via the clientWithCompletion method:

```objc
ODClient *odClient = [ODClient clientWithCompletion:^(ODClient *client, NSError *error){
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






