import 'dart:typed_data';

import 'bridgefy_platform_interface.dart';

/// The mode used to propagate a message through nearby devices.
enum BridgefyTransmissionMode {
  /// Deliver a message to a specific recipient only if there's an active connection with it.
  p2p,

  /// Deliver a message to a specific recipient using nearby devices to propagate it.
  mesh,

  /// Propagate a message readable by every device that receives it.
  broadcast
}

/// Profile that defines a series of properties and rules for the propagation of messages.
enum BridgefyPropagationProfile {
  standard,
  highDensityNetwork,
  sparseNetwork,
  longReach,
  shortReach
}

class BridgefyError extends Error {}

mixin BridgefyDelegate {
  void bridgefyDidStart({required String currentUserID});
  void bridgefyDidFailToStart({required Error error});
  void bridgefyDidConnect({required String userID});
  void bridgefyDidDisconnect({required String userID});
  void bridgefyDidSendMessage({required String messageID});
  void bridgefyDidFailSendingMessage({required String messageID, required Error error});
  void bridgefyDidReceiveData(
      {required Uint8List data,
      required BridgefyTransmissionMode transmissionMode,
      String? userID});
}

class Bridgefy {
  /// Initialize the SDK
  /// - Parameters:
  ///   - apiKey: API key
  ///   - propagationProfile: Profile that defines a series of properties and rules for the propagation of messages.
  ///   - delegate: Delegate that handles Bridgefy SDK events.
  ///   - verboseLogging: The log level.
  Bridgefy(
      {required String apiKey,
      required BridgefyDelegate delegate,
      BridgefyPropagationProfile propagationProfile = BridgefyPropagationProfile.standard,
      bool verboseLogging = false}) {
    BridgefyPlatform.instance.initialize(
        apiKey: apiKey,
        propagationProfile: propagationProfile,
        delegate: delegate,
        verboseLogging: verboseLogging);
  }

  /// Start Bridgefy SDK operations
  void start() {
    return BridgefyPlatform.instance.start();
  }

  /// Function used to send data using a ``TransmissionMode``. This method returns a UUID to identify the message sent.
  /// - Parameters:
  ///   - data: The message data
  ///   - transmissionMode: The mode used to propagate a message through nearby devices.
  /// - Returns: The id of the message that was sent.
  void send(
      {required Uint8List data,
      required BridgefyTransmissionMode transmissionMode,
      String? userID}) {
    return BridgefyPlatform.instance
        .send(data: data, transmissionMode: transmissionMode, userID: userID);
  }

  /// Stop Bridgefy SDK operations
  void stop() {
    return BridgefyPlatform.instance.stop();
  }
}
