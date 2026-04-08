import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_list_item.dart';
import 'package:side_project/core/shared/app_outlined_button.dart';

/// Что пользователь выбрал создать из шторки «+» в шапке профиля.
enum ProfileCreateContentKind { cluster, post }

/// Кнопки действий в шапке профиля.
class ProfileHeaderActionRow extends StatelessWidget {
  const ProfileHeaderActionRow({
    super.key,
    required this.onEditProfile,
    required this.onMessage,
    this.onCreateContent,
  });

  final VoidCallback? onEditProfile;
  final VoidCallback? onMessage;
  final ValueChanged<ProfileCreateContentKind>? onCreateContent;

  Future<void> _openCreateSheet(BuildContext context) async {
    final kind = await AppBottomSheet.show<ProfileCreateContentKind>(
      context: context,
      title: 'Создать',
      contentBottomSpacing: 16,
      content: Builder(
        builder: (sheetContext) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppListTile(
                leading: Icon(AppIcons.folder.icon, color: AppColors.primary, size: 22),
                title: const Text('Создать кластер'),
                onTap: () => Navigator.of(sheetContext).pop(ProfileCreateContentKind.cluster),
              ),
              const SizedBox(height: 4),
              AppListTile(
                leading: Icon(AppIcons.photo.icon, color: AppColors.primary, size: 22),
                title: const Text('Создать пост'),
                onTap: () => Navigator.of(sheetContext).pop(ProfileCreateContentKind.post),
              ),
            ],
          );
        },
      ),
    );
    if (!context.mounted || kind == null) return;
    onCreateContent?.call(kind);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: AppOutlinedButton(text: 'Редактировать профиль', onPressed: onEditProfile, isExpanded: true),
        ),
        const SizedBox(width: 8),
        AppOutlinedButton(
          text: '',
          isExpanded: false,
          onPressed: () => _openCreateSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(AppIcons.add.icon, color: AppColors.primary, size: 22),
          ),
        ),
        const SizedBox(width: 8),
        AppButton(
          text: '',
          isExpanded: false,
          onPressed: onMessage,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(AppIcons.settings.icon, color: AppColors.white, size: 22),
          ),
        ),
      ],
    );
  }
}
