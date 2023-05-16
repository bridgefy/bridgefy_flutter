import 'package:bridgefy/bridgefy.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bridgefy/bridgefy_method_channel.dart';

void main() {
  MethodChannelBridgefy platform = MethodChannelBridgefy();
  const MethodChannel channel = MethodChannel('bridgefy');

  TestWidgetsFlutterBinding.ensureInitialized();

  handler(MethodCall methodCall) async {
    if (methodCall.method == 'send') {
      return {
        "messageId": "edab9506-b7ab-4f45-b460-7a691c3e0134",
      };
    } else if (methodCall.method == 'connectedPeers') {
      return {
        "connectedPeers": [
          "92cb1869-c31f-43e3-bca3-1bc627e99a6e",
          "6d3c37a0-40c4-4c7e-a3ac-9bba19ab2a72"
        ],
      };
    } else if (methodCall.method == 'currentUserID') {
      return {"userId": "92cb1869-c31f-43e3-bca3-1bc627e99a6e"};
    } else if (methodCall.method == 'licenseExpirationDate') {
      return {"licenseExpirationDate": 1684211697000};
    }
    return null;
  }

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, handler);

  test('start', () async {
    expect(
      await platform.send(
        data: Uint8List(0),
        transmissionMode: BridgefyTransmissionMode(
          type: BridgefyTransmissionModeType.p2p,
          uuid: "5782e755-f2d2-4df9-be85-82a88fe47315",
        ),
      ),
      "edab9506-b7ab-4f45-b460-7a691c3e0134",
    );
  });

  test('connectedPeers', () async {
    expect(
      await platform.connectedPeers,
      ["92cb1869-c31f-43e3-bca3-1bc627e99a6e", "6d3c37a0-40c4-4c7e-a3ac-9bba19ab2a72"],
    );
  });

  test('currentUserID', () async {
    expect(
      await platform.currentUserID,
      "92cb1869-c31f-43e3-bca3-1bc627e99a6e",
    );
  });

  test('licenseExpirationDate', () async {
    expect(
      await platform.licenseExpirationDate,
      DateTime.fromMillisecondsSinceEpoch(1684211697000),
    );
  });
}
