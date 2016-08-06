# Authenticate your iOS app for OneDrive

To authenticate your app to use OneDrive, you only need to get a ODClient, which will handle all authentication for you. Note that if the user changes their password, you must re-authenticate.  If you see `401` error codes, this is most likley the case. See [Error codes for the OneDrive iOS SDK](errors.md) for more info.

## Simple authentication
The easiest way to get authenticated is to call the clientWithCompletion method:

```objc
[ODClient clientWithCompletion:^(ODClient *client, NSError *error){
    if (!error){
        self.odClient = client;
    }
 }];
```

This method will do two things:

1. Try and retrieve the last used ODClient from the keychain.
2. If this fails, the method will invoke the OneDrive UI and prompt the user to log in.

If there was an error in either of these steps, the error will be returned.

If you want to invoke the UI, you can make a direct call to authenticatedClientWithCompletion:

```objc
[ODClient authenticatedClientWithCompletion:^(ODClient *client, NSError *error){
    if (!error){
        self.odclient = client;
    }
}];
```
This method will work like clientWithCompletion but it will not check the disk for a client first.

## Loading accounts from disk

If you already have accounts on the disk and want to select which account to use, you can call:

```objc
NSArray *accounts = [ODClient loadClients];
```

This method will return an `NSArray` of ODClient objects that have been stored on disk.

If you want to load just the current account. You can also call:

```objc
ODClient *currentClient = [ODClient loadCurrentClient];
```

You can set the current client by:

```objc
[ODClient setCurrentClient:<current_client>];
```

To load the client by the client's account id:

```objc
[ODClient loadClientWithAccountId:<account_id>];
```

To get a client's account id, use the `client.accountId` property on ODClient.

## Signing out

To sign out you can call:

```objc
[currentClient signOutWithCompletion:^(NSError *error){
    // This will remove any client information from disk.
    // An error will be passed back if an error occured during the sign out process.
}];
```
