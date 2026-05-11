import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/shared/app_tile_toggle.dart';
import 'package:side_project/feature/profile_hire/presentation/cubit/profile_hire_toggle_cubit.dart';

const double _kToggleSheetSkeletonHeight = 104;

abstract final class ProfileHireSettingsSheet {
  static Future<void> show(BuildContext hostContext) {
    return AppBottomSheet.show<void>(
      context: hostContext,
      contentBottomSpacing: 16,
      content: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<HiringToggleCubit>()..load()),
          BlocProvider(create: (_) => sl<MembershipToggleCubit>()..load()),
        ],
        child: const _ProfileHireSettingsBody(),
      ),
    );
  }
}

class _ProfileHireSettingsBody extends StatelessWidget {
  const _ProfileHireSettingsBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Секция: Я НАНИМАЮ ---
        BlocBuilder<HiringToggleCubit, ProfileHireToggleState>(
          builder: (context, state) {
            return _ToggleItemView(
              state: state,
              icon: Icons.business_center_outlined,
              titleActive: 'Приостановить найм',
              titleInactive: 'Открыть найм',
              subtitleActive: 'Ваш профиль отображается в поиске сотрудников.',
              subtitleInactive: 'Включите, чтобы другие видели, что вы ищете людей.',
              onChanged: (v) async {
                final err = await context.read<HiringToggleCubit>().toggle(v);
                if (!context.mounted) return;
                if (err != null && err.isNotEmpty) {
                  AppSnackBar.show(context, message: err, kind: AppSnackBarKind.error);
                }
              },
              onRetry: () => context.read<HiringToggleCubit>().load(),
            );
          },
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1, thickness: 0.5),
        ),

        // --- Секция: Я ГОТОВ НАНЯТЬСЯ (Вступить в команду) ---
        BlocBuilder<MembershipToggleCubit, ProfileHireToggleState>(
          builder: (context, state) {
            return _ToggleItemView(
              state: state,
              icon: Icons.person_add_alt_1_outlined,
              titleActive: 'Закрыть поиск команды',
              titleInactive: 'Готов вступить в команду',
              subtitleActive: 'Ваш профиль виден тем, кто ищет людей.',
              subtitleInactive: 'Включите, чтобы получать приглашения в команды.',
              onChanged: (v) async {
                final err = await context.read<MembershipToggleCubit>().toggle(v);
                if (!context.mounted) return;
                if (err != null && err.isNotEmpty) {
                  AppSnackBar.show(context, message: err, kind: AppSnackBarKind.error);
                }
              },
              onRetry: () => context.read<MembershipToggleCubit>().load(),
            );
          },
        ),
      ],
    );
  }
}

/// Универсальный виджет для отрисовки каждого тогла
class _ToggleItemView extends StatelessWidget {
  const _ToggleItemView({
    required this.state,
    required this.icon,
    required this.titleActive,
    required this.titleInactive,
    required this.subtitleActive,
    required this.subtitleInactive,
    required this.onChanged,
    required this.onRetry,
  });

  final ProfileHireToggleState state;
  final IconData icon;
  final String titleActive;
  final String titleInactive;
  final String subtitleActive;
  final String subtitleInactive;
  final ValueChanged<bool> onChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: state.maybeWhen(
        loading: () => const SizedBox(
          height: _kToggleSheetSkeletonHeight,
          child: Center(
            child: AppCircularProgressIndicator(strokeWidth: 2, dimension: 28, color: AppColors.primary),
          ),
        ),
        error: (msg) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(msg, style: AppTextStyle.base(14, height: 1.4, color: AppColors.error)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Повторить',
                  style: AppTextStyle.base(15, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        loaded: (isEnabled, isSubmitting) {
          return AppTileToggle(
            leading: Icon(icon, color: AppColors.btnBackground),
            title: Text(
              isEnabled ? titleActive : titleInactive,
              style: AppTextStyle.base(16, fontWeight: FontWeight.w700, color: AppColors.textColor),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                isEnabled ? subtitleActive : subtitleInactive,
                style: AppTextStyle.base(13, height: 1.35, color: AppColors.subTextColor),
              ),
            ),
            value: isEnabled,
            onChanged: isSubmitting ? null : onChanged,
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}
