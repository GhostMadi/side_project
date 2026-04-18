import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_thread_timeline_utils.dart';

/// Липкая дата без фона — только подпись по центру.
class ChatThreadDayHeader extends StatelessWidget {
  const ChatThreadDayHeader({super.key, required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          formatChatDayHeader(day, locale: locale),
          style: AppTextStyle.base(12, color: AppColors.subTextColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
