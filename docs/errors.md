# Handling errors in the OneDrive SDK for iOS
Errors in the OneDriveSDK for iOS behave just like errors returned from the service. You can read more about them [here](https://github.com/OneDrive/onedrive-api-docs/blob/master/misc/errors.md).

Anytime you make a request against the service there is the potential for an error. You will see that all requests to the service can return an error. The error returned is a native `NSError` object, and inside of the NSErrors user dictionary you can obtain the ODError object.

## Checking the Error
There are a few different types of errors that can occur during a network call. We have provided some helper methods to make it easy to check what kind of error occurred. These error types are defined in [ODAuthContants.h](../OneDriveSDK/Common/ODAuthConstants.h).

### Authentication Errors

There can be errors during the authentication process. If the error occurred during the authentication process, the error will have the domain `OD_AUTH_ERROR_DOMAIN`, which is defined as `com.microsoft.onedrivesdk.auth` in [ODAuthContants.h](../OneDriveSDK/Common/ODAuthConstants.h).

You can easily check if an error is an authentication error by calling `[error IsAuthenticationError]`:

```objc
[ODClient clientWithCompletion:^(ODClient *client, NSError *error){
    if (error && [error isAuthenticationError]){
        // handle auth error
    }
 }];
```

In this case, you can also call `[error IsAuthCancelError]` to check if the user canceled the auth flow themselves.

See ODAuthConstants.h for a list of error codes during authentication. To retrieve any info about the error, look in the userInfo dictionary with the key `OD_AUTH_ERROR_KEY`, which is defined as `ODAuthErrorKey`.

### Client Errors

To check if an error is a client error, you can call `[error isClientError]` and  `[error clientError]`, like this:

```objc
[[[[odClient drive] items:@"foo"] request] getWithCompletion:^(ODItem *item, NSError *error){
    if (error && [error isClientError]){
        [self handleClientError:[error clientError]];
    }
}];
```

When a client error arises there will be an ODError object stored in the userInfo dictionary. You can access it with `ODErrorKey`, defined in  [ODConstants.h](../OneDriveSDK/OneDriveCoreSDK/Core/ODConstants.h).

To check the code of an error, you can call the matches method on an error:

```objc
if ([odError matches:@"accessDenied"]){
    // handle access denied error
}
```

Each error object has a message as well as code. This message is for debugging purpose and is not be meant to be displayed to the user. Common error codes have been defined in [ODErrorCodes.h](../OneDriveSDK/OneDriveCoreSDK/Errors/ODErrorCodes.h).


