import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_list_item.dart';

/// Хаб бизнес-аккаунта: отсюда — график, услуги и т.д.
@RoutePage()
class BusinessAccountPage extends StatelessWidget {
  const BusinessAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;
    final chevron = Icon(Icons.chevron_right_rounded, color: AppColors.subTextColor.withValues(alpha: 0.6));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar(
        backgroundColor: bg,
        automaticallyImplyLeading: true,
        title: Text('Бизнес-аккаунт', style: AppTextStyle.base(19, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMiddle),
        children: [
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'Собрали основные действия по графику, аналитике и подпискам на аккаунты.',
            style: AppTextStyle.base(14, height: 1.45, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'ГРАФИК И УСЛУГИ',
            style: AppTextStyle.base(13, fontWeight: FontWeight.w800, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceJunior),
          AppListTile(
            title: Text(
              'Создай свой график и услуги',
              style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
            ),
            subtitle: Text(
              'Настрой расписание и услуги для онлайн-записи',
              style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
            ),
            leading: Icon(Icons.event_note_outlined, color: AppColors.btnBackground),
            trailing: chevron,
            onTap: () => context.router.push(BusinessScheduleRoute()),
          ),
          SizedBox(height: AppDimensions.spaceJunior),
          AppListTile(
            title: Text(
              'Поделиться своим графиком и услугой',
              style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
            ),
            subtitle: Text(
              'Управляй доступом через раздел работников и работодателей',
              style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
            ),
            leading: Icon(Icons.share_outlined, color: AppColors.btnBackground),
            trailing: chevron,
            onTap: () => context.router.push(BusinessScheduleRoute(showWorkers: true)),
          ),
          SizedBox(height: AppDimensions.spaceJunior),
          AppListTile(
            title: Text(
              'Мои графики и услуги',
              style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
            ),
            subtitle: Text(
              'Карточки: ваши + работников',
              style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
            ),
            leading: Icon(Icons.dashboard_customize_outlined, color: AppColors.btnBackground),
            trailing: chevron,
            onTap: () => context.router.push(BusinessScheduleRoute(showWorkers: true)),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'АНАЛИТИКА',
            style: AppTextStyle.base(13, fontWeight: FontWeight.w800, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceJunior),
          AppListTile(
            title: Text(
              'Все аналитики',
              style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
            ),
            subtitle: Text(
              'Список аналитик, включая аналитику по сервисам',
              style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
            ),
            leading: Icon(Icons.analytics_outlined, color: AppColors.btnBackground),
            trailing: chevron,
            onTap: () => context.router.push(const BusinessAnalyticsListRoute()),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'ПОДПИСКИ НА АККАУНТЫ',
            style: AppTextStyle.base(13, fontWeight: FontWeight.w800, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceJunior),
          AppListTile(
            title: Text(
              'Подписать под себя аккаунт',
              style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
            ),
            subtitle: Text(
              'Табы: Аккаунт и Подписанные аккаунты',
              style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
            ),
            leading: Icon(Icons.person_add_alt_1_outlined, color: AppColors.btnBackground),
            trailing: chevron,
            onTap: () => context.router.push(const WorkersRoute()),
          ),
          SizedBox(height: AppDimensions.spaceJunior),
          AppListTile(
            title: Text(
              'Подписаться под аккаунт',
              style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
            ),
            subtitle: Text(
              'Табы: Подписанные аккаунты и Поиск',
              style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
            ),
            leading: Icon(Icons.person_search_outlined, color: AppColors.btnBackground),
            trailing: chevron,
            onTap: () => context.router.push(const EmployersRoute()),
          ),
        ],
      ),
    );
  }
}
