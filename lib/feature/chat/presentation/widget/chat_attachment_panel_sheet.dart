import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';

/// Выбор действия из панели «+»: фото, камера, файл.
enum ChatAttachmentChoice {
  gallery,
  camera,
  file,
}

/// Шторка вложений через общий [AppBottomSheet] (блюр, jelly).
abstract final class ChatAttachmentPanelSheet {
  ChatAttachmentPanelSheet._();

  static Future<ChatAttachmentChoice?> show(BuildContext context) {
    return AppBottomSheet.show<ChatAttachmentChoice>(
      context: context,
      title: 'Вложения',
      upperCaseTitle: false,
      showCloseButton: true,
      contentBottomSpacing: 12,
      content: const _AttachmentPanelContent(),
    );
  }
}

class _AttachmentPanelContent extends StatelessWidget {
  const _AttachmentPanelContent();

  static const _items = <({IconData icon, String title, String subtitle, ChatAttachmentChoice choice})>[
    (
      icon: Icons.photo_library_rounded,
      title: 'Фото',
      subtitle: 'галерея',
      choice: ChatAttachmentChoice.gallery,
    ),
    (
      icon: Icons.photo_camera_rounded,
      title: 'Камера',
      subtitle: 'снять снимок',
      choice: ChatAttachmentChoice.camera,
    ),
    (
      icon: Icons.insert_drive_file_rounded,
      title: 'Файл',
      subtitle: 'документ или видео',
      choice: ChatAttachmentChoice.file,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in _items)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            leading: Icon(item.icon, color: AppColors.primary, size: 26),
            title: Text(item.title, style: AppTextStyle.base(16, fontWeight: FontWeight.w600)),
            subtitle: Text(item.subtitle, style: AppTextStyle.base(13, color: AppColors.subTextColor)),
            onTap: () => Navigator.pop(context, item.choice),
          ),
      ],
    );
  }
}
