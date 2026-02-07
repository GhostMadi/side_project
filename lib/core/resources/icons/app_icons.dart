import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AppIcons {
  // Исправил опечатку: Icons.profil -> Icons.person
  map(iconAndroid: Icons.map_rounded, iconIos: CupertinoIcons.map_fill),



  user(iconAndroid: Icons.person, iconIos: CupertinoIcons.person_fill),
  menu(iconAndroid: Icons.menu, iconIos: CupertinoIcons.bars),
  back(iconAndroid: Icons.arrow_back, iconIos: CupertinoIcons.back),
  addShop(iconAndroid: Icons.add, iconIos: CupertinoIcons.add_circled),
  language(iconAndroid: Icons.language, iconIos: CupertinoIcons.globe),
  theme(iconAndroid: Icons.wb_sunny_outlined, iconIos: CupertinoIcons.sun_max),
  check(iconAndroid: Icons.check, iconIos: CupertinoIcons.check_mark),
  photo(iconAndroid: Icons.photo, iconIos: CupertinoIcons.photo),
  folder(iconAndroid: Icons.folder, iconIos: CupertinoIcons.folder),
  add(iconAndroid: Icons.add, iconIos: CupertinoIcons.add),
  delete(
    iconAndroid: Icons.delete_outline_outlined,
    iconIos: CupertinoIcons.delete,
  ),
  search(iconAndroid: Icons.search, iconIos: CupertinoIcons.search),
  arrowDown(
    iconAndroid: Icons.keyboard_arrow_down_rounded,
    iconIos: Icons.keyboard_arrow_down_rounded,
  ),
  checkBox(iconAndroid: Icons.check_box, iconIos: CupertinoIcons.check_mark),
  checkBoxBlank(
    iconAndroid: Icons.check_box_outline_blank,
    iconIos: CupertinoIcons.square,
  );

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
