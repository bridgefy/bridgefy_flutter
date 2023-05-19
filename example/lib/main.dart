import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bridgefy/bridgefy.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements BridgefyDelegate {
  String apiKey = "APIKEY";
  final _bridgefy = Bridgefy();
  bool _didStart = false;
  String _buttonText = 'Start';
  String _logStr = '';

  @override
  void initState() {
    super.initState();
    Permission.locationAlways.request().then((value) async {
      try {
        await _bridgefy.initialize(
          apiKey: apiKey,
          propagationProfile: BridgefyPropagationProfile.longReach,
          delegate: this,
        );
      } catch (e) {
        _log("Unable to initialize: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bridgefy'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: _toggleStart, child: Text(_buttonText)),
                    const SizedBox(width: 10),
                    ElevatedButton(onPressed: _send, child: const Text("Send data")),
                  ],
                ),
                const SizedBox(height: 10),
                const Text("Log", style: TextStyle(fontWeight: FontWeight.bold)),
                SingleChildScrollView(
                  child: Text(_logStr),
                ),
              ],
            ),
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
    _log("Sent message with ID: $lastMessageId");
  }

  @override
  void bridgefyDidConnect({required String userID}) {
    _log("bridgefyDidConnect");
  }

  @override
  void bridgefyDidDestroySession() {
    _log("bridgefyDidDestroySession");
  }

  @override
  void bridgefyDidDisconnect({required String userID}) {
    _log("bridgefyDidDisconnect: $userID");
  }

  @override
  void bridgefyDidEstablishSecureConnection({required String userID}) {
    _log("bridgefyDidEstablishSecureConnection: $userID");
  }

  @override
  void bridgefyDidFailSendingMessage({required String messageID, BridgefyError? error}) {
    _log("bridgefyDidFailSendingMessage: $messageID, $error");
  }

  @override
  void bridgefyDidFailToDestroySession() {
    _log("bridgefyDidFailToDestroySession");
  }

  @override
  void bridgefyDidFailToEstablishSecureConnection({
    required String userID,
    required BridgefyError error,
  }) {
    _log("bridgefyDidFailToEstablishSecureConnection: $userID, $error");
  }

  @override
  void bridgefyDidFailToStart({required BridgefyError error}) {
    _log("bridgefyDidFailToStart: $error");
  }

  @override
  void bridgefyDidFailToStop({required BridgefyError error}) {
    _log("bridgefyDidFailToStop: $error");
  }

  @override
  void bridgefyDidReceiveData({
    required Uint8List data,
    required String messageId,
    required BridgefyTransmissionMode transmissionMode,
  }) {
    _log("bridgefyDidReceiveData: $data, $messageId, $transmissionMode");
  }

  @override
  void bridgefyDidSendMessage({required String messageID}) {
    _log("bridgefyDidSendMessage: $messageID");
  }

  @override
  void bridgefyDidStart({required String currentUserID}) {
    _log("bridgefyDidStart: $currentUserID");
    setState(() {
      _didStart = true;
      _buttonText = 'Stop';
    });
  }

  @override
  void bridgefyDidStop() {
    _log("bridgefyDidStop");
    setState(() {
      _didStart = false;
      _buttonText = 'Start';
    });
  }

  @override
  void bridgefyDidSendDataProgress({
    required String messageID,
    required int position,
    required int of,
  }) {
    _log("bridgefyDidSendDataProgress: $messageID, $position, $of");
  }

  void _log(String text) {
    setState(() {
      _logStr += "$text\n";
    });
  }
}
