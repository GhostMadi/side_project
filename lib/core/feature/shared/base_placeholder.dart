// import 'package:flutter/material.dart';
// import 'package:side_project/core/resources/color_settings/color_extension.dart';
// import 'package:side_project/core/resources/text_settings/app_text_style.dart';

// class BaseLoadingPlaceholder extends StatelessWidget {
//   final String labelText;

//   const BaseLoadingPlaceholder({required this.labelText});

//   @override
//   Widget build(BuildContext context) {
//     final appColors = AppColors;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Заголовок поля (Label)
//         Text(
//           labelText,
//           style: AppTextStyle.base(15, weight: FontWeight.w500).copyWith(color: appColors.secondary),
//         ),
//         const SizedBox(height: 8),
//         // Поле-заглушка
//         Container(
//           height: 50,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             border: Border.all(color: appColors.third), // Твой цвет бордера
//             borderRadius: BorderRadius.circular(12),
//             color: appColors.primary, // Твой фон
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           alignment: Alignment.centerLeft,
//           child: SizedBox(
//             height: 18,
//             width: 18,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               valueColor: AlwaysStoppedAnimation<Color>(appColors.brand), // Твой бирюзовый акцент
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
