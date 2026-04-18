import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_ig_adjust_panel.dart';
import 'package:side_project/feature/media_pick_edit/domain/media_aspect_preset.dart';
import 'package:side_project/feature/media_pick_edit/domain/media_pick_edit_config.dart';
import 'package:side_project/feature/post_create_page/presentation/page/post_create_models.dart';
import 'package:side_project/feature/post_create_page/presentation/page/post_edit_gpu_preview.dart';

const int _kCropEditorMaxSide = 2048;
const int _kCropEditorJpegQuality = 88;

Uint8List? _cropEditorNormalizeInIsolate(Uint8List raw) {
  try {
    final decoded = img.decodeImage(raw);
    if (decoded == null) {
      return null;
    }
    final w = decoded.width;
    final h = decoded.height;
    final long = w > h ? w : h;
    final img.Image out;
    if (long <= _kCropEditorMaxSide) {
      out = decoded;
    } else {
      final scale = _kCropEditorMaxSide / long;
      out = img.copyResize(
        decoded,
        width: (w * scale).round(),
        height: (h * scale).round(),
        interpolation: img.Interpolation.linear,
      );
    }
    return Uint8List.fromList(img.encodeJpg(out, quality: _kCropEditorJpegQuality));
  } catch (_) {
    return null;
  }
}

Future<Uint8List?> _cropEditorNormalizeWithFlutterUi(Uint8List raw) async {
  ui.Codec? codec;
  try {
    final buffer = await ui.ImmutableBuffer.fromUint8List(raw);
    codec = await ui.instantiateImageCodecWithSize(
      buffer,
      getTargetSize: (int iw, int ih) {
        final long = iw > ih ? iw : ih;
        if (long <= _kCropEditorMaxSide) {
          return const ui.TargetImageSize();
        }
        if (iw >= ih) {
          return ui.TargetImageSize(width: _kCropEditorMaxSide, height: null);
        }
        return ui.TargetImageSize(width: null, height: _kCropEditorMaxSide);
      },
    );
    final frame = await codec.getNextFrame();
    final uiImage = frame.image;
    final w = uiImage.width;
    final h = uiImage.height;
    final bd = await uiImage.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    uiImage.dispose();
    if (bd == null) {
      return null;
    }
    final im = img.Image.fromBytes(
      width: w,
      height: h,
      bytes: bd.buffer,
      rowStride: w * 4,
      format: img.Format.uint8,
      numChannels: 4,
      order: img.ChannelOrder.rgba,
    );
    return Uint8List.fromList(img.encodeJpg(im, quality: _kCropEditorJpegQuality));
  } catch (_) {
    return null;
  } finally {
    codec?.dispose();
  }
}

Future<Uint8List?> _postCreateBytesForCropEditor(Uint8List raw) async {
  final fromIsolate = await compute(_cropEditorNormalizeInIsolate, raw);
  if (fromIsolate != null) {
    return fromIsolate;
  }
  return _cropEditorNormalizeWithFlutterUi(raw);
}

/// Флаги для AppBar родителя (режим «Кадр» / «Готово» / прогресс).
class PostImageEditAppBarFlags {
  const PostImageEditAppBarFlags({
    this.cropSurface = false,
    this.cropReady = false,
    this.cropWorking = false,
  });

  final bool cropSurface;
  final bool cropReady;
  final bool cropWorking;

  PostImageEditAppBarFlags copyWith({bool? cropSurface, bool? cropReady, bool? cropWorking}) {
    return PostImageEditAppBarFlags(
      cropSurface: cropSurface ?? this.cropSurface,
      cropReady: cropReady ?? this.cropReady,
      cropWorking: cropWorking ?? this.cropWorking,
    );
  }
}

/// Один кадр: превью как на шаге «Изменить» у поста (зум, GPU/цветокор, инлайн-обрезка) + нижняя панель [AppIgAdjustPanel].
class PostCreateImageEditBody extends StatefulWidget {
  const PostCreateImageEditBody({
    super.key,
    required this.originalFile,
    required this.displayFile,
    required this.liveParams,
    required this.stripParams,
    required this.flowConfig,
    required this.aspectLabel,
    required this.onAspectLabelChanged,
    required this.onDisplayFileReplaced,
    this.appBarFlags,
  });

  /// Исходник с галереи (для повторной обрезки).
  final File originalFile;

  /// Текущее изображение в редакторе.
  final File displayFile;

  final ValueNotifier<PostImageEditParams> liveParams;
  final ValueNotifier<PostImageEditParams> stripParams;
  final MediaPickEditConfig flowConfig;

  /// Текущий аспект в формате `1x1`, `9x16` и т.д.
  final String aspectLabel;
  final ValueChanged<String> onAspectLabelChanged;

  /// После успешной обрезки: новый display-файл; родитель обновляет пути и байты.
  final Future<void> Function(File newDisplay) onDisplayFileReplaced;

  final ValueNotifier<PostImageEditAppBarFlags>? appBarFlags;

  @override
  State<PostCreateImageEditBody> createState() => PostCreateImageEditBodyState();
}

enum _AdjustTool { exposure, brightness, shadows, highlights, saturation, warmth, contrast, sharpness, crop }

class PostCreateImageEditBodyState extends State<PostCreateImageEditBody> {
  final TransformationController _zoomCtrl = TransformationController();

  Uint8List? _cropImageBytes;
  CropController _cropController = CropController();
  bool _cropEditorReady = false;
  bool _cropWorking = false;
  late MediaAspectPreset _cropAspectPreset;

  _AdjustTool? _activeAdjust;

  MediaAspectPreset get _defaultCropPreset {
    final r = widget.flowConfig.resolvedCropPresets;
    return r.contains(MediaAspectPreset.ratio1x1) ? MediaAspectPreset.ratio1x1 : r.first;
  }

  void _notifyAppBar([PostImageEditAppBarFlags? f]) {
    final n = widget.appBarFlags;
    if (n == null) {
      return;
    }
    // Нельзя обновлять [ValueNotifier], который слушает предок ([ValueListenableBuilder]),
    // пока идёт build — откладываем на конец кадра.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      n.value = f ?? _computeAppBarFlags();
    });
  }

  PostImageEditAppBarFlags _computeAppBarFlags() {
    final cropSurface = _activeAdjust == _AdjustTool.crop;
    final ready = _cropImageBytes != null && _cropEditorReady && !_cropWorking;
    return PostImageEditAppBarFlags(
      cropSurface: cropSurface,
      cropReady: cropSurface && ready,
      cropWorking: cropSurface && _cropWorking,
    );
  }

  @override
  void initState() {
    super.initState();
    _cropAspectPreset = widget.flowConfig.resolvedCropPresets.firstWhere(
      (m) => m.fileAspect == widget.aspectLabel,
      orElse: () => _defaultCropPreset,
    );
    _notifyAppBar();
  }

  @override
  void didUpdateWidget(PostCreateImageEditBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.displayFile.path != widget.displayFile.path) {
      resetZoom();
    }
  }

  @override
  void dispose() {
    _zoomCtrl.dispose();
    super.dispose();
  }

  void resetZoom() {
    _zoomCtrl.value = Matrix4.identity();
  }

  void _syncStripToLive() {
    widget.stripParams.value = widget.liveParams.value;
  }

  void _clearCropSession() {
    _cropImageBytes = null;
    _cropEditorReady = false;
    _cropWorking = false;
    _cropAspectPreset = _defaultCropPreset;
    _cropController = CropController();
  }

  Future<void> _prepareCropSession() async {
    try {
      final raw = await widget.originalFile.readAsBytes();
      if (!mounted) {
        return;
      }
      final normalized = await _postCreateBytesForCropEditor(raw);
      if (!mounted) {
        return;
      }
      if (normalized == null) {
        if (mounted) {
          AppSnackBar.show(
            context,
            message: 'Не удалось открыть фото для обрезки. Попробуйте другое изображение.',
            kind: AppSnackBarKind.error,
          );
          setState(() {
            _activeAdjust = null;
            _clearCropSession();
          });
          _notifyAppBar();
        }
        return;
      }
      setState(() {
        _cropImageBytes = normalized;
        _cropController = CropController();
        _cropEditorReady = false;
        _cropWorking = false;
      });
      _notifyAppBar();
    } catch (_) {
      if (mounted) {
        setState(() {
          _activeAdjust = null;
          _clearCropSession();
        });
        _notifyAppBar();
      }
    }
  }

  void _setCropAspectPreset(MediaAspectPreset mode) {
    if (_cropAspectPreset == mode) {
      return;
    }
    setState(() {
      _cropAspectPreset = mode;
      widget.onAspectLabelChanged(mode.fileAspect);
      _cropController = CropController();
      _cropEditorReady = false;
    });
  }

  Future<void> _onCropResult(CropResult result) async {
    if (!mounted) {
      return;
    }
    setState(() => _cropWorking = false);
    _notifyAppBar();
    switch (result) {
      case CropSuccess(:final croppedImage):
        try {
          final dir = await getTemporaryDirectory();
          final f = File('${dir.path}/cluster_crop_${DateTime.now().microsecondsSinceEpoch}.jpg');
          await f.writeAsBytes(croppedImage, flush: true);
          if (!mounted) {
            return;
          }
          widget.liveParams.value = const PostImageEditParams();
          widget.stripParams.value = const PostImageEditParams();
          setState(() {
            _activeAdjust = null;
            _clearCropSession();
          });
          await widget.onDisplayFileReplaced(f);
          if (mounted) {
            resetZoom();
          }
          _notifyAppBar();
        } catch (e) {
          if (mounted) {
            AppSnackBar.show(
              context,
              message: 'Не удалось сохранить обрезку: $e',
              kind: AppSnackBarKind.error,
            );
          }
        }
      case CropFailure(:final cause):
        if (mounted) {
          AppSnackBar.show(context, message: '$cause', kind: AppSnackBarKind.error);
        }
    }
  }

  void applyCrop() {
    if (!_cropEditorReady || _cropWorking) {
      return;
    }
    setState(() => _cropWorking = true);
    _notifyAppBar();
    _cropController.crop();
  }

  bool get canApplyCrop =>
      _activeAdjust == _AdjustTool.crop && _cropImageBytes != null && _cropEditorReady && !_cropWorking;

  /// Закрыть UI обрезки без применения (как «назад» у поста). `true`, если событие обработано.
  bool exitCropIfActive() {
    if (_activeAdjust == _AdjustTool.crop) {
      setState(() {
        _activeAdjust = null;
        _clearCropSession();
      });
      _notifyAppBar();
      return true;
    }
    return false;
  }

  void _updateParam(PostImageEditParams Function(PostImageEditParams p) fn, {bool syncStrip = false}) {
    final next = fn(widget.liveParams.value);
    widget.liveParams.value = next;
    if (syncStrip) {
      widget.stripParams.value = next;
    }
  }

  String _toolLabel(_AdjustTool t) => switch (t) {
    _AdjustTool.exposure => 'Экспозиция',
    _AdjustTool.brightness => 'Яркость',
    _AdjustTool.shadows => 'Тени',
    _AdjustTool.highlights => 'Света',
    _AdjustTool.saturation => 'Насыщенность',
    _AdjustTool.warmth => 'Тепло',
    _AdjustTool.contrast => 'Контраст',
    _AdjustTool.sharpness => 'Резкость',
    _AdjustTool.crop => 'Кадр',
  };

  void _onAdjustToolTapped(_AdjustTool t) {
    if (t == _AdjustTool.crop) {
      if (_activeAdjust == _AdjustTool.crop) {
        setState(() {
          _activeAdjust = null;
          _clearCropSession();
        });
        _notifyAppBar();
        return;
      }
      setState(() {
        _activeAdjust = _AdjustTool.crop;
        _cropAspectPreset = widget.flowConfig.resolvedCropPresets.firstWhere(
          (m) => m.fileAspect == widget.aspectLabel,
          orElse: () => _defaultCropPreset,
        );
        _cropController = CropController();
        _cropEditorReady = false;
        _cropWorking = false;
        _cropImageBytes = null;
      });
      _notifyAppBar(PostImageEditAppBarFlags(cropSurface: true, cropReady: false, cropWorking: false));
      _prepareCropSession();
      resetZoom();
      return;
    }
    setState(() {
      if (_activeAdjust == _AdjustTool.crop) {
        _clearCropSession();
      }
      if (_activeAdjust == t) {
        _activeAdjust = null;
      } else {
        _activeAdjust = t;
      }
    });
    _notifyAppBar();
  }

  Widget _igSliderSymmetric(double value, ValueChanged<double> onChanged) {
    return AppIgSlider.symmetric(context, value: value, onChanged: onChanged, onChangeEnd: _syncStripToLive);
  }

  Widget _igSliderSharpness(double value, ValueChanged<double> onChanged) {
    return AppIgSlider.sharpness(context, value: value, onChanged: onChanged, onChangeEnd: _syncStripToLive);
  }

  Widget _buildAdjustSliderPanel() {
    final t = _activeAdjust;
    if (t == null) {
      return const SizedBox.shrink();
    }
    if (t == _AdjustTool.crop) {
      return _buildCropPresetPanel();
    }

    return ValueListenableBuilder<PostImageEditParams>(
      valueListenable: widget.liveParams,
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _toolLabel(t),
                textAlign: TextAlign.center,
                style: AppTextStyle.base(
                  15,
                  color: AppColors.postEditorOnSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              switch (t) {
                _AdjustTool.exposure => _igSliderSymmetric(
                  p.exposure,
                  (v) => _updateParam((x) => x.copyWith(exposure: v)),
                ),
                _AdjustTool.brightness => _igSliderSymmetric(
                  p.brightness,
                  (v) => _updateParam((x) => x.copyWith(brightness: v)),
                ),
                _AdjustTool.shadows => _igSliderSymmetric(
                  p.shadows,
                  (v) => _updateParam((x) => x.copyWith(shadows: v)),
                ),
                _AdjustTool.highlights => _igSliderSymmetric(
                  p.highlights,
                  (v) => _updateParam((x) => x.copyWith(highlights: v)),
                ),
                _AdjustTool.saturation => _igSliderSymmetric(
                  p.saturation,
                  (v) => _updateParam((x) => x.copyWith(saturation: v)),
                ),
                _AdjustTool.warmth => _igSliderSymmetric(
                  p.warmth,
                  (v) => _updateParam((x) => x.copyWith(warmth: v)),
                ),
                _AdjustTool.contrast => _igSliderSymmetric(
                  p.contrast,
                  (v) => _updateParam((x) => x.copyWith(contrast: v)),
                ),
                _AdjustTool.sharpness => _igSliderSharpness(
                  p.sharpness.clamp(0.0, 1.0),
                  (v) => _updateParam((x) => x.copyWith(sharpness: v)),
                ),
                _AdjustTool.crop => const SizedBox.shrink(),
              },
            ],
          ),
        );
      },
    );
  }

  Widget _buildCropAspectChip({required String label, required bool selected, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.18)
                : AppColors.inputBackground.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.inputBorder,
              width: selected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyle.base(
              12,
              color: selected ? AppColors.primary : AppColors.postEditorOnSurfaceMuted,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCropPresetPanel() {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final ready = _cropImageBytes != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 4, 14, 4 + bottomInset * 0.2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Text(
              'Формат',
              style: AppTextStyle.base(
                11,
                color: AppColors.postEditorOnSurfaceDim,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!ready)
            const SizedBox(
              height: 40,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.primary),
                ),
              ),
            )
          else
            SizedBox(
              height: 40,
              width: double.infinity,
              child: IgnorePointer(
                ignoring: _cropWorking,
                child: Opacity(
                  opacity: _cropWorking ? 0.45 : 1,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.flowConfig.resolvedCropPresets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final m = widget.flowConfig.resolvedCropPresets[i];
                      return _buildCropAspectChip(
                        label: m.label,
                        selected: _cropAspectPreset == m,
                        onTap: () => _setCropAspectPreset(m),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditZoomablePhoto(File file) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onDoubleTap: resetZoom,
          behavior: HitTestBehavior.deferToChild,
          child: InteractiveViewer(
            transformationController: _zoomCtrl,
            minScale: 1.0,
            maxScale: 4.0,
            clipBehavior: Clip.hardEdge,
            boundaryMargin: const EdgeInsets.all(120),
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: ValueListenableBuilder<PostImageEditParams>(
                valueListenable: widget.liveParams,
                builder: (context, par, _) {
                  final Widget img = par.isNeutral
                      ? Image.file(
                          file,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.low,
                          isAntiAlias: true,
                        )
                      : PostEditGpuPreview(file: file, params: par, fit: BoxFit.contain);
                  return Center(child: img);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditPreviewFrame() {
    return ColoredBox(
      color: AppColors.postEditorBackground,
      child: _activeAdjust == _AdjustTool.crop
          ? (_cropImageBytes == null
                ? const ColoredBox(
                    color: AppColors.postEditorBackground,
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                : SizedBox.expand(
                    child: Crop(
                      key: ValueKey(_cropAspectPreset),
                      image: _cropImageBytes!,
                      controller: _cropController,
                      onCropped: _onCropResult,
                      aspectRatio: _cropAspectPreset.aspectRatio,
                      withCircleUi: false,
                      interactive: true,
                      fixCropRect: true,
                      clipBehavior: Clip.none,
                      radius: 0,
                      baseColor: AppColors.postEditorBackground,
                      maskColor: Colors.black.withValues(alpha: 0.42),
                      progressIndicator: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                      ),
                      onStatusChanged: (status) {
                        if (status == CropStatus.ready) {
                          setState(() => _cropEditorReady = true);
                          _notifyAppBar();
                        } else if (status == CropStatus.loading) {
                          setState(() => _cropEditorReady = false);
                          _notifyAppBar();
                        }
                      },
                    ),
                  ))
          : RepaintBoundary(child: _buildEditZoomablePhoto(widget.displayFile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final slot = widget.displayFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildEditPreviewFrame()),
        ColoredBox(
          color: AppColors.postEditorPanel,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIgAdjustPanel<_AdjustTool>(
                  imageLabel: 'Фильтр',
                  stripParams: widget.stripParams,
                  showFilters: _activeAdjust != _AdjustTool.crop,
                  showTools: true,
                  onFilterTap: (f) => _updateParam((x) => x.copyWith(styleFilter: f), syncStrip: true),
                  filterThumbnailBuilder: (filter, baseParams) =>
                      PostStyleFilterThumbnail(file: slot, baseParams: baseParams, chipStyle: filter),
                  tools: _AdjustTool.values,
                  activeTool: _activeAdjust,
                  onToolTap: _onAdjustToolTapped,
                  toolLabel: _toolLabel,
                  sliderPanel: AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: _activeAdjust == null
                        ? const SizedBox(width: double.infinity)
                        : _buildAdjustSliderPanel(),
                  ),
                ),
                SizedBox(height: 4 + bottomInset * 0.25),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
