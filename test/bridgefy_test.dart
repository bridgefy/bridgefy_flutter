import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:bridgefy/bridgefy.dart';
import 'package:bridgefy/bridgefy_platform_interface.dart';
import 'package:bridgefy/bridgefy_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBridgefyPlatform
    with MockPlatformInterfaceMixin
    implements BridgefyPlatform {
  @override
  Future<List<String>> get connectedPeers => Future.value([
        "92cb1869-c31f-43e3-bca3-1bc627e99a6e",
        "6d3c37a0-40c4-4c7e-a3ac-9bba19ab2a72"
      ]);

  @override
  Future<String> get currentUserID =>
      Future.value("92cb1869-c31f-43e3-bca3-1bc627e99a6e");

  @override
  Future<void> destroySession() {
    throw UnimplementedError();
  }

  @override
  Future<void> establishSecureConnection({required String userID}) {
    throw UnimplementedError();
  }

  @override
  Future<void> initialize({
    required String apiKey,
    required BridgefyDelegate delegate,
    BridgefyPropagationProfile propagationProfile =
        BridgefyPropagationProfile.standard,
    bool verboseLogging = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<DateTime?> get licenseExpirationDate =>
      Future.value(DateTime.fromMillisecondsSinceEpoch(1684211697000));

  @override
  Future<String> send({
    required Uint8List data,
    required BridgefyTransmissionMode transmissionMode,
  }) {
    return Future.value("92cb1869-c31f-43e3-bca3-1bc627e99a6e");
  }

  @override
  Future<void> start({
    String? userId,
    BridgefyPropagationProfile propagationProfile =
        BridgefyPropagationProfile.standard,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> stop() {
    throw UnimplementedError();
  }

  @override
  Future<void> updateLicense() {
    throw UnimplementedError();
  }

  @override
  bool get isInitialized => throw UnimplementedError();

  @override
  bool get isStarted => throw UnimplementedError();
}

void main() {
  final BridgefyPlatform initialPlatform = BridgefyPlatform.instance;

  test('$MethodChannelBridgefy is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBridgefy>());
  });

  test('connectedPeers', () async {
    Bridgefy bridgefyPlugin = Bridgefy();
    MockBridgefyPlatform fakePlatform = MockBridgefyPlatform();
    BridgefyPlatform.instance = fakePlatform;

    expect(
      await bridgefyPlugin.connectedPeers,
      [
        "92cb1869-c31f-43e3-bca3-1bc627e99a6e",
        "6d3c37a0-40c4-4c7e-a3ac-9bba19ab2a72"
      ],
    );
  });

  test('currentUserID', () async {
    Bridgefy bridgefyPlugin = Bridgefy();
    MockBridgefyPlatform fakePlatform = MockBridgefyPlatform();
    BridgefyPlatform.instance = fakePlatform;

    expect(await bridgefyPlugin.currentUserID,
        "92cb1869-c31f-43e3-bca3-1bc627e99a6e");
  });

  test('licenseExpirationDate', () async {
    Bridgefy bridgefyPlugin = Bridgefy();
    MockBridgefyPlatform fakePlatform = MockBridgefyPlatform();
    BridgefyPlatform.instance = fakePlatform;

    expect(
      await bridgefyPlugin.licenseExpirationDate,
      DateTime.fromMillisecondsSinceEpoch(1684211697000),
    );
  });

  test('send', () async {
    Bridgefy bridgefyPlugin = Bridgefy();
    MockBridgefyPlatform fakePlatform = MockBridgefyPlatform();
    BridgefyPlatform.instance = fakePlatform;

    expect(
      await bridgefyPlugin.send(
        data: Uint8List(0),
        transmissionMode: BridgefyTransmissionMode(
          type: BridgefyTransmissionModeType.broadcast,
          uuid: "6d3c37a0-40c4-4c7e-a3ac-9bba19ab2a72",
        ),
      ),
      "92cb1869-c31f-43e3-bca3-1bc627e99a6e",
    );
  });
}
