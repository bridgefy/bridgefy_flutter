import 'package:flutter_test/flutter_test.dart';
import 'package:bridgefy/bridgefy.dart';
import 'package:bridgefy/bridgefy_platform_interface.dart';
import 'package:bridgefy/bridgefy_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBridgefyPlatform
    with MockPlatformInterfaceMixin
    implements BridgefyPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BridgefyPlatform initialPlatform = BridgefyPlatform.instance;

  test('$MethodChannelBridgefy is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBridgefy>());
  });

  test('getPlatformVersion', () async {
    Bridgefy bridgefyPlugin = Bridgefy();
    MockBridgefyPlatform fakePlatform = MockBridgefyPlatform();
    BridgefyPlatform.instance = fakePlatform;

    expect(await bridgefyPlugin.getPlatformVersion(), '42');
  });
}
