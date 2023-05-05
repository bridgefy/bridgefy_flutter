
import 'dart:typed_data';

import 'bridgefy_platform_interface.dart';

enum BridgefyTransmissionMode {
  p2p,
  mesh,
  broadcast
}

mixin BridgefyDelegate {
  void bridgefyDidStart({required String currentUserID});
  void bridgefyDidFailToStart({required Error error});
  void bridgefyDidConnect({required String userID});
  void bridgefyDidDisconnect({required String userID});
  void bridgefyDidSendMessage({required String messageID});
  void bridgefyDidFailSendingMessage({required String messageID, required Error error});
  void bridgefyDidReceiveData({
    required Uint8List data,
    required BridgefyTransmissionMode transmissionMode,
    String? userID
  });
}

class Bridgefy {
  void start({required String apiKey, required BridgefyDelegate delegate}) {
    return BridgefyPlatform.instance.start(apiKey: apiKey, delegate: delegate);
  }

  void send({required Uint8List data}) {
    return BridgefyPlatform.instance.send(data: data);
  }

  void stop() {
    return BridgefyPlatform.instance.stop();
  }
}
