import 'package:bridgefy/bridgefy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bridgefy_platform_interface.dart';

/// An implementation of [BridgefyPlatform] that uses method channels.
class MethodChannelBridgefy extends BridgefyPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bridgefy');
  BridgefyDelegate? _delegate;

  @override
  Future<void> initialize({
    required String apiKey,
    required BridgefyDelegate delegate,
    BridgefyPropagationProfile propagationProfile = BridgefyPropagationProfile.standard,
    bool verboseLogging = false,
  }) async {
    final value = await methodChannel.invokeMethod(
      'initialize',
      {
        "apiKey": apiKey,
        "propagationProfile": propagationProfile.name,
        "verboseLogging": verboseLogging,
      },
    );
    _throwIfError(value);
    _configureDelegate(delegate);
  }

  @override
  Future<void> start() {
    return methodChannel.invokeMethod('start');
  }

  @override
  Future<String> send({
    required Uint8List data,
    required BridgefyTransmissionMode transmissionMode,
  }) async {
    final result = await methodChannel.invokeMethod(
      'send',
      {
        "data": data,
        "transmissionMode": {"mode": transmissionMode.type.name, "uuid": transmissionMode.uuid},
      },
    );
    _throwIfError(result);
    return result["messageId"] as String;
  }

  @override
  Future<void> stop() {
    return methodChannel.invokeMethod('stop');
  }

  @override
  Future<List<String>> get connectedPeers =>
      methodChannel.invokeMethod('connectedPeers') as Future<List<String>>;

  @override
  Future<String> get currentUserID async {
    final result = await methodChannel.invokeMethod('currentUserID');
    return result["userId"] as String;
  }

  @override
  Future<void> establishSecureConnection({required String userID}) {
    return methodChannel.invokeMethod('establishSecureConnection', {"userId": userID});
  }

  @override
  Future<DateTime?> get licenseExpirationDate async {
    final result = await methodChannel.invokeMethod('licenseExpirationDate');
    final interval = result["licenseExpirationDate"];
    if (interval) {
      return DateTime.fromMillisecondsSinceEpoch(interval);
    }
    return null;
  }

  void _throwIfError(dynamic result) {
    final error = _errorFromResult(result);
    if (error != null) {
      throw error;
    }
  }

  BridgefyError? _errorFromResult(dynamic result) {
    if (result is Map && result.containsKey("error")) {
      final error = result["error"];
      return BridgefyError(
        type: BridgefyErrorType.values.byName(error["type"]),
        code: error["code"],
      );
    }
    return null;
  }

  BridgefyTransmissionMode? _transmissionModeFromResult(dynamic result) {
    if (result is Map && result.containsKey("transmissionMode")) {
      return BridgefyTransmissionMode(
        type: BridgefyTransmissionModeType.values.byName(result["mode"]),
        uuid: result["uuid"],
      );
    }
    return null;
  }

  void _configureDelegate(BridgefyDelegate delegate) {
    _delegate = delegate;
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "bridgefyDidStart":
          _delegate?.bridgefyDidStart(currentUserID: call.arguments['userId'] as String);
          break;
        case "bridgefyDidFailToStart":
          _delegate?.bridgefyDidFailToStart(error: _errorFromResult(call.arguments)!);
          break;
        case "bridgefyDidStop":
          _delegate?.bridgefyDidStop();
          break;
        case "bridgefyDidFailToStop":
          _delegate?.bridgefyDidFailToStop(error: _errorFromResult(call.arguments)!);
          break;
        case "bridgefyDidDestroySession":
          _delegate?.bridgefyDidDestroySession();
          break;
        case "bridgefyDidFailToDestroySession":
          _delegate?.bridgefyDidFailToDestroySession();
          break;
        case "bridgefyDidConnect":
          _delegate?.bridgefyDidConnect(userID: call.arguments['userId'] as String);
          break;
        case "bridgefyDidDisconnect":
          _delegate?.bridgefyDidDisconnect(userID: call.arguments['userId'] as String);
          break;
        case "bridgefyDidEstablishSecureConnection":
          _delegate?.bridgefyDidEstablishSecureConnection(
              userID: call.arguments['userId'] as String);
          break;
        case "bridgefyDidFailToEstablishSecureConnection":
          _delegate?.bridgefyDidFailToEstablishSecureConnection(
            userID: call.arguments['userId'] as String,
            error: _errorFromResult(call.arguments)!,
          );
          break;
        case "bridgefyDidSendMessage":
          _delegate?.bridgefyDidSendMessage(messageID: call.arguments['messageId'] as String);
          break;
        case "bridgefyDidFailSendingMessage":
          _delegate?.bridgefyDidFailSendingMessage(
            messageID: call.arguments['messageId'] as String,
            error: _errorFromResult(call.arguments)!,
          );
          break;
        case "bridgefyDidReceiveData":
          _delegate?.bridgefyDidReceiveData(
            data: call.arguments['data'] as Uint8List,
            messageId: call.arguments['messageId'] as String,
            transmissionMode: _transmissionModeFromResult(call.arguments)!,
          );
          break;
        default:
          break;
      }
    });
  }
}
