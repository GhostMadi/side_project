import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AppIcons {
  // Исправил опечатку: Icons.profil -> Icons.person
  user(iconAndroid: Icons.person, iconIos: CupertinoIcons.person_fill);

  final IconData iconAndroid;
  final IconData iconIos;

  const AppIcons({required this.iconAndroid, required this.iconIos});

  // --- ВОТ ВАША ФУНКЦИЯ (Геттер) ---
  IconData get icon {
    if (Platform.isIOS) {
      return iconIos;
    }
    // Для Android и всех остальных
    return iconAndroid;
  }
}
