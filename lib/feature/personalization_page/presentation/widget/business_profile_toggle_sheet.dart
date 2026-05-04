import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/shared/app_tile_toggle.dart';
import 'package:side_project/feature/personalization_page/presentation/cubit/business_profile_toggle_cubit.dart';

/// Ожидаемая высота ряда с переключателем после загрузки — лоадер не растягивает шторку на весь экран.
const double _kToggleSheetSkeletonHeight = 104;

abstract final class BusinessProfileToggleSheet {
  static Future<void> show(BuildContext hostContext) {
    return AppBottomSheet.show<void>(
      context: hostContext,
      contentBottomSpacing: 16,
      content: BlocProvider(
        create: (_) => sl<BusinessProfileToggleCubit>()..load(),
        child: const _BusinessProfileToggleBody(),
      ),
    );
  }
}

class _BusinessProfileToggleBody extends StatelessWidget {
  const _BusinessProfileToggleBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessProfileToggleCubit, BusinessProfileToggleState>(
      builder: (context, state) {
        return IntrinsicHeight(
          child: state.maybeWhen(
            loading: () => SizedBox(
              height: _kToggleSheetSkeletonHeight,
              child: Center(
                child: AppCircularProgressIndicator(strokeWidth: 2, dimension: 28, color: AppColors.primary),
              ),
            ),
            error: (msg) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(msg, style: AppTextStyle.base(14, height: 1.4, color: AppColors.error)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.read<BusinessProfileToggleCubit>().load(),
                    child: Text(
                      'Повторить',
                      style: AppTextStyle.base(15, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            loaded: (isActive, submitting) {
              final titleLabel = isActive ? 'Деактивировать' : 'Активировать';

              return AppTileToggle(
                leading: Icon(Icons.storefront_outlined, color: AppColors.btnBackground),
                title: Text(
                  titleLabel,
                  style: AppTextStyle.base(16, fontWeight: FontWeight.w700, color: AppColors.textColor),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    isActive
                        ? 'Бизнес-профиль виден и доступен как активный.'
                        : 'Включите, чтобы использовать бизнес-функции.',
                    style: AppTextStyle.base(13, height: 1.35, color: AppColors.subTextColor),
                  ),
                ),
                value: isActive,
                onChanged: submitting
                    ? null
                    : (v) async {
                        final err = await context.read<BusinessProfileToggleCubit>().applyActive(v);
                        if (!context.mounted) return;
                        if (err != null && err.isNotEmpty) {
                          AppSnackBar.show(context, message: err, kind: AppSnackBarKind.error);
                        }
                      },
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
