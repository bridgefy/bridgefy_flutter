<p align="center">
    <img src="https://www.gitbook.com/cdn-cgi/image/width=256,dpr=2,height=40,fit=contain,format=auto/https%3A%2F%2F3290834949-files.gitbook.io%2F~%2Ffiles%2Fv0%2Fb%2Fgitbook-x-prod.appspot.com%2Fo%2Fspaces%252F5XKIMMP6VF2l9XuPV80l%252Flogo%252Fd78nQFIysoU2bbM5fYNP%252FGroup%25203367.png%3Falt%3Dmedia%26token%3Df83a642d-8a9a-411f-9ef4-d7189a4c5f0a" />
</p>

<p align="center">
    <img src="https://3290834949-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F5XKIMMP6VF2l9XuPV80l%2Fuploads%2FD0HSf0lWC4pWB4U7inIw%2Fharegit.jpg?alt=media&token=a400cf7d-3254-4afc-bed0-48f7d98205b0"/>
</p>

# Bridgefy Flutter SDK
![GitHub last commit](https://img.shields.io/github/last-commit/bridgefy/bridgefy_flutter)
![GitHub issues](https://img.shields.io/github/issues-raw/bridgefy/bridgefy_flutter?style=plastic)

The Bridgefy Software Development Kit (SDK) is a state-of-the-art, plug-and-play package that will let people use your mobile app when they don’t have access to the Internet, by using Bluetooth mesh networks.

Integrate the Bridgefy SDK into your Android and iOS app to reach the 3.5 billion people that don’t always have access to an Internet connection, and watch engagement and revenue grow!

**Website**. https://bridgefy.me/sdk <br>
**Email**. contact@bridgefy.me <br>
**witter**. https://twitter.com/bridgefy <br>
**Facebook**. https://www.facebook.com/bridgefy <br>

## Operation mode

All the connections are handled seamlessly by the SDK to create a mesh network. The size of this
network depends on the number of devices connected and the environment as a variable factor,
allowing you to join nodes in the same network or nodes in different networks.

![networking](https://images.saymedia-content.com/.image/t_share/MTkzOTUzODU0MDkyNjE3MjIx/particlesjs-examples.gif)

## Platform permissions

To utilize this SDK in a Flutter application, you'll need to configure permissions for each
individual platform (iOS and Android) first. You can read more about each platform's requirements
below:

* [iOS Permissions](https://github.com/bridgefy/sdk-ios#permissions)
* [Android Permissions](https://github.com/bridgefy/sdk-android#android-permissions)

## Installation

To install this SDK, you'll need to either add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  bridgefy: ^1.1.6
```

Or run this flutter command:

```bash
flutter pub add bridgefy
```

## Usage

### Initialization

The init method initializes the Bridgefy SDK with the given API key and verbose logging. The
delegate parameter is required and should be an object that conforms to the `BridgefyDelegate`mixin.

The following code shows how to init the SDK (using your API key) and how to assign the delegate.

```dart
import 'package:bridgefy/bridgefy.dart';

class _MyAppState extends State<MyApp> implements BridgefyDelegate {
  final _bridgefy = Bridgefy();

  @override
  void initState() {
    super.initState();
    try {
      await _bridgefy.initialize(
        apiKey: "<API_KEY>",
        delegate: this,
        verboseLogging: true,
      );
    } catch (e) {
      _log("Unable to initialize: $e");
    }
  }
```
### Start Bridgefy

The following code shows how to start the SDK with propagation profile and custom user Id.

````dart

    _bridgefy.start(
      userId: "Custom UUID",
      propagationProfile: BridgefyPropagationProfile.standard
    );

````

### Stop Bridgefy

Stop Bridgefy operations
```dart
	_bridgefy.stop();
```


### Sending data

The following method is used to send data using a transmission mode. This method returns a UUID to
identify the message sent.

```dart
void _send() async {
  final lastMessageId = await _bridgefy.send(
    data: _data, // Uint8List data to send
    transmissionMode: BridgefyTransmissionMode(
      type: BridgefyTransmissionModeType.broadcast,
      uuid: await _bridgefy.currentUserID,
    ),
  );
}
```

### Responding to SDK events

The SDK will report events to your app through the `BridgefyDelegate` object you specified upon
initialization.

The following is an example event emitted when a message is successfully sent:

```dart
@override
void bridgefyDidSendMessage({required String messageID}) {
  // `messageID` The id of the message sent successfully.
}

// This function is called when the message could not be sent.
@override
void bridgefyDidFailSendingMessage({required String messageID, BridgefyError? error}) {
    // `messageID`: The id of the message that was tried to be sent.
	// `error`: Error reason.
}
```


When the app received data through Bridgefy:

```dart
@override
void bridgefyDidReceiveData({
  required Uint8List data,
  required String messageId,
  required BridgefyTransmissionMode transmissionMode,
}) {
  // `data` contains the message bytes.
}
```

### Transmission Mode

`BridgefyTransmissionModeType` specifies different transmission modes:

- `p2p`: Deliver a message to a specific recipient only if there's an active connection with it.
- `mesh`: Deliver a message to a specific recipient using nearby devices to propagate it.
- `broadcast`: Propagate a message readable by every device that receives it.

### PropagationProfile

`BridgefyPropagationProfile` defines different propagation profiles within the BridgefySDK.

- `standard`: Represents a standard propagation profile.
- `highDensityNetwork`: Indicates a propagation profile suitable for high-density networks.
- `sparseNetwork`: Represents a propagation profile tailored for sparse networks.
- `longReach`: Indicates a propagation profile optimized for long reach.
- `shortReach`: Represents a propagation profile designed for short reach communication.

### Nearby peer detection

The following method is invoked when a peer has established connection:

```dart
    @override
    void bridgefyDidConnect({required String userID}) {
      // `userID` the peer connected
    }
```

When a peer is disconnected(out of range), the following method will be invoked:

```dart
    @override
    void bridgefyDidDisconnect({required String userID}) {
      // `userID` the peer disconnected
    }
```

To see a full list of events, take a look at the `BridgefyDelegate` mixin.

### Other Utilities

Retrieve current user ID:

 ```dart
 String currentUserID = await _bridgefy.currentUserID;
 ```

Get a list of connected peers:


 ```dart
 List<String> connectedPeers = await _bridgefy.connectedPeers;
 ```

Check if the SDK is initialized or started:

 ```dart
bool isInitialized = await _bridgefy.isInitialized;
bool isStarted = await _bridgefy.isStarted;
 ```

Retrieve license expiration date:


```dart
DateTime? expirationDate = await _bridgefy.licenseExpirationDate;
```

### License Update
Update the license:

```dart
await _bridgefy.updateLicense();
```


## Multi-Platform Support

Bridgefy's SDKs are designed to work seamlessly across different platforms, including iOS and Android. This means that users with different devices can communicate with each other as long as they have the Bridgefy-enabled applications installed.

* [Bridgefy iOS](https://github.com/bridgefy/sdk-ios)
* [Bridgefy Android](https://github.com/bridgefy/sdk-android)

## Contact & Support
+ contact@bridgefy.me

© 2023 Bridgefy Inc. All rights reserved 
