import 'dart:core';

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
  bool _initialized = false;

  @override
  Future<void> initialize({
    required String apiKey,
    required BridgefyDelegate delegate,
    bool verboseLogging = false,
  }) async {
    try {
      await methodChannel.invokeMethod(
        'initialize',
        {
          "apiKey": apiKey,
          "verboseLogging": verboseLogging,
        },
      );
      _delegate = delegate;
      methodChannel.setMethodCallHandler(delegateCallHandler);
      _initialized = true;
    } on PlatformException catch (e) {
      throw _bridgefyException(e);
    }
  }

  @override
  Future<void> start({
    String? userId,
    BridgefyPropagationProfile propagationProfile =
        BridgefyPropagationProfile.standard,
  }) {
    assert(_initialized, 'Bridgefy is not initialized');
    return methodChannel.invokeMethod('start', {
      "userId": userId,
      "propagationProfile": propagationProfile.name,
    });
  }

  @override
  Future<String> send({
    required Uint8List data,
    required BridgefyTransmissionMode transmissionMode,
  }) async {
    assert(_initialized, 'Bridgefy is not initialized');
    try {
      final result = await methodChannel.invokeMethod(
        'send',
        {
          "data": data,
          "transmissionMode": {
            "mode": transmissionMode.type.name,
            "uuid": transmissionMode.uuid
          },
        },
      );
      return result["messageId"] as String;
    } on PlatformException catch (e) {
      throw _bridgefyException(e);
    }
  }

  @override
  Future<void> stop() {
    assert(_initialized, 'Bridgefy is not initialized');
    return methodChannel.invokeMethod('stop');
  }

  @override
  Future<List<String>> get connectedPeers async {
    assert(_initialized, 'Bridgefy is not initialized');
    final result = await methodChannel.invokeMethod('connectedPeers');
    return (result["connectedPeers"] as List).map((e) => e.toString()).toList();
  }

  @override
  Future<String> get currentUserID async {
    assert(_initialized, 'Bridgefy is not initialized');
    final result = await methodChannel.invokeMethod('currentUserID');
    return result["userId"] as String;
  }

  @override
  Future<void> establishSecureConnection({required String userID}) {
    assert(_initialized, 'Bridgefy is not initialized');
    return methodChannel
        .invokeMethod('establishSecureConnection', {"userId": userID});
  }

  @override
  Future<DateTime?> get licenseExpirationDate async {
    assert(_initialized, 'Bridgefy is not initialized');
    final result = await methodChannel.invokeMethod('licenseExpirationDate');
    final interval = result["licenseExpirationDate"].toInt();
    if (interval != null) {
      return DateTime.fromMillisecondsSinceEpoch(interval);
    }
    return null;
  }

  @override
  Future<void> destroySession() {
    assert(_initialized, 'Bridgefy is not initialized');
    return methodChannel.invokeMethod('destroySession');
  }

  @override
  Future<void> updateLicense() {
    assert(_initialized, 'Bridgefy is not initialized');
    return methodChannel.invokeMethod('updateLicense');
  }

  BridgefyTransmissionMode _transmissionMode(dynamic result) {
    return BridgefyTransmissionMode(
      type: BridgefyTransmissionModeType.values
          .byName(result["transmissionMode"]["mode"]),
      uuid: result["transmissionMode"]["uuid"],
    );
  }

  BridgefyError? _bridgefyError(dynamic result) {
    if (result["error"] != null) {
      return BridgefyError(
        type: BridgefyErrorType.values.byName(result["error"]["code"]),
        code: result["error"]["details"],
        message: result["error"]["message"],
      );
    }
    return null;
  }

  BridgefyError _bridgefyException(PlatformException exception) {
    return BridgefyError(
      type: BridgefyErrorType.values.byName(exception.code),
      code: exception.details,
      message: exception.message,
    );
  }

  @visibleForTesting
  Future<dynamic> delegateCallHandler(MethodCall call) async {
    switch (call.method) {
      case "bridgefyDidStart":
        _delegate?.bridgefyDidStart(
            currentUserID: call.arguments['userId'] as String);
        break;
      case "bridgefyDidFailToStart":
        _delegate?.bridgefyDidFailToStart(
          error: _bridgefyError(call.arguments)!,
        );
        break;
      case "bridgefyDidStop":
        _delegate?.bridgefyDidStop();
        break;
      case "bridgefyDidFailToStop":
        _delegate?.bridgefyDidFailToStop(
          error: _bridgefyError(call.arguments)!,
        );
        break;
      case "bridgefyDidDestroySession":
        _delegate?.bridgefyDidDestroySession();
        break;
      case "bridgefyDidFailToDestroySession":
        _delegate?.bridgefyDidFailToDestroySession();
        break;
      case "bridgefyDidConnect":
        _delegate?.bridgefyDidConnect(
            userID: call.arguments['userId'] as String);
        break;
      case "bridgefyDidDisconnect":
        _delegate?.bridgefyDidDisconnect(
            userID: call.arguments['userId'] as String);
        break;
      case "bridgefyDidEstablishSecureConnection":
        _delegate?.bridgefyDidEstablishSecureConnection(
            userID: call.arguments['userId'] as String);
        break;
      case "bridgefyDidFailToEstablishSecureConnection":
        _delegate?.bridgefyDidFailToEstablishSecureConnection(
          userID: call.arguments['userId'] as String,
          error: _bridgefyError(call.arguments)!,
        );
        break;
      case "bridgefyDidSendMessage":
        _delegate?.bridgefyDidSendMessage(
            messageID: call.arguments['messageId'] as String);
        break;
      case "bridgefyDidFailSendingMessage":
        _delegate?.bridgefyDidFailSendingMessage(
          messageID: call.arguments['messageId'] as String,
          error: _bridgefyError(call.arguments),
        );
        break;
      case "bridgefyDidReceiveData":
        _delegate?.bridgefyDidReceiveData(
          data: call.arguments['data'] as Uint8List,
          messageId: call.arguments['messageId'] as String,
          transmissionMode: _transmissionMode(call.arguments),
        );
        break;
      case "bridgefyDidSendDataProgress":
        _delegate?.bridgefyDidSendDataProgress(
          messageID: call.arguments['messageId'] as String,
          position: call.arguments['position'] as int,
          of: call.arguments['of'] as int,
        );
        break;
      default:
        break;
    }
  }
}
