import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

/// Тема общего bottom sheet «порядок в посте» (шаг галереи vs шаг редактора).
enum PostReorderSheetVariant { gallery, editor }

/// Строка [ReorderableListView]: карточка + непрозрачный зазор цвета фона шита (без артефактов при драге).
Widget postReorderListRow({
  required Key key,
  required PostReorderSheetVariant variant,
  required int index,
  required int itemCount,
  required Widget card,
}) {
  final sheetBg = _sheetBackground(variant);
  return Column(
    key: key,
    mainAxisSize: MainAxisSize.min,
    children: [
      card,
      if (index < itemCount - 1)
        ColoredBox(
          color: sheetBg,
          child: const SizedBox(height: 10, width: double.infinity),
        ),
    ],
  );
}

Color _sheetBackground(PostReorderSheetVariant variant) => switch (variant) {
  PostReorderSheetVariant.gallery => AppColors.surface,
  PostReorderSheetVariant.editor => AppColors.postEditorPanel,
};

TextStyle _titleStyle(PostReorderSheetVariant variant) => AppTextStyle.base(
  17,
  color: switch (variant) {
    PostReorderSheetVariant.gallery => AppColors.textColor,
    PostReorderSheetVariant.editor => AppColors.postEditorOnSurface,
  },
  fontWeight: FontWeight.w700,
);

TextStyle _hintStyle(PostReorderSheetVariant variant) => AppTextStyle.base(
  13,
  color: switch (variant) {
    PostReorderSheetVariant.gallery => AppColors.subTextColor,
    PostReorderSheetVariant.editor => AppColors.postEditorOnSurfaceMuted,
  },
  height: 1.35,
);

/// Общий bottom sheet порядка кадров для шага галереи и шага редактора.
Future<void> showPostReorderBottomSheet({
  required BuildContext context,
  required PostReorderSheetVariant variant,
  required int itemCount,
  required ReorderCallback onReorder,
  required Widget Function(BuildContext context, int index) itemBuilder,
}) async {
  if (itemCount < 2) {
    return;
  }
  final sheetBg = _sheetBackground(variant);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: sheetBg,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) {
      final bottom = MediaQuery.paddingOf(ctx).bottom;
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Порядок в посте', textAlign: TextAlign.center, style: _titleStyle(variant)),
              const SizedBox(height: 6),
              Text('Зажмите ≡ и перетащите строки', textAlign: TextAlign.center, style: _hintStyle(variant)),
              const SizedBox(height: 16),
              SizedBox(
                height: MediaQuery.sizeOf(ctx).height * 0.45,
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.only(bottom: 10),

                  itemCount: itemCount,
                  onReorder: onReorder,
                  itemBuilder: itemBuilder,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Готово', style: AppTextStyle.base(16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    },
  );
}
