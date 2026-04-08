import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_ig_adjust_panel.dart';
import 'package:side_project/feature/post_create_page/presentation/page/post_create_models.dart';
import 'package:side_project/feature/post_create_page/presentation/page/post_edit_gpu_preview.dart';

enum ClusterCoverAdjustTool {
  exposure,
  brightness,
  shadows,
  highlights,
  saturation,
  warmth,
  contrast,
  sharpness,
}

/// Переиспользуемый 2-й этап: редактирование обложки кластера как в посте (пресеты + инструменты + crop).
///
/// - [bytes] — картинка для превью (raw или уже cropped).
/// - [params] — текущее состояние слайдеров/пресета (снаружи, чтобы сохранять между экранами).
/// - [onCrop] — открыть кадрирование (квадрат 1:1).
/// - [onContinue] — действие “Далее” (обычно: bake в isolate и переход на следующий шаг).
class ClusterCoverEditStep extends StatefulWidget {
  const ClusterCoverEditStep({
    super.key,
    required this.bytes,
    required this.params,
    required this.onCrop,
    required this.onContinue,
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(14),
      topRight: Radius.circular(10),
      bottomRight: Radius.circular(14),
      bottomLeft: Radius.circular(10),
    ),
  });

  final Uint8List bytes;
  final ValueNotifier<PostImageEditParams> params;
  final VoidCallback? onCrop;
  final Future<void> Function()? onContinue;
  final BorderRadius borderRadius;

  @override
  State<ClusterCoverEditStep> createState() => _ClusterCoverEditStepState();
}

class _ClusterCoverEditStepState extends State<ClusterCoverEditStep> {
  ClusterCoverAdjustTool? _activeTool;

  String _toolLabel(ClusterCoverAdjustTool t) => switch (t) {
    ClusterCoverAdjustTool.exposure => 'Экспозиция',
    ClusterCoverAdjustTool.brightness => 'Яркость',
    ClusterCoverAdjustTool.shadows => 'Тени',
    ClusterCoverAdjustTool.highlights => 'Света',
    ClusterCoverAdjustTool.saturation => 'Насыщенность',
    ClusterCoverAdjustTool.warmth => 'Тепло',
    ClusterCoverAdjustTool.contrast => 'Контраст',
    ClusterCoverAdjustTool.sharpness => 'Резкость',
  };

  // (значения слайдеров обрабатываются прямо в sliderPanel через widget.params)

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: ClipRRect(
              borderRadius: widget.borderRadius,
              child: AspectRatio(
                aspectRatio: 1,
                child: ValueListenableBuilder<PostImageEditParams>(
                  valueListenable: widget.params,
                  builder: (context, p, _) {
                    final m = p.isNeutral ? null : postEditCombinedColorMatrix(p);
                    Widget img = Image.memory(
                      widget.bytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.low,
                    );
                    if (m != null) {
                      img = ColorFiltered(colorFilter: ColorFilter.matrix(m), child: img);
                    }
                    return img;
                  },
                ),
              ),
            ),
          ),
        ),
        AppIgAdjustPanel<ClusterCoverAdjustTool>(
          imageLabel: 'Фильтр',
          stripParams: widget.params,
          showFilters: true,
          showTools: true,
          onFilterTap: (f) => widget.params.value = widget.params.value.copyWith(styleFilter: f),
          filterThumbnailBuilder: (filter, baseParams) {
            final m = filter == PostStyleFilter.none
                ? null
                : postEditCombinedColorMatrix(baseParams.copyWith(styleFilter: filter));
            Widget thumb = Image.memory(widget.bytes, fit: BoxFit.cover, gaplessPlayback: true, filterQuality: FilterQuality.low);
            if (m != null) {
              thumb = ColorFiltered(colorFilter: ColorFilter.matrix(m), child: thumb);
            }
            return thumb;
          },
          tools: ClusterCoverAdjustTool.values,
          activeTool: _activeTool,
          onToolTap: (t) => setState(() => _activeTool = _activeTool == t ? null : t),
          toolLabel: _toolLabel,
          sliderPanel: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _activeTool == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                    child: ValueListenableBuilder<PostImageEditParams>(
                      valueListenable: widget.params,
                      builder: (context, p, _) {
                        final t = _activeTool!;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _toolLabel(t),
                              textAlign: TextAlign.center,
                              style: AppTextStyle.base(15, color: AppColors.postEditorOnSurface, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            switch (t) {
                              ClusterCoverAdjustTool.exposure => AppIgSlider.symmetric(
                                context,
                                value: p.exposure,
                                onChanged: (v) => widget.params.value = p.copyWith(exposure: v),
                              ),
                              ClusterCoverAdjustTool.brightness => AppIgSlider.symmetric(
                                context,
                                value: p.brightness,
                                onChanged: (v) => widget.params.value = p.copyWith(brightness: v),
                              ),
                              ClusterCoverAdjustTool.shadows => AppIgSlider.symmetric(
                                context,
                                value: p.shadows,
                                onChanged: (v) => widget.params.value = p.copyWith(shadows: v),
                              ),
                              ClusterCoverAdjustTool.highlights => AppIgSlider.symmetric(
                                context,
                                value: p.highlights,
                                onChanged: (v) => widget.params.value = p.copyWith(highlights: v),
                              ),
                              ClusterCoverAdjustTool.saturation => AppIgSlider.symmetric(
                                context,
                                value: p.saturation,
                                onChanged: (v) => widget.params.value = p.copyWith(saturation: v),
                              ),
                              ClusterCoverAdjustTool.warmth => AppIgSlider.symmetric(
                                context,
                                value: p.warmth,
                                onChanged: (v) => widget.params.value = p.copyWith(warmth: v),
                              ),
                              ClusterCoverAdjustTool.contrast => AppIgSlider.symmetric(
                                context,
                                value: p.contrast,
                                onChanged: (v) => widget.params.value = p.copyWith(contrast: v),
                              ),
                              ClusterCoverAdjustTool.sharpness => AppIgSlider.sharpness(
                                context,
                                value: p.sharpness,
                                onChanged: (v) => widget.params.value = p.copyWith(sharpness: v),
                              ),
                            },
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomPad),
          child: Row(
            children: [
              Expanded(child: AppButton(text: 'Кадр', onPressed: widget.onCrop)),
              const SizedBox(width: 12),
              Expanded(child: AppButton(text: 'Далее', onPressed: widget.onContinue == null ? null : () => widget.onContinue!.call())),
            ],
          ),
        ),
      ],
    );
  }
}

