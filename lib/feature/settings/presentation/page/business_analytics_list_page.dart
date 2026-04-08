import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_list_item.dart';

@RoutePage()
class BusinessAnalyticsListPage extends StatelessWidget {
  const BusinessAnalyticsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chevron = Icon(Icons.chevron_right_rounded, color: AppColors.subTextColor.withValues(alpha: 0.6));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Text('Аналитика', style: AppTextStyle.base(19, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMiddle),
        children: [
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'Выберите раздел аналитики.',
            style: AppTextStyle.base(14, height: 1.4, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          AppListTile(
            title: Text(
              'Аналитика по сервисам',
              style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
            ),
            subtitle: Text(
              'Показатели по услугам и группам сервисов',
              style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
            ),
            leading: Icon(Icons.insights_outlined, color: AppColors.btnBackground),
            trailing: chevron,
            onTap: () => context.router.push(const BusinessAnalyticsRoute()),
          ),
          SizedBox(height: AppDimensions.spaceJunior),
          AppListTile(
            title: Text(
              'Справочник услуг для аналитики',
              style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
            ),
            subtitle: Text(
              'Названия и описания групп, которые участвуют в отчётах',
              style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
            ),
            leading: Icon(Icons.analytics_outlined, color: AppColors.btnBackground),
            trailing: chevron,
            onTap: () => context.router.push(const BusinessAnalyticsServicesRoute()),
          ),
        ],
      ),
    );
  }
}
