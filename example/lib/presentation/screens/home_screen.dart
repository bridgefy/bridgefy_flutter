import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bridgefy_example/presentation/providers/sdk_provider.dart';
import 'package:bridgefy_example/presentation/screens/logs_screen.dart';
import 'package:bridgefy_example/presentation/screens/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sdkProvider = context.watch<SdkProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ElevatedButton.icon(
                icon: sdkProvider.isStarted
                  ? const Icon(Icons.stop_circle)
                  : const Icon(Icons.check_circle),
                onPressed: (){
                  if (sdkProvider.isStarted){
                    sdkProvider.stop();
                  }else{
                    sdkProvider.start();
                  }
                },
                label: Text(sdkProvider.isStarted ? 'Stop' : 'Start')
              ),
            ),
          ],
          bottom: TabBar(
            onTap: (value) {
              sdkProvider.tabIndex = value;
            },
            tabs: const [
              Tab(icon: Icon(Icons.table_rows_outlined)),
              Tab(icon: Icon(Icons.message_rounded)),
            ],
          ),
          title: const Text('Bridgefy'),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              LogsScreen(),
              ChatScreen(),
            ],
          ),
        ),
      ),
    );
  }
}