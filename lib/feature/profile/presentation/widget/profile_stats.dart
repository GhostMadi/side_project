// import 'package:flutter/material.dart';
// import 'package:side_project/core/resources/color_settings/color_extension.dart';
// import 'package:side_project/core/resources/dimension/app_dimension.dart';
// import 'package:side_project/core/resources/text_settings/app_text_style.dart';

// class ProfileStatsWidget extends StatelessWidget {
//   const ProfileStatsWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final colors = AppColors;

//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMiddle),
//       padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingMiddle),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(100),
//         border: Border.all(color: colors.fourth),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _StatItem('Following', 10),
//           _StatItem('Followers', 15),
//           _StatItem('Eventers', 20),
//         ],
//       ),
//     );
//   }

//   Widget _StatItem(String label, int count) => Column(
//     children: [
//       Text('$count', style: AppTextStyle.base(15)),
//       Text(label, style: AppTextStyle.base(15, weight: FontWeight.w400)),
//     ],
//   );
// }
