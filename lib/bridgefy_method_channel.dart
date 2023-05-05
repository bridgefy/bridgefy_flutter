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
  void start({required String apiKey, required BridgefyDelegate delegate}) {
    _delegate = delegate;
    methodChannel.invokeMethod('start', apiKey);
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "bridgefyDidStart":
          _delegate?.bridgefyDidStart(currentUserID: call.arguments as String);
        break;
        case "bridgefyDidFailToStart":
          _delegate?.bridgefyDidFailToStart(error: call.arguments as Error);
        break;
        default:
        break;
      }
    });
  }

  @override
  void send({required Uint8List data}) {
    methodChannel.invokeMethod('send', data);
  }

  @override
  void stop() {
    methodChannel.invokeMethod('stop');
  }
}
