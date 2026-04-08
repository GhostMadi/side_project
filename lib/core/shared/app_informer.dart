import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

/// Компактный информационный блок: иконка, заголовок/текст, опциональное действие.
class AppInformer extends StatelessWidget {
  const AppInformer({
    super.key,
    required this.message,
    this.title,
    this.actionLabel,
    this.onAction,
    this.leading,
  });

  final String message;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.hintCardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hintCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading ?? Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.base(14, fontWeight: FontWeight.w700, color: AppColors.textColor),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.primary,
                      ),
                      child: Text(
                        actionLabel!,
                        style: AppTextStyle.base(14, color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
