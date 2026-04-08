import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/ig_edit/ig_edit_models.dart';

// ignore_for_file: file_names

/// Общая панель “как в Instagram”: фильтры + инструменты + (опционально) панель слайдера.
///
/// Это “родитель” UI для обоих потоков: создание поста и создание кластера.
class AppIgAdjustPanel<TTool> extends StatelessWidget {
  const AppIgAdjustPanel({
    super.key,
    required this.imageLabel,
    required this.stripParams,
    required this.onFilterTap,
    required this.filterThumbnailBuilder,
    required this.tools,
    required this.activeTool,
    required this.onToolTap,
    required this.toolLabel,
    required this.sliderPanel,
    required this.showFilters,
    required this.showTools,
  });

  /// Обычно “Фильтр”.
  final String imageLabel;

  final ValueListenable<PostImageEditParams> stripParams;

  final void Function(PostStyleFilter filter) onFilterTap;

  /// Миниатюра фильтра (разная для поста/кластера).
  final Widget Function(PostStyleFilter filter, PostImageEditParams baseParams) filterThumbnailBuilder;

  final List<TTool> tools;
  final TTool? activeTool;
  final ValueChanged<TTool> onToolTap;
  final String Function(TTool tool) toolLabel;

  /// Снаружи можно передать AnimatedSize/Container — тут только слот.
  final Widget sliderPanel;

  final bool showFilters;
  final bool showTools;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showFilters)
          _IgFilterStrip(
            label: imageLabel,
            params: stripParams,
            onFilterTap: onFilterTap,
            thumbBuilder: filterThumbnailBuilder,
          ),
        if (showTools) ...[
          sliderPanel,
          _IgToolStrip<TTool>(
            tools: tools,
            active: activeTool,
            onTap: onToolTap,
            label: toolLabel,
          ),
        ],
      ],
    );
  }
}

class _IgFilterStrip extends StatelessWidget {
  const _IgFilterStrip({
    required this.label,
    required this.params,
    required this.onFilterTap,
    required this.thumbBuilder,
  });

  final String label;
  final ValueListenable<PostImageEditParams> params;
  final void Function(PostStyleFilter filter) onFilterTap;
  final Widget Function(PostStyleFilter filter, PostImageEditParams baseParams) thumbBuilder;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            child: Text(
              label,
              style: AppTextStyle.base(
                11,
                color: AppColors.postEditorOnSurfaceDim,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 96,
            child: ValueListenableBuilder<PostImageEditParams>(
              valueListenable: params,
              builder: (context, p, _) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                  itemCount: PostStyleFilter.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final f = PostStyleFilter.values[i];
                    final sel = p.styleFilter == f;
                    return RepaintBoundary(
                      child: Tooltip(
                        message: f.hint,
                        child: GestureDetector(
                          onTap: () => onFilterTap(f),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 54,
                                height: 54,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: sel ? AppColors.primary : AppColors.postEditorOnSurfaceHint,
                                    width: sel ? 2.5 : 1,
                                  ),
                                  boxShadow: sel
                                      ? [
                                          BoxShadow(
                                            color: AppColors.shadowDark.withValues(alpha: 0.08),
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: thumbBuilder(f, p),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 76,
                                child: Text(
                                  f.label,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.base(
                                    10,
                                    color: sel ? AppColors.postEditorOnSurface : AppColors.postEditorOnSurfaceMuted,
                                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IgToolStrip<TTool> extends StatelessWidget {
  const _IgToolStrip({
    required this.tools,
    required this.active,
    required this.onTap,
    required this.label,
  });

  final List<TTool> tools;
  final TTool? active;
  final ValueChanged<TTool> onTap;
  final String Function(TTool tool) label;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 46,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: tools.length,
          separatorBuilder: (_, __) => const SizedBox(width: 2),
          itemBuilder: (context, index) {
            final tool = tools[index];
            final sel = active == tool;
            return GestureDetector(
              onTap: () => onTap(tool),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label(tool),
                      style: AppTextStyle.base(
                        13,
                        color: sel ? AppColors.postEditorOnSurface : AppColors.postEditorOnSurfaceMuted,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2,
                      width: sel ? 22 : 0,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Слайдеры “как в редакторе поста” — чтобы кластер и пост выглядели одинаково.
abstract final class AppIgSlider {
  static SliderThemeData _theme(SliderThemeData base) => base.copyWith(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.borderSoft,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.postEditorSliderOverlay,
      );

  static Widget symmetric(
    BuildContext context, {
    required double value,
    required ValueChanged<double> onChanged,
    VoidCallback? onChangeEnd,
    int divisions = 40,
  }) {
    final theme = SliderTheme.of(context);
    return SliderTheme(
      data: _theme(theme),
      child: Slider(
        value: value.clamp(-1.0, 1.0),
        min: -1,
        max: 1,
        divisions: divisions,
        onChanged: onChanged,
        onChangeEnd: (_) => onChangeEnd?.call(),
      ),
    );
  }

  static Widget sharpness(
    BuildContext context, {
    required double value,
    required ValueChanged<double> onChanged,
    VoidCallback? onChangeEnd,
    int divisions = 20,
  }) {
    final theme = SliderTheme.of(context);
    return SliderTheme(
      data: _theme(theme),
      child: Slider(
        value: value.clamp(0.0, 1.0),
        min: 0,
        max: 1,
        divisions: divisions,
        onChanged: onChanged,
        onChangeEnd: (_) => onChangeEnd?.call(),
      ),
    );
  }
}

