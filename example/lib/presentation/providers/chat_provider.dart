import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:bridgefy/bridgefy.dart';
import 'package:bridgefy_example/domain/entities/message.dart';
import 'package:bridgefy_example/presentation/providers/sdk_provider.dart';

class ChatProvider extends ChangeNotifier {
  SdkProvider? _sdkProvider;
  String userId = '';
  void setSDK(SdkProvider sdkProvider){
    _sdkProvider = sdkProvider;
    userId = _sdkProvider!.userId;
    final newMessage = _sdkProvider?.newMessage;
    if (newMessage!=null){
      _sdkProvider!.resetNewMessage();
      _addMessage(newMessage);
    }
  }
  final ScrollController chatScrollController = ScrollController();
  final BridgefyTransmissionModeType transmissionModeType = BridgefyTransmissionModeType.broadcast;
  final _bridgefy = Bridgefy();

  List<Message> messageList = [];

  void _addMessage(Message newMessage){
    messageList.add(newMessage);
    notifyListeners();
    if (_sdkProvider!.tabIndex==1){
      moveScrollToBottom();
    }
  }
  Uint8List _encodeData(String text){
    return const Utf8Encoder().convert(text);
  }

  Future<void> sendMessage( String text ) async {
    if (text.isEmpty) return;
    if (userId.isEmpty){
      userId = _sdkProvider!.userId;
    }

    await _bridgefy.send(
      data: _encodeData(text),
      transmissionMode: BridgefyTransmissionMode(
        type: transmissionModeType,
        uuid: await _bridgefy.currentUserID,
      ),
    );
    final newMessage = Message(text: text, origin: OriginMessage.me);
    _addMessage(newMessage);
  }

  Future<void> moveScrollToBottom() async{
    await Future.delayed(const Duration(milliseconds: 100));

    chatScrollController.animateTo(
      chatScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut
    );
  }
}