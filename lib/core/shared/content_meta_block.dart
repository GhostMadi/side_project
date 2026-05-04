import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

/// Сетка как в [EventTicketDetailsSheet]: колонка под иконку/эмодзи, отступ, текст.
const double kContentMetaLeadW = 40;
const double kContentMetaGutter = 8;
const double kContentMetaIcon = 18;

TextStyle get contentMetaTimeTextStyle =>
    AppTextStyle.base(15, fontWeight: FontWeight.w600, color: AppColors.textColor, height: 1.3);

TextStyle get contentMetaPlaceTextStyle => AppTextStyle.base(
  14,
  fontWeight: FontWeight.w500,
  color: AppColors.textColor.withValues(alpha: 0.85),
  height: 1.45,
);

class ContentMetaRow extends StatelessWidget {
  const ContentMetaRow({super.key, required this.lead, required this.body});

  final Widget lead;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: kContentMetaLeadW, child: lead),
        const SizedBox(width: kContentMetaGutter),
        Expanded(child: body),
      ],
    );
  }
}
