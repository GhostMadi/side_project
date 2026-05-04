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
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_dialog.dart';
import 'package:side_project/core/shared/app_list_item.dart';
import 'package:side_project/core/shared/app_pill_back_nav_overlay.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/storage/prefs/post_reactions_prefs_storage.dart';
import 'package:side_project/core/storage/prefs/post_saves_prefs_storage.dart';
import 'package:side_project/core/storage/prefs/business_profile_cache_storage.dart';
import 'package:side_project/core/storage/prefs/profile_follow_status_prefs_storage.dart';
import 'package:side_project/core/storage/prefs/profile_mini_cache_storage.dart';
import 'package:side_project/feature/personalization_page/data/business_profile_gate_listenable.dart';
import 'package:side_project/feature/login_page/data/repository/auth_repository.dart';
import 'package:side_project/feature/login_page/presentation/cubit/auth_cubit.dart';
import 'package:side_project/feature/personalization_page/presentation/cubit/account_hibernate_reset_cubit.dart';
import 'package:side_project/feature/personalization_page/presentation/widget/business_profile_toggle_sheet.dart';

/// Экран «Персонализация» (бизнес-аккаунт, спящий режим).
@RoutePage()
class PersonalizationPage extends StatefulWidget {
  const PersonalizationPage({super.key});

  @override
  State<PersonalizationPage> createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends State<PersonalizationPage> {
  late final AccountHibernateResetCubit _hibernateResetCubit;

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
    await sl<BusinessProfileCacheStorage>().clear(uid);
    sl<BusinessProfileGateListenable>().notifyGateChanged();
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
            automaticallyImplyLeading: false,
            title: Text('Персонализация', style: AppTextStyle.base(19, fontWeight: FontWeight.w700)),
          ),
          body: AppPillBackNavOverlay(
            child: BlocBuilder<AccountHibernateResetCubit, AccountHibernateResetState>(
              builder: (context, actionsState) {
                final busy = actionsState.maybeMap(submitting: (_) => true, orElse: () => false);
                return Stack(
                  children: [
                    ListView(
                      padding: EdgeInsets.only(
                        left: AppDimensions.paddingMiddle,
                        right: AppDimensions.paddingMiddle,
                        bottom: AppPillBackNavOverlay.scrollBottomInset(context),
                      ),
                      children: [
                        SizedBox(height: AppDimensions.spaceMiddle),
                        AppListTile(
                          title: Text(
                            'Бизнес-аккаунт',
                            style: AppTextStyle.base(
                              16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          subtitle: Text(
                            'График, услуги и запись клиентов',
                            style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
                          ),
                          leading: Icon(Icons.storefront_outlined, color: AppColors.btnBackground),
                          trailing: chevron,
                          onTap: busy ? () {} : () => BusinessProfileToggleSheet.show(context),
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
      ),
    );
  }
}
