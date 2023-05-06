import 'dart:typed_data';

import 'package:bridgefy/bridgefy.dart';
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

  Future<void> initialize(
      {required String apiKey,
      required BridgefyDelegate delegate,
      BridgefyPropagationProfile propagationProfile = BridgefyPropagationProfile.standard,
      bool verboseLogging = false}) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<void> start() {
    throw UnimplementedError('start() has not been implemented.');
  }

  Future<void> stop() {
    throw UnimplementedError('stop() has not been implemented.');
  }

  Future<void> destroySession() {
    throw UnimplementedError('destroySession() has not been implemented.');
  }

  Future<String> send(
      {required Uint8List data,
      required BridgefyTransmissionMode transmissionMode,
      String? userID}) {
    throw UnimplementedError('send() has not been implemented.');
  }

  Future<void> updateLicense() {
    throw UnimplementedError('updateLicense() has not been implemented.');
  }

  Future<void> establishSecureConnection({required String userID});

  Future<String> get currentUserID;

  Future<List<String>> get connectedPeers;

  Future<DateTime> get licenseExpirationDate;
}
