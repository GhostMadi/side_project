import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_dialog.dart';
import 'package:side_project/core/shared/app_overflow_menu.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/feature/profile_page/data/models/profile_marker_model.dart';
import 'package:side_project/feature/profile_page/presentation/cubit/profile_markers_cubit.dart';

class ProfileMarkersList extends StatelessWidget {
  const ProfileMarkersList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileMarkersCubit, ProfileMarkersState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
          loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
          error: (m) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              m,
              style: AppTextStyle.base(13, fontWeight: FontWeight.w700, color: AppColors.textColor),
            ),
          ),
          loaded: (items) {
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Text(
                  'Маркеров пока нет',
                  style: AppTextStyle.base(14, fontWeight: FontWeight.w800, color: AppColors.textColor),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  for (final m in items) ...[_MarkerTile(model: m), const SizedBox(height: 10)],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MarkerTile extends StatelessWidget {
  const _MarkerTile({required this.model});

  final ProfileMarkerModel model;

  @override
  Widget build(BuildContext context) {
    final emoji = model.textEmoji?.trim();
    final title = (model.addressText?.trim().isNotEmpty == true) ? model.addressText!.trim() : 'Без названия';
    final time = _formatTimeRange(model.eventTime, model.endTime);
    final status = model.status;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                (emoji == null || emoji.isEmpty) ? '📍' : emoji,
                style: AppTextStyle.base(20, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.base(14, fontWeight: FontWeight.w900, color: AppColors.textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: AppTextStyle.base(
                      12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _StatusPill(status: status),
            const SizedBox(width: 6),
            AppOverflowMenu<String>(
              items: const [
                AppOverflowMenuItem(
                  value: 'archive',
                  title: 'Архивировать',
                  icon: Icons.archive_outlined,
                ),
                AppOverflowMenuItem(
                  value: 'delete',
                  title: 'Удалить',
                  icon: Icons.delete_outline_rounded,
                  titleColor: AppColors.destructive,
                  iconColor: AppColors.destructive,
                ),
              ],
              onSelected: (v) async {
                if (v == 'archive') {
                  await context.read<ProfileMarkersCubit>().archiveMarker(model.id);
                  if (!context.mounted) return;
                  AppSnackBar.show(context, message: 'Маркер в архиве', kind: AppSnackBarKind.success);
                  return;
                }
                if (v == 'delete') {
                  final ok = await AppDialog.showConfirm(
                    context: context,
                    title: 'Удалить маркер?',
                    message: 'Маркер исчезнет из профиля и карты. Это действие нельзя отменить.',
                    confirmLabel: 'Удалить',
                    confirmIsDestructive: true,
                  );
                  if (ok != true || !context.mounted) return;
                  await context.read<ProfileMarkersCubit>().deleteMarker(model.id);
                  if (!context.mounted) return;
                  AppSnackBar.show(context, message: 'Маркер удалён', kind: AppSnackBarKind.success);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      'active' => (AppColors.primary.withValues(alpha: 0.14), AppColors.primary, 'Активно'),
      'upcoming' => (AppColors.surfaceSoft, AppColors.textColor, 'Скоро'),
      'finished' => (AppColors.surfaceSoft, AppColors.textColor.withValues(alpha: 0.7), 'Прошло'),
      'cancelled' => (Colors.red.withValues(alpha: 0.12), Colors.red, 'Отмена'),
      _ => (AppColors.surfaceSoft, AppColors.textColor.withValues(alpha: 0.7), status),
    };

    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: AppTextStyle.base(12, fontWeight: FontWeight.w900, color: fg),
        ),
      ),
    );
  }
}

String _formatTimeRange(DateTime start, DateTime end) {
  String two(int v) => v.toString().padLeft(2, '0');
  final d = '${two(start.day)}.${two(start.month)}';
  final s = '${two(start.hour)}:${two(start.minute)}';
  final e = '${two(end.hour)}:${two(end.minute)}';
  return '$d • $s–$e';
}
