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
  Future<void> initialize(
      {required String apiKey,
      required BridgefyDelegate delegate,
      BridgefyPropagationProfile propagationProfile = BridgefyPropagationProfile.standard,
      bool verboseLogging = false}) async {
    final value = await methodChannel.invokeMethod('initialize', {
      "apiKey": apiKey,
      "propagationProfile": propagationProfile.name,
      "verboseLogging": verboseLogging,
    });
    _throwIfError(value);
    _configureDelegate(delegate);
  }

  @override
  Future<void> start() {
    return methodChannel.invokeMethod('start');
  }

  @override
  Future<String> send(
      {required Uint8List data,
      required BridgefyTransmissionMode transmissionMode,
      String? userID}) {
    return methodChannel.invokeMethod(
            'send', {"data": data, "transmissionMode": transmissionMode.name, "userID": userID})
        as Future<String>;
  }

  @override
  Future<void> stop() {
    return methodChannel.invokeMethod('stop');
  }

  @override
  Future<List<String>> get connectedPeers =>
      methodChannel.invokeMethod('connectedPeers') as Future<List<String>>;

  @override
  Future<String> get currentUserID => methodChannel.invokeMethod('currentUserID') as Future<String>;

  @override
  Future<void> establishSecureConnection({required String userID}) {
    return methodChannel.invokeMethod('establishSecureConnection', {"userID": userID});
  }

  @override
  Future<DateTime> get licenseExpirationDate =>
      methodChannel.invokeMethod('licenseExpirationDate') as Future<DateTime>;

  void _throwIfError(dynamic result) {
    if (result is Map && result.containsKey("error")) {
      final error = result["error"];
      throw BridgefyError(name: error["type"], code: error["code"]);
    }
  }

  void _configureDelegate(BridgefyDelegate delegate) {
    _delegate = delegate;
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "bridgefyDidStart":
          _delegate?.bridgefyDidStart(currentUserID: call.arguments as String);
          break;
        case "bridgefyDidFailToStart":
          _delegate?.bridgefyDidFailToStart(error: call.arguments as BridgefyError);
          break;
        default:
          break;
      }
    });
  }
}
