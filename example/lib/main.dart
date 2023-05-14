import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bridgefy/bridgefy.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements BridgefyDelegate {
  String apiKey = "<api_key>";
  final _bridgefy = Bridgefy();
  bool _didStart = false;
  String _buttonText = 'Start';
  String? _uuid;
  String? _lastMessageId;

  @override
  void initState() {
    super.initState();
    _bridgefy.initialize(apiKey: apiKey, delegate: this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(onPressed: _toggleStart, child: Text(_buttonText)),
              const SizedBox(height: 48),
              ElevatedButton(onPressed: _send, child: const Text("Send")),
              Text("UUID: $_uuid"),
              Text("Last sent message ID: $_lastMessageId"),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleStart() {
    if (!_didStart) {
      _bridgefy.start();
    } else {
      _bridgefy.stop();
    }
  }

  void _send() async {
    final lastMessageId = await _bridgefy.send(
      data: Uint8List.fromList([0, 1, 2, 3]),
      transmissionMode: BridgefyTransmissionMode(
        type: BridgefyTransmissionModeType.broadcast,
        uuid: await _bridgefy.currentUserID,
      ),
    );
    setState(() {
      _lastMessageId = lastMessageId;
    });
  }

  @override
  void bridgefyDidConnect({required String userID}) {
    print("bridgefyDidConnect");
  }

  @override
  void bridgefyDidDestroySession() {
    print("bridgefyDidDestroySession");
  }

  @override
  void bridgefyDidDisconnect({required String userID}) {
    print("bridgefyDidDisconnect: $userID");
  }

  @override
  void bridgefyDidEstablishSecureConnection({required String userID}) {
    print("bridgefyDidEstablishSecureConnection: $userID");
  }

  @override
  void bridgefyDidFailSendingMessage({required String messageID, BridgefyError? error}) {
    print("bridgefyDidFailSendingMessage: $messageID, $error");
  }

  @override
  void bridgefyDidFailToDestroySession() {
    print("bridgefyDidFailToDestroySession");
  }

  @override
  void bridgefyDidFailToEstablishSecureConnection({
    required String userID,
    required BridgefyError error,
  }) {
    print("bridgefyDidFailToEstablishSecureConnection: $userID, $error");
  }

  @override
  void bridgefyDidFailToStart({required BridgefyError error}) {
    print("bridgefyDidFailToStart: $error");
  }

  @override
  void bridgefyDidFailToStop({required BridgefyError error}) {
    print("bridgefyDidFailToStop: $error");
  }

  @override
  void bridgefyDidReceiveData({
    required Uint8List data,
    required String messageId,
    required BridgefyTransmissionMode transmissionMode,
  }) {
    print("bridgefyDidReceiveData: $data, $messageId, $transmissionMode");
  }

  @override
  void bridgefyDidSendMessage({required String messageID}) {
    print("bridgefyDidSendMessage: $messageID");
  }

  @override
  void bridgefyDidStart({required String currentUserID}) {
    print("bridgefyDidStart: $currentUserID");
    setState(() {
      _didStart = true;
      _buttonText = 'Stop';
      _uuid = currentUserID;
    });
  }

  @override
  void bridgefyDidStop() {
    print("bridgefyDidStop");
    setState(() {
      _didStart = false;
      _buttonText = 'Start';
      _uuid = null;
    });
  }

  @override
  void bridgefyDidSendDataProgress({
    required String messageID,
    required int position,
    required int of,
  }) {
    print("bridgefyDidSendDataProgress: $messageID, $position, $of");
  }
}
