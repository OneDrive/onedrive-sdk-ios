# Authentication

To authenticate your app, you only need to get a ODClient, which will handle all authentication for you. Note that if the user changes their password, you must re-authenticate.  If you see `401` error codes, this is most likley the case. See [Errors](error.md) for more info.

## Simple authentication
The easiest way to get authenticated is to call the clientWithCompletion method:

```
[ODClient clientWithCompletion:^(ODClient *client, NSError *error){
    if (!error){
        self.odClient = client;
    }
 }];
```

This method will do two things:

1. Try and retrieve the last used ODClient from the keychain.
2. If this fails, the method will invoke UI and promt the user to log in.

If there was an error in either of these steps, an error will be handed back.

If you know you want to invoke the UI you can make a direct call to authenticatedClientWithCompletion:

```
[ODClient authenticatedClientWithCompletion:(ODClient *client, NSError *error){
    if (!error){
        self.odclient = client;
    }
}];
```
This method will work the same as clientWithCompletion but it will not check on disk for a client first.

## Loading accounts from disk

If you know that you already have accounts on disk and want to select which account to use, you can call:

```
NSArray *accounts = [ODClient loadClients];
```

This method will return an `NSArray` of ODClient objects that have been stored on disk.

If you want to load just the current account. You can also call:

```
ODClient *currentClient = [ODClient loadCurrentClient];
```

You can set the current client by:

```
[ODClient setCurrentClient:<current_client>];
```

To load the client by the client's account id:

```
[ODClient loadClientWithAccountId:<account_id>];
```

To get a clients account id, use the `client.accountId` property on ODClient.


