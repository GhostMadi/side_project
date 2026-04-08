import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';

/// Оболочка скролла + pull-to-refresh для экрана профиля.
class ProfilePageScrollShell extends StatelessWidget {
  const ProfilePageScrollShell({
    super.key,
    required this.bottomPad,
    required this.onRefresh,
    required this.header,
    this.top,
  });

  final double bottomPad;
  final Future<void> Function() onRefresh;
  final Widget header;
  final Widget? top;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            if (top != null) top!,
            header,
            SizedBox(height: bottomPad),
          ],
        ),
      ),
    );
  }
}
