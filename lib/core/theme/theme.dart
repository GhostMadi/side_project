import 'package:flutter/material.dart';
import 'package:side_project/core/resources/app_colors.dart';

ThemeData lightTheme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    extensions: [AppColorsExtension.light],
  );
}

ThemeData blackTheme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.black,

    extensions: [AppColorsExtension.dark],
  );
}
