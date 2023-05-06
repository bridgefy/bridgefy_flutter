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
  void start() {
    methodChannel.invokeMethod('start');
  }

  @override
  void send(
      {required Uint8List data,
      required BridgefyTransmissionMode transmissionMode,
      String? userID}) {
    methodChannel.invokeMethod(
        'send', {"data": data, "transmissionMode": transmissionMode.name, "userID": userID});
  }

  @override
  void stop() {
    methodChannel.invokeMethod('stop');
  }

  void _throwIfError(dynamic result) {
    if (result is Map) {
      throw BridgefyError(name: result["error"], code: result["code"]);
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
