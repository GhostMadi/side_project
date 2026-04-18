import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_list_item.dart';
import 'package:side_project/core/shared/app_pill_back_nav_overlay.dart';
import 'package:side_project/feature/login_page/presentation/cubit/auth_cubit.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;
    final chevron = Icon(Icons.chevron_right_rounded, color: AppColors.subTextColor.withValues(alpha: 0.6));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar(
        backgroundColor: bg,
        automaticallyImplyLeading: false,
        title: Text('Настройки', style: AppTextStyle.base(19, fontWeight: FontWeight.w700)),
      ),
      body: AppPillBackNavOverlay(
        child: ListView(
          padding: EdgeInsets.only(
            left: AppDimensions.paddingMiddle,
            right: AppDimensions.paddingMiddle,
            bottom: AppPillBackNavOverlay.scrollBottomInset(context),
          ),
          children: [
            SizedBox(height: AppDimensions.spaceMiddle),
            Text(
              'Бизнес',
              style: AppTextStyle.base(14, fontWeight: FontWeight.w800, color: AppColors.subTextColor),
            ),
            SizedBox(height: AppDimensions.spaceJunior),
            AppListTile(
              title: Text(
                'Бизнес-аккаунт',
                style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
              ),
              subtitle: Text(
                'График, услуги и запись клиентов',
                style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
              ),
              leading: Icon(Icons.storefront_outlined, color: AppColors.btnBackground),
              trailing: chevron,
              onTap: () => context.router.push(const BusinessAccountRoute()),
            ),
            SizedBox(height: AppDimensions.spaceJunior),
            AppListTile(
              title: Text(
                'Записи',
                style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
              ),
              subtitle: Text(
                'Кто записался, на кого, статус по табам',
                style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
              ),
              leading: Icon(Icons.calendar_month_outlined, color: AppColors.btnBackground),
              trailing: chevron,
              onTap: () => context.router.push(const BusinessBookingsRoute()),
            ),
            SizedBox(height: AppDimensions.spaceMiddle),
            Text(
              'Аккаунт',
              style: AppTextStyle.base(14, fontWeight: FontWeight.w800, color: AppColors.subTextColor),
            ),
            SizedBox(height: AppDimensions.spaceJunior),
            AppListTile(
              title: Text(
                'Персонализация',
                style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
              ),
              subtitle: Text(
                'Тема, язык, спящий режим',
                style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
              ),
              leading: Icon(Icons.manage_accounts_outlined, color: AppColors.btnBackground),
              trailing: chevron,
              onTap: () => context.router.push(const AccountRoute()),
            ),
            SizedBox(height: AppDimensions.spaceJunior),
            AppListTile(
              title: Text(
                'Сохранённое',
                style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
              ),
              subtitle: Text(
                'Посты, которые вы сохранили',
                style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
              ),
              leading: Icon(Icons.bookmark_outline_rounded, color: AppColors.btnBackground),
              trailing: chevron,
              onTap: () => context.router.push(const SavedRoute()),
            ),
            SizedBox(height: AppDimensions.spaceJunior),
            AppListTile(
              title: Text(
                'Архивированные',
                style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
              ),
              subtitle: Text(
                'Кластеры и публикации в архиве',
                style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
              ),
              leading: Icon(Icons.archive_outlined, color: AppColors.subTextColor),
              trailing: chevron,
              onTap: () => context.router.push(const ArchivedRoute()),
            ),
            SizedBox(height: AppDimensions.spaceJunior),
            AppListTile(
              title: Text(
                'Выйти',
                style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
              ),
              subtitle: Text(
                'Выход из Google и Supabase на этом устройстве',
                style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
              ),
              leading: Icon(Icons.logout_rounded, color: AppColors.subTextColor),
              onTap: () async {
                await context.read<AuthCubit>().signOut();
                if (!context.mounted) return;
                context.router.replaceAll([const LoginRoute()]);
              },
            ),
            SizedBox(height: AppDimensions.spaceJunior),
          ],
        ),
      ),
    );
  }
}
