import 'dart:async';

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
  String apiKey = "YOUR_API_KEY_HERE";
  final _bridgefy = Bridgefy();
  bool _didStart = false;
  String _logStr = '';
  final Color _bfColor = const Color(0x00FF4040);
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _goToEnd() {
    Timer(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.linear,
      );
    });
  }

  Future<void> checkPermissions() async {
    await [
      Permission.location,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
  }

  @override
  void initState() {
    super.initState();
    checkPermissions().then((value) async {
      try {
        //you can validate if there is already an initialized instance to avoid an error in case it already exists
        final isInitialized = await _bridgefy.isInitialized;
        _didStart = await _bridgefy.isStarted;
        if (!isInitialized){
          await _bridgefy.initialize(
            apiKey: apiKey,
            delegate: this,
            verboseLogging: true,
          );
        }
      } catch (e) {
        _log("Unable to initialize: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return MaterialApp(
      theme: ThemeData(
        primaryColor: _bfColor,
        colorScheme: ColorScheme.fromSeed(seedColor: _bfColor),
      ),
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
                    ElevatedButton.icon(
                        icon: _didStart
                            ? const Icon(Icons.stop_circle)
                            : const Icon(Icons.check_circle),
                        onPressed: _toggleStart,
                        label: Text(_didStart ? "Stop" : "Start")),
                    const SizedBox(width: 7),
                    ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        onPressed: _didStart ? _send : null,
                        label: const Text("Send")),
                    const SizedBox(width: 7),
                    ElevatedButton.icon(
                        icon: const Icon(Icons.delete_forever),
                        onPressed: _logStr != '' ? _clearLogs : null,
                        label: const Text("Logs")),
                  ],
                ),
                const SizedBox(height: 10),
                const Text("Logs",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: SafeArea(
                    bottom: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Text(_logStr),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _clearLogs() {
    setState(() {
      _logStr = "";
    });
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
    _log("bridgefyDidConnect: $userID");
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
  void bridgefyDidFailSendingMessage(
      {required String messageID, BridgefyError? error}) {
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
    });
  }

  @override
  void bridgefyDidStop() {
    _log("bridgefyDidStop");
    setState(() {
      _didStart = false;
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
    _goToEnd();
    setState(() {
      _logStr += "$text\n";
    });
  }
}
