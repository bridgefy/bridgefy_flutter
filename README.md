# Bridgefy Flutter SDK

## Overview

The Bridgefy Software Development Kit (SDK) is a state-of-the-art, plug-and-play package of
awesomeness that will let people use your mobile app when they don’t have access to the Internet by
using mesh networks.

Integrate the Bridgefy SDK into your Android and iOS app to reach the 3.5 billion people that don’t
always have access to an Internet connection, and watch engagement and revenue grow!

Website. https://bridgefy.me/sdk/

Email. contact@bridgefy.me

Twitter. https://twitter.com/bridgefy

Facebook. https://www.facebook.com/bridgefy

## Operation mode

All the connections are handled seamlessly by the SDK to create a mesh network. The size of this
network depends on the number of devices connected and the environment as a variable factor,
allowing you to join nodes in the same network or nodes in different networks.

![https://github.com/bridgefy/bridgefy-ios-sdk-sample/blob/master/img/Mobile_Adhoc_Network.gif?raw=true](https://github.com/bridgefy/bridgefy-ios-sdk-sample/blob/master/img/Mobile_Adhoc_Network.gif?raw=true)

## Platform permissions

To utilize this SDK in a Flutter application, you'll need to configure permissions for each
individual platform (iOS and Android) first. You can read more about each platform's requirements
below:

* [iOS Permissions](https://github.com/bridgefy/sdk-ios-beta#permissions)
* [Android Permissions](https://github.com/bridgefy/sdk-android-beta#permissions)

## Installation

Since this SDK is still in beta, you'll need to add a reference to this repository in your
`pubspec.yaml` file:

```yaml
dependencies:
  bridgefy:
    git:
      url: https://github.com/bridgefy/bridgefy_flutter.git
      ref: main
```

## Usage

### Initialization

The init method initializes the Bridgefy SDK with the given API key and propagation profile. The
delegate parameter is required and should be an object that conforms to the `BridgefyDelegate`
mixin.

The following code shows how to start the SDK (using your API key) and how to assign the delegate.

```dart
class _MyAppState extends State<MyApp> implements BridgefyDelegate {
  final _bridgefy = Bridgefy();

  @override
  void initState() {
    super.initState();
    _bridgefy.initialize(
      apiKey: "<API_KEY>",
      propagationProfile: BridgefyPropagationProfile.longReach,
      delegate: this
    );
  }
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
  // `messageID` contains the ID of the message.
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

To see a full list of events, take a look at the `BridgefyDelegate` mixin.
