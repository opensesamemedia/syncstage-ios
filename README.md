# SyncStage iOS Quick Start Example

## Prerequisites

Before starting this guide make sure you have these prerequisites in place.

1. You have received a SyncStage access token by filling in the Early Access Request form [here](https://sync-stage.com/).

2. We assume that you’re using [xcode](https://developer.apple.com/xcode/).

## Getting Started

First you’ll need to clone the SyncStage iOS Example:

```
git clone https://github.com/opensesamemedia/syncstage-ios
cd syncstage-ios
```

The SyncStageSDK is already added to the project as swift package, please wait until the package is downloaded and run the project.

```
dependencies: [
    .package(url: "https://github.com/opensesamemedia/SyncStageSDKSwiftPackage.git", .upToNextMajor(from: "0.0.5"))
]
```

### Permissions

SyncStage SDK requires following permissions to be added to info.plist:

```
Privacy - Microphone Usage Description (Need microphone access for audio recording)
Privacy - Camera Usage Description (No need for camera access), required by ffmpeg
```

## A note on user management in the current SyncStage platform

You are currently responsible for managing your own users in the SyncStage platform. Each access token allows you to host 7 simultaneous users on a single SyncStage server.

When connecting to the quick start app the users will be asked to select their user. If they choose clashing user numbers (between 0 and 6) their connections will fail.

We suggest that you explore the SDK and implement user management in your own service to make sure clashes don’t occur.


## Exploring the SyncStage test application

The SyncStage test application shows you basic UI representation of a typical SDK flow.

You must first copy and paste your Sync Stage early access token into the textbox at the top of the user interface.

As you can see in the code, the access token is passed as a parameter when creating the SyncStage object.

```swift
func initSDK(accessToken: String, userId: Int, completion: @escaping (_ error: SyncStageSDK.SyncStageError?) -> Void) {
        syncStage = SyncStage(accessToken: accessToken, userId: userId) { [weak self] errorCode, message in
            self?.delegate?.onOperationError(errorCode: errorCode, message: message)
        } onConnectionDataChange: { [weak self] connectionData in
            self?.delegate?.onConnectionDataChange(connectionData: connectionData)
        } onStreamListChange: { [weak self] connectionData in
            self?.delegate?.onStreamListChange(connectionData: connectionData)
        } completion: { error in
            completion(error)
        }
    }
```

The first button (‘Request Access’) allow you to click to allow the `Microphone usage` permission that Sync Stage requires from the iOS Operating system.

After that you’ll see buttons for core SDK steps to establish a connection for a user. All of code for these steps can be found in use in the following file:

```
./SyncStageDemo_iOS/SyncStageSDK.swift
```

Those steps are:

1. Call constructor of the SyncStage SDK to create an object for future interactions. Importantly constructor accepts a userID variable which allows you to define the aforementioned user number on your SyncStage server. Meaning of other constructor parameters is described in the following sections.

2. `connect(_ completion: @escaping (SyncStageSDK.SyncStageError?) -> Void)` which uses your SyncStage Early Access token to connect to your SyncStage server. Importantly, once more than one user is connected, they will then be able to start communicating via SyncStage. Establishing a connection can take up to 5s.
3. `disconnect(_ completion: @escaping (SyncStageSDK.SyncStageError?) -> Void)` which then disconnects the user that initialized this SDK instance from the server.

Other noteworthy SDK functions are:

4. `getConnectionData() -> ConnectionData?` which returns `ConnectionData` object with detailed information about audio streams like connection status of each stream, network impact, or volume level of each stream.
5. `changeStreamVolume(with streamId: String, volume: Int) -> SyncStageErrorCode` which allows to change volume of particular stream.
6. `getExpirationTime() -> Int64?` which returns the amount of time you have left available on your SyncStage Early Access server token.

### SDK callbacks

The constructor of the SyncStage class allows for registering callback listeners of specific asynchronous events:

1. `completion: @escaping (_ error: SyncStageSDK.SyncStageError?) -> Void` which informs about SDK initialization problem if occur.
2. `onOperationError: @escaping (_ errorCode: SyncStageSDK.SyncStageErrorCode, _ message: String) -> Void` which informs about errors that occured after the successfull initialization.
3. `onConnectionDataChange: @escaping (_ connectionData: SyncStageSDK.ConnectionData) -> Void` which is called if any of the `ConnectionData` parameters have changed.
4. `onStreamListChange: @escaping (_ connectionData: SyncStageSDK.ConnectionData) -> Void` which is called if status of any of `rxStreams` (incoming streams) have changed, e.g. is triggered when any stream joins or leaves the session.

All of the callback parameters are optional.

# Looking for assistance

You can lean on the SyncStage Early Access Slack channel for assistance with connecting with your applications. You can join the channel INSERT LINK HERE or send us an email via INSERT EMAIL HERE

# Recommendations

1. SyncStage SDK pipeline will work even faster with headphones plugged into your apple device as it helps our algorithm avoid certain calculations.

2. If you’re testing two smartphones in close proximity, you will need to be aware of feedback. While the SyncStage platform provides feedback cancellation, isolating the phones from each other in distance will ensure the best experience.

3. While it is possible to test with wireless headphones, we strongly recommend against it as doing so can add up to 300ms of latency.

# SyncStage SDK package repository
SyncStage SDK swift package package repository can be found [here](https://github.com/opensesamemedia/SyncStageSDKSwiftPackage).

# Acknowledgements
 We'd like to give a shout out to following open source projects that were used in the SDK and Quick Start Example development:

* [FFmpeg](https://github.com/FFmpeg/FFmpeg)
