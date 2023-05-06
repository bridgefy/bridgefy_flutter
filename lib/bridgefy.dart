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

/// Describes errors in the Bridgefy error domain.
enum BridgefyErrorType {
  /// The Bridgefy SDK cannot run in the simulator
  simulatorIsNotSupported,

  /// The Bridgefy SDK hasn't been started
  notStarted,

  /// A Bridgefy SDK instance already exists
  alreadyInstantiated,

  /// The Bridgefy SDK is performing the start process
  startInProgress,

  /// The Bridgefy SDK is already running
  alreadyStarted,

  /// The Bridgefy SDK service is not started
  serviceNotStarted,

  /// Cannot get app's bundle id
  missingBundleID,

  /// The provided API key is not valid
  invalidAPIKey,

  /// An internet connection is required to validate the license
  internetConnectionRequired,

  /// An error occurred while creating the session
  sessionError,

  /// The license is expired
  expiredLicense,

  /// The device's time has been modified
  inconsistentDeviceTime,

  /// The user does not allow the use of BLE
  BLEUsageNotGranted,

  /// The use of BLE in this device is restricted
  BLEUsageRestricted,

  /// The BLE antenna has been turned off
  BLEPoweredOff,

  /// The usage of BLE is not supported in the device
  BLEUnsupported,

  /// BLE usage failed with an unknown error
  BLEUnknownError,

  inconsistentConnection,

  connectionIsAlreadySecure,

  cannotCreateSecureConnection,

  /// The length of the data exceed the maximum limit
  dataLengthExceeded,

  /// The data to send is empty
  dataValueIsEmpty,

  /// The requested peer is not connected
  peerIsNotConnected,

  /// An internal error occurred
  internalError,

  /// An error occurred while validating the license
  licenseError,

  /// An error occurred while storing data
  storageError,

  /// An error occurred while encoding the message
  encodingError,

  /// An error occurred while encrypting the message
  encryptionError,
}

class BridgefyError implements Exception {
  BridgefyErrorType type;
  int? code;

  BridgefyError({required String name, this.code}) : type = BridgefyErrorType.values.byName(name);

  @override
  String toString() {
    return "BridgefyError (${type.name})";
  }
}

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
  Future<void> initialize(
      {required String apiKey,
      required BridgefyDelegate delegate,
      BridgefyPropagationProfile propagationProfile = BridgefyPropagationProfile.standard,
      bool verboseLogging = false}) async {
    await BridgefyPlatform.instance.initialize(
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
