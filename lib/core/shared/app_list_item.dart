import 'package:flutter/material.dart';

class AppListTile extends StatelessWidget {
  final Widget title;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final bool isDestructive; // Для кнопки "Выход" (красный текст)

  const AppListTile({
    super.key,
    required this.title,
    required this.onTap,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      // 2. Иконка слева (если передали)
      leading: leading,

      // 3. Текст
      title: title,

      // 4. Иконка справа (Стрелочка по умолчанию, если не передали trailing)
      trailing: trailing,
    );
  }
}
