import 'package:bridgefy/bridgefy.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bridgefy/bridgefy_method_channel.dart';

import 'test_delegate.dart';

void main() {
  MethodChannelBridgefy platform = MethodChannelBridgefy();
  const MethodChannel channel = MethodChannel('bridgefy');

  TestWidgetsFlutterBinding.ensureInitialized();

  handler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'send':
        return {"messageId": "edab9506-b7ab-4f45-b460-7a691c3e0134"};
      case 'connectedPeers':
        return {
          "connectedPeers": [
            "92cb1869-c31f-43e3-bca3-1bc627e99a6e",
            "6d3c37a0-40c4-4c7e-a3ac-9bba19ab2a72"
          ],
        };
      case 'currentUserID':
        return {"userId": "92cb1869-c31f-43e3-bca3-1bc627e99a6e"};
      case 'licenseExpirationDate':
        return {"licenseExpirationDate": 1684211697000};
      default:
        return null;
    }
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
      [
        "92cb1869-c31f-43e3-bca3-1bc627e99a6e",
        "6d3c37a0-40c4-4c7e-a3ac-9bba19ab2a72"
      ],
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

  test('bridgefyDidStart', () async {
    final delegate = TestDelegate();
    await platform.initialize(apiKey: "test", delegate: delegate);
    platform.delegateCallHandler(
      const MethodCall('bridgefyDidStart',
          {"userId": "6d3c37a0-40c4-4c7e-a3ac-9bba19ab2a72"}),
    );
    expect(delegate.result, "6d3c37a0-40c4-4c7e-a3ac-9bba19ab2a72");
  });

  test('bridgefyDidDestroySession', () async {
    final delegate = TestDelegate();
    await platform.initialize(apiKey: "test", delegate: delegate);
    platform.delegateCallHandler(
      const MethodCall('bridgefyDidDestroySession'),
    );
    expect(delegate.result, "bridgefyDidDestroySession");
  });

  test('bridgefyDidDisconnect', () async {
    final delegate = TestDelegate();
    await platform.initialize(apiKey: "test", delegate: delegate);
    platform.delegateCallHandler(
      const MethodCall('bridgefyDidDisconnect',
          {"userId": "6d3c37a0-40c4-4444-a3ac-9bba19ab2a72"}),
    );
    expect(delegate.result, "6d3c37a0-40c4-4444-a3ac-9bba19ab2a72");
  });

  test('bridgefyDidEstablishSecureConnection', () async {
    final delegate = TestDelegate();
    await platform.initialize(apiKey: "test", delegate: delegate);
    platform.delegateCallHandler(
      const MethodCall(
        'bridgefyDidEstablishSecureConnection',
        {"userId": "c7273a7f-481d-485a-9872-be79404f8003"},
      ),
    );
    expect(delegate.result, "c7273a7f-481d-485a-9872-be79404f8003");
  });

  test('bridgefyDidFailSendingMessage', () async {
    final delegate = TestDelegate();
    await platform.initialize(apiKey: "test", delegate: delegate);
    platform.delegateCallHandler(
      const MethodCall(
        'bridgefyDidFailSendingMessage',
        {
          "messageId": "9fe6b168-eea1-4f9d-8770-8066d9fa0a43",
          "error": {"code": "encodingError", "message": "test", "details": null}
        },
      ),
    );
    expect(
        delegate.result["messageID"], "9fe6b168-eea1-4f9d-8770-8066d9fa0a43");
    final error = delegate.result["error"] as BridgefyError;
    expect(error.type, BridgefyErrorType.encodingError);
    expect(error.message, "test");
    expect(error.code, null);
  });

  test('bridgefyDidFailToDestroySession', () async {
    final delegate = TestDelegate();
    await platform.initialize(apiKey: "test", delegate: delegate);
    platform.delegateCallHandler(
      const MethodCall('bridgefyDidFailToDestroySession'),
    );
    expect(delegate.result, "bridgefyDidFailToDestroySession");
  });

  test('bridgefyDidFailToEstablishSecureConnection', () async {
    final delegate = TestDelegate();
    await platform.initialize(apiKey: "test", delegate: delegate);
    platform.delegateCallHandler(
      const MethodCall(
        'bridgefyDidFailToEstablishSecureConnection',
        {
          "userId": "9fe6b168-eea1-4f9d-8770-8066d9fa0a43",
          "error": {
            "code": "cannotCreateSecureConnection",
            "message": "test",
            "details": 0
          }
        },
      ),
    );
    expect(delegate.result["userID"], "9fe6b168-eea1-4f9d-8770-8066d9fa0a43");
    final error = delegate.result["error"] as BridgefyError;
    expect(error.type, BridgefyErrorType.cannotCreateSecureConnection);
    expect(error.message, "test");
    expect(error.code, 0);
  });

  test('bridgefyDidFailToStart', () async {
    final delegate = TestDelegate();
    await platform.initialize(apiKey: "test", delegate: delegate);
    platform.delegateCallHandler(
      const MethodCall(
        'bridgefyDidFailToStart',
        {
          "error": {
            "code": "serviceNotStarted",
            "message": "test",
            "details": 0
          }
        },
      ),
    );
    final error = delegate.result["error"] as BridgefyError;
    expect(error.type, BridgefyErrorType.serviceNotStarted);
    expect(error.message, "test");
    expect(error.code, 0);
  });

  test('bridgefyDidFailToStop', () async {
    final delegate = TestDelegate();
    await platform.initialize(apiKey: "test", delegate: delegate);
    platform.delegateCallHandler(
      const MethodCall(
        'bridgefyDidFailToStop',
        {
          "error": {
            "code": "serviceNotStarted",
            "message": "test",
            "details": 0
          }
        },
      ),
    );
    final error = delegate.result["error"] as BridgefyError;
    expect(error.type, BridgefyErrorType.serviceNotStarted);
    expect(error.message, "test");
    expect(error.code, 0);
  });

  test('bridgefyDidReceiveData', () async {
    final delegate = TestDelegate();
    await platform.initialize(apiKey: "test", delegate: delegate);
    platform.delegateCallHandler(
      MethodCall(
        'bridgefyDidReceiveData',
        {
          "data": Uint8List(0),
          "messageId": "5c2160a6-2581-4c36-a7fb-2aedb8798976",
          "transmissionMode": const {
            "mode": "p2p",
            "uuid": "dd438451-50f5-49c9-b13a-f3baf51a6580",
          }
        },
      ),
    );
    expect(delegate.result["data"], Uint8List(0));
    final mode =
        delegate.result["transmissionMode"] as BridgefyTransmissionMode;
    expect(mode.type, BridgefyTransmissionModeType.p2p);
    expect(mode.uuid, "dd438451-50f5-49c9-b13a-f3baf51a6580");
  });

  test('bridgefyDidSendDataProgress', () async {
    final delegate = TestDelegate();
    await platform.initialize(apiKey: "test", delegate: delegate);
    platform.delegateCallHandler(
      const MethodCall(
        'bridgefyDidSendDataProgress',
        {
          "messageId": "5c2160a6-2581-4c36-a7fb-2aedb8798976",
          "position": 5,
          "of": 7
        },
      ),
    );
    expect(
        delegate.result["messageID"], "5c2160a6-2581-4c36-a7fb-2aedb8798976");
    expect(delegate.result["position"], 5);
    expect(delegate.result["of"], 7);
  });

  test('bridgefyDidSendMessage', () async {
    final delegate = TestDelegate();
    await platform.initialize(apiKey: "test", delegate: delegate);
    platform.delegateCallHandler(
      const MethodCall(
        'bridgefyDidSendMessage',
        {
          "messageId": "6c038bf6-a847-4c16-8e65-c57d98bec74a",
        },
      ),
    );
    expect(delegate.result, "6c038bf6-a847-4c16-8e65-c57d98bec74a");
  });

  test('bridgefyDidStop', () async {
    final delegate = TestDelegate();
    await platform.initialize(apiKey: "test", delegate: delegate);
    platform.delegateCallHandler(
      const MethodCall('bridgefyDidStop'),
    );
    expect(delegate.result, "bridgefyDidStop");
  });
}
