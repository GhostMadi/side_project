import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/locale/app_locale_cubit.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_dialog.dart';
import 'package:side_project/core/shared/app_list_item.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/storage/prefs/post_reactions_prefs_storage.dart';
import 'package:side_project/core/storage/prefs/post_saves_prefs_storage.dart';
import 'package:side_project/core/storage/prefs/profile_follow_status_prefs_storage.dart';
import 'package:side_project/core/storage/prefs/profile_mini_cache_storage.dart';
import 'package:side_project/feature/account_page/presentation/cubit/account_hibernate_reset_cubit.dart';
import 'package:side_project/feature/login_page/data/repository/auth_repository.dart';
import 'package:side_project/feature/login_page/presentation/cubit/auth_cubit.dart';

@RoutePage()
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final AccountHibernateResetCubit _hibernateResetCubit;
  bool _mockDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _hibernateResetCubit = sl<AccountHibernateResetCubit>();
  }

  @override
  void dispose() {
    _hibernateResetCubit.close();
    super.dispose();
  }

  Future<void> _confirmAndHibernate() async {
    final ok = await AppDialog.showConfirm(
      context: context,
      title: 'Спящий режим',
      message:
          'Профиль и публикации станут скрыты от других пользователей. Посты и кластеры не удаляются.\n\n'
          'Действие выполняется на сервере; повторное переключение ограничено раз в 30 дней. ',

      cancelLabel: 'Отмена',
      confirmLabel: 'Включить',
    );
    if (ok != true || !mounted) return;
    await _hibernateResetCubit.hibernateAccount();
  }

  Future<void> _clearLocalUserCaches() async {
    final uid = sl<AuthRepository>().currentUser?.id;
    if (uid == null || uid.isEmpty) return;
    await sl<PostSavesPrefsStorage>().writeCached(uid, {});
    final reactions = sl<PostReactionsPrefsStorage>();
    await reactions.writeCachedKinds(uid, {});
    await reactions.writePendingDesired(uid, {});
    await sl<ProfileMiniCacheStorage>().write(uid, username: null, avatarUrl: null);
    await sl<ProfileFollowStatusPrefsStorage>().writeCached(uid, {});
  }

  Future<void> _signOutAndOpenLogin(BuildContext dialogContext) async {
    await _clearLocalUserCaches();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!dialogContext.mounted) return;
    await dialogContext.read<AuthCubit>().signOut();
    if (!dialogContext.mounted) return;
    dialogContext.router.replaceAll([const LoginRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;
    final switchActive = AppColors.btnBackground;
    final chevron = Icon(Icons.chevron_right_rounded, color: AppColors.subTextColor.withValues(alpha: 0.6));

    return BlocProvider.value(
      value: _hibernateResetCubit,
      child: BlocListener<AccountHibernateResetCubit, AccountHibernateResetState>(
        listenWhen: (prev, next) =>
            next.maybeMap(success: (_) => true, error: (_) => true, orElse: () => false),
        listener: (context, state) {
          state.maybeWhen(
            success: (msg) {
              AppSnackBar.show(
                context,
                message: msg,
                kind: AppSnackBarKind.success,
                duration: const Duration(milliseconds: 1800),
              );
              _hibernateResetCubit.clearTransient();
              unawaited(_signOutAndOpenLogin(context));
            },
            error: (msg) {
              AppSnackBar.show(context, message: msg, kind: AppSnackBarKind.error);
              _hibernateResetCubit.clearTransient();
            },
            orElse: () {},
          );
        },
        child: Scaffold(
          backgroundColor: bg,
          appBar: AppAppBar(
            backgroundColor: bg,
            automaticallyImplyLeading: true,
            title: Text('Удалить аккаунт', style: AppTextStyle.base(19, fontWeight: FontWeight.w700)),
          ),
          body: BlocBuilder<AccountHibernateResetCubit, AccountHibernateResetState>(
            builder: (context, actionsState) {
              final busy = actionsState.maybeMap(submitting: (_) => true, orElse: () => false);
              return Stack(
                children: [
                  ListView(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMiddle),
                    children: [
                      SizedBox(height: AppDimensions.spaceMiddle),
                      Text(
                        'Здесь — персонализация и режим сна (скрытие от других без удаления постов). '
                        'Полное удаление аккаунта с сервера — позже.',
                        style: AppTextStyle.base(14, height: 1.45, color: AppColors.subTextColor),
                      ),
                      SizedBox(height: AppDimensions.spaceMiddle),
                      Text(
                        'ПЕРСОНАЛИЗАЦИЯ',
                        style: AppTextStyle.base(
                          13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.subTextColor,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceJunior),
                      Text(
                        'Тёмная тема — локальный переключатель; язык сохраняется на устройстве.',
                        style: AppTextStyle.base(12, height: 1.35, color: AppColors.subTextColor),
                      ),
                      SizedBox(height: AppDimensions.spaceJunior),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Тёмная тема',
                          style: AppTextStyle.base(
                            16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        value: _mockDarkTheme,
                        activeThumbColor: Colors.white,
                        activeTrackColor: switchActive,
                        onChanged: busy ? null : (v) => setState(() => _mockDarkTheme = v),
                      ),
                      SizedBox(height: AppDimensions.spaceMiddle),
                      Text(
                        'Язык',
                        style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
                      ),
                      SizedBox(height: AppDimensions.spaceJunior),
                      BlocBuilder<AppLocaleCubit, Locale>(
                        buildWhen: (a, b) => a != b,
                        builder: (context, locale) {
                          final idx = locale.languageCode == 'ru' ? 0 : 1;
                          return SegmentedButton<int>(
                            segments: const [
                              ButtonSegment<int>(value: 0, label: Text('Русский')),
                              ButtonSegment<int>(value: 1, label: Text('English')),
                            ],
                            selected: {idx},
                            onSelectionChanged: busy
                                ? (_) {}
                                : (next) {
                                    final i = next.first;
                                    context.read<AppLocaleCubit>().setLocale(Locale(i == 0 ? 'ru' : 'en'));
                                  },
                            style: ButtonStyle(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.white;
                                }
                                return AppColors.textColor;
                              }),
                              backgroundColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return switchActive;
                                }
                                return AppColors.subTextColor.withValues(alpha: 0.08);
                              }),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: AppDimensions.spaceMiddle),
                      Text(
                        'УДАЛЕНИЕ / СОН',
                        style: AppTextStyle.base(
                          13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.subTextColor,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceJunior),
                      AppListTile(
                        title: Text(
                          'Спящий режим',
                          style: AppTextStyle.base(
                            16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        subtitle: Text(
                          'Скрыть профиль и публикации у других',
                          style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
                        ),
                        leading: Icon(Icons.bedtime_outlined, color: AppColors.btnBackground),
                        trailing: chevron,
                        onTap: busy ? () {} : _confirmAndHibernate,
                      ),
                      SizedBox(height: AppDimensions.spaceMiddle),
                    ],
                  ),
                  if (busy) ModalBarrier(color: Colors.white.withValues(alpha: 0.45), dismissible: false),
                  if (busy) const Center(child: AppCircularProgressIndicator()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
