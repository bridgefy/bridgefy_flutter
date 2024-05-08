import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:bridgefy/bridgefy.dart';
import 'package:bridgefy_example/domain/entities/log.dart';
import 'package:bridgefy_example/domain/entities/message.dart';
import 'package:bridgefy_example/config/environment.dart';

class SdkProvider extends ChangeNotifier implements BridgefyDelegate {
  final _bridgefy = Bridgefy();
  final ScrollController logsScrollController = ScrollController();
  Message? newMessage;
  bool isInitialized = false;
  bool isStarted = false;
  bool permissionsGranted = false;
  String userId = '';
  int tabIndex = 0;
  List<Log> logList = [];

  void _addLog(Log newLog){
    logList.add(newLog);
    notifyListeners();
    if (tabIndex==0){
      moveScrollToBottom();
    }
  }
  Future<void> moveScrollToBottom() async{
    await Future.delayed(const Duration(milliseconds: 100));

    logsScrollController.animateTo(
      logsScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut
    );
  }
  Future<bool> _checkPermissions() async {
    final status = await [
      Permission.location,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
    if (Platform.isIOS) return true;
    
    bool granted = true;
    status.forEach((key, value) {
      if (value==PermissionStatus.permanentlyDenied || value==PermissionStatus.denied){
        granted = false;
        _addLog(Log(text: '$key is required', type: LogType.error));
      }
    });
    if (!granted){
      openAppSettings();
    }
    return granted;
  }

  Future<void> initialized() async {
    try {
      permissionsGranted = await _checkPermissions();
      if (!permissionsGranted || isInitialized){
        return;
      }
      await _bridgefy.initialize(
        apiKey: EnvironmentConfig.apiKey,
        delegate: this,
        verboseLogging: true,
      );
      isInitialized = await _bridgefy.isInitialized;
      notifyListeners();
    } catch (e) {
      _addLog(Log(text: 'Unable to initialize: $e', type: LogType.error));
    }
  }
  Future<void> start({
    String? userId,
    BridgefyPropagationProfile propagationProfile =
        BridgefyPropagationProfile.standard,
  }) async {
    if (!isInitialized || !permissionsGranted){
      await initialized();
    }
    if (!permissionsGranted){
      return;
    }
    assert(isInitialized, 'Bridgefy is not initialized');
    await _bridgefy.start();
    notifyListeners();
  }
  Future<void> stop() async {
    assert(isInitialized, 'Bridgefy is not initialized');
    assert(isStarted, 'Bridgefy is not started');
    await _bridgefy.stop();
    notifyListeners();
  }
  void resetNewMessage(){
    newMessage = null;
  }
  void clearLogs(){
    logList.clear();
    notifyListeners();
  }

  @override
  void bridgefyDidConnect({required String userID}) {
    _addLog(Log(text: 'A user with id $userID has connected', type: LogType.success));
  }
  @override
  void bridgefyDidEstablishSecureConnection({required String userID}) {
    _addLog(Log(text: 'didEstablishSecureConnection', type: LogType.normal));
  }
  @override
  void bridgefyDidDisconnect({required String userID}) {
    _addLog(Log(text: 'didDisconnect: $userID', type: LogType.finish));
  }
  @override
  void bridgefyDidDestroySession() {
    _addLog(Log(text: 'didDestroySession', type: LogType.normal));
  }

  @override
  void bridgefyDidStart({required String currentUserID}) {
    isStarted = true;
    userId = currentUserID;
    _addLog(Log(text: 'didStart: $currentUserID', type: LogType.success));
    notifyListeners();
  }
  @override
  void bridgefyDidStop() {
    isStarted = false;
    userId = '';
    _addLog(Log(text: 'bridgefyDidStop', type: LogType.finish));
    notifyListeners();
  }

  @override
  void bridgefyDidSendDataProgress({
    required String messageID,
    required int position,
    required int of,
  }) {
    _addLog(Log(text: 'didSendDataProgress: $messageID, $position, $of', type: LogType.normal));
  }
  @override
  void bridgefyDidSendMessage({required String messageID}) {
    _addLog(Log(text: 'sendMessage: $messageID', type: LogType.success));
  }

  @override
  void bridgefyDidReceiveData({
    required Uint8List data,
    required String messageId,
    required BridgefyTransmissionMode transmissionMode
  }) {
    final message = const Utf8Decoder().convert(data);
    newMessage = Message(text: message, origin: OriginMessage.other);
    _addLog(Log(text: 'didReceiveData: $data, $messageId, $transmissionMode', type: LogType.normal));
    notifyListeners();
  }

  @override
  void bridgefyDidFailSendingMessage({required String messageID, BridgefyError? error}) {
    _addLog(Log(text: 'didFailSendingMessage $messageID: $error', type: LogType.error));
  }
  @override
  void bridgefyDidFailToDestroySession() {
    _addLog(Log(text: 'didFailToDestroySession', type: LogType.error));
  }
  @override
  void bridgefyDidFailToEstablishSecureConnection({required String userID, required BridgefyError error}) {
    _addLog(Log(text: 'didFailToEstablishSecureConnection with $userID: $error', type: LogType.error));
  }
  @override
  void bridgefyDidFailToStart({required BridgefyError error}) {
    _addLog(Log(text: 'didFailToStart: $error', type: LogType.error));
  }
  @override
  void bridgefyDidFailToStop({required BridgefyError error}) {
    _addLog(Log(text: 'didFailToStop: $error', type: LogType.error));
  }
}