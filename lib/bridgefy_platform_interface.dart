import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bridgefy_method_channel.dart';

abstract class BridgefyPlatform extends PlatformInterface {
  /// Constructs a BridgefyPlatform.
  BridgefyPlatform() : super(token: _token);

  static final Object _token = Object();

  static BridgefyPlatform _instance = MethodChannelBridgefy();

  /// The default instance of [BridgefyPlatform] to use.
  ///
  /// Defaults to [MethodChannelBridgefy].
  static BridgefyPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BridgefyPlatform] when
  /// they register themselves.
  static set instance(BridgefyPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
