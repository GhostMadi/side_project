import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_list_item.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';

@RoutePage()
class BusinessGrowthPage extends StatelessWidget {
  const BusinessGrowthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chevron = Icon(Icons.chevron_right_rounded, color: AppColors.subTextColor.withValues(alpha: 0.6));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Text('Подключение бизнеса', style: AppTextStyle.base(18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMiddle),
        children: [
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'Отдельный сервис для салонов и мастеров: перенос клиентской базы, запуск записи и быстрый старт без сложной настройки.',
            style: AppTextStyle.base(14, height: 1.4, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          AppListTile(
            title: Text('Перенос клиентской базы', style: AppTextStyle.base(16, fontWeight: FontWeight.w700)),
            subtitle: Text('Excel/CSV, ручной список или вставка текста', style: AppTextStyle.base(13, color: AppColors.subTextColor)),
            leading: const Icon(Icons.cloud_upload_outlined, color: AppColors.btnBackground),
            trailing: chevron,
            onTap: () => context.router.push(const BusinessClientImportRoute()),
          ),
          SizedBox(height: AppDimensions.spaceJunior),
          AppListTile(
            title: Text('О сервисе', style: AppTextStyle.base(16, fontWeight: FontWeight.w700)),
            subtitle: Text('Как работает запись и CRM в приложении', style: AppTextStyle.base(13, color: AppColors.subTextColor)),
            leading: const Icon(Icons.info_outline_rounded, color: AppColors.btnBackground),
            trailing: chevron,
            onTap: () {
              AppSnackBar.show(
                context,
                message: 'Мок: здесь будет презентация сервиса',
                kind: AppSnackBarKind.info,
              );
            },
          ),
        ],
      ),
    );
  }
}
