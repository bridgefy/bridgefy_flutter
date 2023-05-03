import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bridgefy/bridgefy_method_channel.dart';

void main() {
  MethodChannelBridgefy platform = MethodChannelBridgefy();
  const MethodChannel channel = MethodChannel('bridgefy');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
