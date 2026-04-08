import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';

/// Простая панель с иконкой "сетка" над постами (как было раньше).
class ProfilePostsTabBar extends StatelessWidget {
  const ProfilePostsTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final iconColor = AppColors.textColor.withValues(alpha: 0.78);
    return SizedBox(
      height: 46,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 44,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.grid_on_rounded, size: 20, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }
}
