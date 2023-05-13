import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'bridgefy_platform_interface.dart';

/// Profile that defines a series of properties and rules for the propagation of messages.
enum BridgefyPropagationProfile {
  standard,
  highDensityNetwork,
  sparseNetwork,
  longReach,
  shortReach
}

/// The mode used to propagate a message through nearby devices.
enum BridgefyTransmissionModeType {
  /// Deliver a message to a specific recipient only if there's an active connection with it.
  p2p,

  /// Deliver a message to a specific recipient using nearby devices to propagate it.
  mesh,

  /// Propagate a message readable by every device that receives it.
  broadcast
}

class BridgefyTransmissionMode {
  BridgefyTransmissionModeType type;
  String uuid;

  BridgefyTransmissionMode({
    required this.type,
    required this.uuid
  });

  @override
  String toString() {
    return "BridgefyTransmissionMode (type: ${type.name}, uuid: $uuid)";
  }
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
  String? message;

  BridgefyError({required this.type, this.code, this.message});

  @override
  String toString() {
    return "BridgefyError (type: ${type.name}, code: $code, message: $message)";
  }
}

/// Definition of the functions required to handle events occurred in the Bridgefy SDK.
mixin BridgefyDelegate {
  /// This function is called when the BridgefySDK has been started.
  /// - Parameter userId: The current user id
  void bridgefyDidStart({required String currentUserID});

  /// This function is called when an error occurred while starting the BridgefySDK.
  /// - Parameter error: Error reason.
  void bridgefyDidFailToStart({required BridgefyError error});

  /// This function is called when the BridgefySDK has been stopped.
  void bridgefyDidStop();

  /// This function is called when an error occurred while stopping the BridgefySDK.
  /// - Parameter error: Error reason.
  void bridgefyDidFailToStop({required BridgefyError error});

  /// The current session was destroyed
  void bridgefyDidDestroySession();

  /// An error occurred while destroying the current session
  void bridgefyDidFailToDestroySession();

  /// This function is called to notify a new connection.
  /// - Parameter userId: The id of the connected peer.
  void bridgefyDidConnect({required String userID});

  /// This function is called to notify a disconnection.
  /// - Parameter userId: The id of the disconnected peer.
  void bridgefyDidDisconnect({required String userID});

  /// This function is called to notify when an on-demand secure connection was established.
  /// - Parameter userId: The id of the user with whom the secure connection was established.
  void bridgefyDidEstablishSecureConnection({required String userID});

  /// This function is called to notify when an on-demand secure connection could not be established.
  /// - Parameters:
  ///   - userId: The id of the user with whom the secure connection failed.
  ///   - error: Error reason
  void bridgefyDidFailToEstablishSecureConnection(
      {required String userID, required BridgefyError error});

  /// This function is called when you confirm the sending of the message
  /// - Parameter messageId: The id of the message sent successfully
  void bridgefyDidSendMessage({required String messageID});

  /// This function is called when the message could not be sent
  /// - Parameters:
  ///   - messageId: The id of the message that was tried to be sent
  ///   - error: Error reason.
  void bridgefyDidFailSendingMessage({required String messageID, required BridgefyError error});

  /// This function is called when a new message is received
  /// - Parameters:
  ///   - data: The message data
  ///   - messageId: The id of the message that was received
  ///   - transmissionMode: The mode used to propagate a message
  void bridgefyDidReceiveData({
    required Uint8List data,
    required String messageId,
    required BridgefyTransmissionMode transmissionMode,
  });
}

/// Bridgefy SDK
class Bridgefy {
  /// Initialize the SDK
  /// - Parameters:
  ///   - apiKey: API key
  ///   - propagationProfile: Profile that defines a series of properties and rules for the
  ///     propagation of messages.
  ///   - delegate: Delegate that handles Bridgefy SDK events.
  ///   - verboseLogging: The log level.
  Future<void> initialize({
    required String apiKey,
    required BridgefyDelegate delegate,
    BridgefyPropagationProfile propagationProfile = BridgefyPropagationProfile.standard,
    bool verboseLogging = false,
  }) async {
    await BridgefyPlatform.instance.initialize(
      apiKey: apiKey,
      propagationProfile: propagationProfile,
      delegate: delegate,
      verboseLogging: verboseLogging,
    );
  }

  /// Start Bridgefy SDK operations
  Future<void> start() {
    return BridgefyPlatform.instance.start();
  }

  /// Stop Bridgefy SDK operations
  Future<void> stop() {
    return BridgefyPlatform.instance.stop();
  }

  /// Destroy current session
  Future<void> destroySession() {
    return BridgefyPlatform.instance.destroySession();
  }

  /// Function used to send data using a ``TransmissionMode``. This method returns a UUID to
  /// identify the message sent.
  /// - Parameters:
  ///   - data: The message data
  ///   - transmissionMode: The mode used to propagate a message through nearby devices.
  /// - Returns: The id of the message that was sent.
  Future<String> send({
    required Uint8List data,
    required BridgefyTransmissionMode transmissionMode,
  }) {
    return BridgefyPlatform.instance.send(
      data: data,
      transmissionMode: transmissionMode,
    );
  }

  /// Function to update the license
  Future<void> updateLicense() {
    return BridgefyPlatform.instance.updateLicense();
  }

  /// Establishes a secure connection with the specified user using
  /// - Parameter userId: The UUID of the user with whom a secure
  ///  connection should be established.
  Future<void> establishSecureConnection({required String userID}) {
    return BridgefyPlatform.instance.establishSecureConnection(userID: userID);
  }

  Future<String> get currentUserID {
    return BridgefyPlatform.instance.currentUserID;
  }

  /// Returns connected peers
  Future<List<String>> get connectedPeers {
    return BridgefyPlatform.instance.connectedPeers;
  }

  /// Returns license expiration date
  Future<DateTime?> get licenseExpirationDate {
    return BridgefyPlatform.instance.licenseExpirationDate;
  }
}
