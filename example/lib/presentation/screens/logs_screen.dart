import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bridgefy_example/presentation/providers/sdk_provider.dart';
import 'package:bridgefy_example/presentation/widgets/log_row.dart';
import 'package:bridgefy_example/presentation/providers/chat_provider.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sdkProvider = context.watch<SdkProvider>();
    final chatProvider = context.watch<ChatProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  onPressed: !sdkProvider.isStarted ? null : (){
                    chatProvider.sendMessage('Hi!');
                  },
                  label: const Text('Send "Hi!"')
                ),
                const SizedBox(width: 7),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cleaning_services_outlined),
                  onPressed: (){
                    sdkProvider.clearLogs();
                  },
                  label: const Text("Clear logs")
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: sdkProvider.logsScrollController,
                itemCount: sdkProvider.logList.length,
                itemBuilder: (context, index){
                  final log = sdkProvider.logList[index];
              
                  return LogRow(log: log);
                }
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}