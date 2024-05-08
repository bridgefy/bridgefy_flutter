import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bridgefy_example/presentation/providers/chat_provider.dart';
import 'package:bridgefy_example/presentation/widgets/message_bubble.dart';
import 'package:bridgefy_example/presentation/widgets/message_field_box.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:10),
        child: Column(
          children: [
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                controller: chatProvider.chatScrollController,
                itemCount: chatProvider.messageList.length,
                itemBuilder: (context, index){
                  final message = chatProvider.messageList[index];
              
                  return MessageBubble(message: message);
                }
              ),
            ),
            MessageFieldBox(
              onValue: (value)=>chatProvider.sendMessage(value),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}