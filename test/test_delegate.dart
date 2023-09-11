import 'dart:typed_data';

import 'package:bridgefy/bridgefy.dart';

class TestDelegate implements BridgefyDelegate {
  dynamic result;

  @override
  void bridgefyDidConnect({required String userID}) {
    result = userID;
  }

  @override
  void bridgefyDidDestroySession() {
    result = 'bridgefyDidDestroySession';
  }

  @override
  void bridgefyDidDisconnect({required String userID}) {
    result = userID;
  }

  @override
  void bridgefyDidEstablishSecureConnection({required String userID}) {
    result = userID;
  }

  @override
  void bridgefyDidFailSendingMessage(
      {required String messageID, BridgefyError? error}) {
    result = {"messageID": messageID, "error": error};
  }

  @override
  void bridgefyDidFailToDestroySession() {
    result = 'bridgefyDidFailToDestroySession';
  }

  @override
  void bridgefyDidFailToEstablishSecureConnection({
    required String userID,
    required BridgefyError error,
  }) {
    result = {"userID": userID, "error": error};
  }

  @override
  void bridgefyDidFailToStart({required BridgefyError error}) {
    result = {"error": error};
  }

  @override
  void bridgefyDidFailToStop({required BridgefyError error}) {
    result = {"error": error};
  }

  @override
  void bridgefyDidReceiveData({
    required Uint8List data,
    required String messageId,
    required BridgefyTransmissionMode transmissionMode,
  }) {
    result = {
      "data": data,
      "messageId": messageId,
      "transmissionMode": transmissionMode
    };
  }

  @override
  void bridgefyDidSendDataProgress({
    required String messageID,
    required int position,
    required int of,
  }) {
    result = {"messageID": messageID, "position": position, "of": of};
  }

  @override
  void bridgefyDidSendMessage({required String messageID}) {
    result = messageID;
  }

  @override
  void bridgefyDidStart({required String currentUserID}) {
    result = currentUserID;
  }

  @override
  void bridgefyDidStop() {
    result = 'bridgefyDidStop';
  }
}
