import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

/// Карточка строки в списке переупорядочивания кадров (галерея / редактор).
///
/// Без внешних отступов: расстояние между строками задавайте в [ReorderableListView]
/// (например `Padding` только сверху), иначе при перетаскивании под карточкой
/// остаётся прозрачная полоса и виден фон шита.
class PostReorderCard extends StatelessWidget {
  const PostReorderCard.gallery({
    super.key,
    required this.index,
    required this.thumbnail,
    required this.mediaLabel,
    required this.dragHandle,
  })  : _surface = AppColors.surface,
        _border = AppColors.border,
        _titleColor = AppColors.textColor,
        _subtitleColor = AppColors.subTextColor,
        _handleColor = AppColors.iconMuted;

  const PostReorderCard.editor({
    super.key,
    required this.index,
    required this.thumbnail,
    required this.mediaLabel,
    required this.dragHandle,
  })  : _surface = AppColors.postEditorPanel,
        _border = AppColors.postEditorOnSurfaceMuted,
        _titleColor = AppColors.postEditorOnSurface,
        _subtitleColor = AppColors.postEditorOnSurfaceMuted,
        _handleColor = AppColors.postEditorOnSurfaceMuted;

  final int index;
  final Widget thumbnail;
  final String mediaLabel;
  final Widget dragHandle;

  final Color _surface;
  final Color _border;
  final Color _titleColor;
  final Color _subtitleColor;
  final Color _handleColor;

  static const double _thumb = 64;
  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    final n = index + 1;
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      clipBehavior: Clip.hardEdge,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _border.withValues(alpha: 0.45)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
          child: Row(
            children: [
              SizedBox(
                width: _thumb + 6,
                height: _thumb + 6,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      left: 4,
                      top: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.hardEdge,
                        child: ColoredBox(
                          color: _border.withValues(alpha: 0.12),
                          child: SizedBox(
                            width: _thumb,
                            height: _thumb,
                            child: thumbnail,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: Center(
                            child: Text(
                              '$n',
                              style: AppTextStyle.base(11, color: Colors.white, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Кадр $n',
                      style: AppTextStyle.base(16, color: _titleColor, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mediaLabel,
                      style: AppTextStyle.base(13, color: _subtitleColor, height: 1.25),
                    ),
                  ],
                ),
              ),
              IconTheme(
                data: IconThemeData(color: _handleColor, size: 26),
                child: dragHandle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
