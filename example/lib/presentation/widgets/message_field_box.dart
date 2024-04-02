import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bridgefy_example/presentation/providers/sdk_provider.dart';

class MessageFieldBox extends StatelessWidget {
  final ValueChanged<String> onValue;
  const MessageFieldBox({
    super.key,
    required this.onValue,
  });

  @override
  Widget build(BuildContext context) {
    final sdkProvider = context.watch<SdkProvider>();

    final textController = TextEditingController();
    final focusNode = FocusNode();
    final outlineInputBorder = UnderlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(10),
    );
    final inputDecoration = InputDecoration(
      enabled: sdkProvider.isStarted,
      hintText: 'Type your message',
      hintStyle: const TextStyle(
        color: Colors.grey,
      ),
      enabledBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
      filled: true,
      suffixIcon: IconButton(
        icon: const Icon(Icons.send_outlined),
        onPressed: (){
          final textValue = textController.value.text;
          textController.clear();
          onValue(textValue);
        },
      ),
    );

    return TextFormField(
      controller: textController,
      decoration: inputDecoration,
      focusNode: focusNode,
      onFieldSubmitted: (value){
        textController.clear();
        focusNode.requestFocus();
        onValue(value);
      },
      // onTapOutside: (event){
      //   focusNode.unfocus();
      // },
    );
  }
}