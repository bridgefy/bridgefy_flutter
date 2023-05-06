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
  String _platformVersion = 'Unknown';
  final _bridgefy = Bridgefy();

  @override
  void initState() {
    super.initState();
    // initPlatformState();
    _bridgefy.initialize(apiKey: "test", delegate: this);
    _bridgefy.start();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformState() async {
  //   String platformVersion;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   // We also handle the message potentially returning null.
  //   try {
  //     platformVersion =
  //         await _bridgefyPlugin.getPlatformVersion() ?? 'Unknown platform version';
  //   } on PlatformException {
  //     platformVersion = 'Failed to get platform version.';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }

  @override
  void bridgefyDidConnect({required String userID}) {
    // TODO: implement bridgefyDidConnect
  }

  @override
  void bridgefyDidDestroySession() {
    // TODO: implement bridgefyDidDestroySession
  }

  @override
  void bridgefyDidDisconnect({required String userID}) {
    // TODO: implement bridgefyDidDisconnect
  }

  @override
  void bridgefyDidEstablishSecureConnection({required String userID}) {
    // TODO: implement bridgefyDidEstablishSecureConnection
  }

  @override
  void bridgefyDidFailSendingMessage({required String messageID, required Error error}) {
    // TODO: implement bridgefyDidFailSendingMessage
  }

  @override
  void bridgefyDidFailToDestroySession() {
    // TODO: implement bridgefyDidFailToDestroySession
  }

  @override
  void bridgefyDidFailToEstablishSecureConnection(
      {required String userID, required BridgefyError error}) {
    // TODO: implement bridgefyDidFailToEstablishSecureConnection
  }

  @override
  void bridgefyDidFailToStart({required BridgefyError error}) {
    // TODO: implement bridgefyDidFailToStart
  }

  @override
  void bridgefyDidFailToStop({required BridgefyError error}) {
    // TODO: implement bridgefyDidFailToStop
  }

  @override
  void bridgefyDidReceiveData(
      {required Uint8List data,
      required BridgefyTransmissionMode transmissionMode,
      String? userID}) {
    // TODO: implement bridgefyDidReceiveData
  }

  @override
  void bridgefyDidSendMessage({required String messageID}) {
    // TODO: implement bridgefyDidSendMessage
  }

  @override
  void bridgefyDidStart({required String currentUserID}) {
    // TODO: implement bridgefyDidStart
  }

  @override
  void bridgefyDidStop() {
    // TODO: implement bridgefyDidStop
  }
}
