import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/color_settings/color_extension.dart';

class AppTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const AppTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.third, width: 1.2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          listTileTheme: ListTileThemeData(
            // iconColor: colors.textPrimary,
            // textColor: colors.textPrimary,
            tileColor: Colors.transparent, // Контейнер сам управляет цветом
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
          ),
        ),
        child: ListTile(
          onTap: onTap,
          leading: leadingIcon != null ? Icon(leadingIcon) : null,
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          trailing: trailingIcon != null ? Icon(trailingIcon) : null,
        ),
      ),
    );
  }
}
