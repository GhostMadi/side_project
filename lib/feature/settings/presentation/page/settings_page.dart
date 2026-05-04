import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_list_item.dart';
import 'package:side_project/core/shared/app_pill_back_nav_overlay.dart';
import 'package:side_project/core/shared/app_shimmer.dart';
import 'package:side_project/core/storage/prefs/business_profile_cache_storage.dart';
import 'package:side_project/feature/login_page/presentation/cubit/auth_cubit.dart';
import 'package:side_project/feature/personalization_page/data/business_profile_gate_listenable.dart';
import 'package:side_project/feature/personalization_page/data/business_profile_repository.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final BusinessProfileGateListenable _bizGateListen = sl<BusinessProfileGateListenable>();

  /// Всегда из KV после первого [_readPeekFromCache]; пока нет записи (`cacheKnown == false`) — шиммер блока «Бизнес».
  BusinessProfileGatePeek _bizPeek = BusinessProfileGatePeek.unknown();

  @override
  void initState() {
    super.initState();
    _bizGateListen.addListener(_onBizGateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_readPeekFromCache()));
  }

  @override
  void dispose() {
    _bizGateListen.removeListener(_onBizGateChanged);
    super.dispose();
  }

  void _onBizGateChanged() {
    unawaited(_readPeekFromCache());
  }

  Future<void> _readPeekFromCache() async {
    final peek = await sl<BusinessProfileRepository>().peekGate();
    if (!mounted) return;
    setState(() => _bizPeek = peek);
  }

  Future<void> _pullRefreshBiz() async {
    try {
      await sl<BusinessProfileRepository>().refreshRemoteAndCache();
    } catch (_) {
      /// Ошибку не показываем — блок остаётся по последнему кэшу; при необходимости пользователь потянет снова.
    }
    if (mounted) await _readPeekFromCache();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;
    final chevron = Icon(Icons.chevron_right_rounded, color: AppColors.subTextColor.withValues(alpha: 0.6));
    final showBizTiles = _bizPeek.cacheKnown && businessProfileIsActiveFromPeek(_bizPeek);
    final showBizShimmer = !_bizPeek.cacheKnown;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar(
        backgroundColor: bg,
        automaticallyImplyLeading: false,
        title: Text('Настройки', style: AppTextStyle.base(19, fontWeight: FontWeight.w700)),
      ),
      body: AppPillBackNavOverlay(
        child: RefreshIndicator(
          onRefresh: () async => _pullRefreshBiz(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: AppDimensions.paddingMiddle,
              right: AppDimensions.paddingMiddle,
              bottom: AppPillBackNavOverlay.scrollBottomInset(context),
            ),
            children: [
              SizedBox(height: AppDimensions.spaceMiddle),
              if (showBizShimmer) ...[
                Text(
                  'Бизнес',
                  style: AppTextStyle.base(14, fontWeight: FontWeight.w800, color: AppColors.subTextColor),
                ),
                SizedBox(height: AppDimensions.spaceJunior),
                const _BizSectionShimmer(),
                SizedBox(height: AppDimensions.spaceMiddle),
              ],
              if (showBizTiles) ...[
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
              ],
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
                  'Бизнес-аккаунт и спящий режим',
                  style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
                ),
                leading: Icon(Icons.manage_accounts_outlined, color: AppColors.btnBackground),
                trailing: chevron,
                onTap: () async {
                  await context.router.push(const PersonalizationRoute());
                  if (!mounted) return;
                  await _readPeekFromCache();
                },
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
      ),
    );
  }
}

class _BizSectionShimmer extends StatelessWidget {
  const _BizSectionShimmer();

  @override
  Widget build(BuildContext context) {
    Widget row() {
      return AppShimmer(
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row(),
        SizedBox(height: AppDimensions.spaceJunior),
        row(),
      ],
    );
  }
}
