import 'package:flutter/material.dart';
import 'package:bridgefy_example/config/environment.dart';

Color _bridgefyColor = Color(int.parse(EnvironmentConfig.bridgefyColor));

class AppTheme {
  ThemeData theme(){
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _bridgefyColor,
    );
  }
}