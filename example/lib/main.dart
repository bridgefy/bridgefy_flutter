import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bridgefy_example/presentation/screens/home_screen.dart';
import 'package:bridgefy_example/config/theme/app_theme.dart';
import 'package:bridgefy_example/presentation/providers/chat_provider.dart';
import 'package:bridgefy_example/presentation/providers/sdk_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SdkProvider>(create: (_)=> SdkProvider()),
        ChangeNotifierProxyProvider<SdkProvider, ChatProvider>(
          create: (_)=> ChatProvider(),
          update: (_, sdkProvider, chatProvider)=>chatProvider!..setSDK(sdkProvider),
        ),
      ],
      child: MaterialApp(
        title: 'Bridgefy example',
        debugShowCheckedModeBanner: false,
        theme: AppTheme().theme(),
        home: const HomeScreen(),
      ),
    );
  }
}