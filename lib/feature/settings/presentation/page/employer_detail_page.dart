import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_list_item.dart';

/// Страница конкретного работодателя (1 карточка): тут только инфо + тайл на корзину услуг.
@RoutePage()
class EmployerDetailPage extends StatelessWidget {
  const EmployerDetailPage({
    super.key,
    required this.employerId,
    required this.employerName,
    required this.employerAvatar,
  });

  final String employerId;
  final String employerName;
  final String employerAvatar;

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;
    final chevron = Icon(Icons.chevron_right_rounded, color: AppColors.subTextColor.withValues(alpha: 0.6));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar(
        backgroundColor: bg,
        automaticallyImplyLeading: true,
        title: Text(
          employerName,
          style: AppTextStyle.base(18, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingMiddle,
          AppDimensions.spaceMiddle,
          AppDimensions.paddingMiddle,
          AppDimensions.spaceSenior,
        ),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(employerAvatar),
            ),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'Здесь можно отправить свои услуги для этого работодателя.',
            style: AppTextStyle.base(14, height: 1.4, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          AppListTile(
            title: Text(
              'Выберите услуги для работодателя',
              style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
            ),
            subtitle: Text(
              'Перетащите нужные услуги (drag & drop) и отправьте',
              style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
            ),
            leading: Icon(Icons.shopping_cart_outlined, color: AppColors.btnBackground),
            trailing: chevron,
            onTap: () => context.router.push(
              EmployerServiceShareRoute(
                employerId: employerId,
                employerName: employerName,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

