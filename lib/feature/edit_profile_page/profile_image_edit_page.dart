import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';

/// Редактор: обложка, аватар, кластер, пост — с пресетами кадра и свободной обрезкой.
@RoutePage()
class ProfileImageEditPage extends StatefulWidget {
  const ProfileImageEditPage({
    super.key,
    required this.imageBytes,
    required this.isCover,
    this.clusterCollectionThumb = false,
    this.postFeedCrop = false,
    this.freeFormCrop = false,
  });

  final Uint8List imageBytes;
  final bool isCover;

  /// Квадрат под миниатюру 64×64 в [ProfileCollectionCard], не широкая обложка профиля.
  final bool clusterCollectionThumb;

  /// Вертикальный кадр 4:5 для поста (как типичная карточка в ленте).
  final bool postFeedCrop;

  /// Свободная рамка: любое соотношение сторон, углы тянутся (пост и т.п.).
  final bool freeFormCrop;

  @override
  State<ProfileImageEditPage> createState() => _ProfileImageEditPageState();
}

/// Пресеты кадра для поста ([freeFormCrop]). Фиксированные — только масштаб/сдвиг фото; «Свободно» — тянуть углы.
enum _PostCropAspectMode { square, story, feed, portrait, landscape, free }

extension on _PostCropAspectMode {
  String get label => switch (this) {
    _PostCropAspectMode.square => '1:1',
    _PostCropAspectMode.story => '9:16',
    _PostCropAspectMode.feed => '4:5',
    _PostCropAspectMode.portrait => '3:4',
    _PostCropAspectMode.landscape => '4:3',
    _PostCropAspectMode.free => 'Свободно',
  };

  double? get aspectRatio => switch (this) {
    _PostCropAspectMode.square => 1.0,
    _PostCropAspectMode.story => 9 / 16,
    _PostCropAspectMode.feed => 4 / 5,
    _PostCropAspectMode.portrait => 3 / 4,
    _PostCropAspectMode.landscape => 4 / 3,
    _PostCropAspectMode.free => null,
  };

  bool get fixCropRect => this != _PostCropAspectMode.free;
}

class _ProfileImageEditPageState extends State<ProfileImageEditPage> {
  CropController _cropController = CropController();
  bool _editorReady = false;
  bool _cropping = false;

  _PostCropAspectMode _postAspectMode = _PostCropAspectMode.square;

  /// Соотношение как у блока обложки на экране редактирования: ширина − отступы, высота 150.
  double _coverAspectRatio(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    const horizontalPadding = 24.0;
    const coverHeight = 150.0;
    return (w - horizontalPadding) / coverHeight;
  }

  void _switchPostAspectMode(_PostCropAspectMode mode) {
    if (_postAspectMode == mode) {
      return;
    }
    setState(() {
      _postAspectMode = mode;
      _cropController = CropController();
      _editorReady = false;
    });
  }

  void _onCropped(CropResult result) {
    if (!mounted) return;
    setState(() => _cropping = false);
    switch (result) {
      case CropSuccess(:final croppedImage):
        context.router.pop<Uint8List>(croppedImage);
      case CropFailure(:final cause):
        AppSnackBar.show(context, message: '$cause', kind: AppSnackBarKind.error);
    }
  }

  void _confirm() {
    if (!_editorReady || _cropping) return;
    setState(() => _cropping = true);
    // Пост — только четырёхугольный кадр, никогда круг.
    if (widget.freeFormCrop) {
      _cropController.crop();
      return;
    }
    if (_useCircleCrop) {
      _cropController.cropCircle();
    } else {
      _cropController.crop();
    }
  }

  bool get _clusterThumb => widget.clusterCollectionThumb;
  bool get _postFeed => widget.postFeedCrop;
  bool get _freeForm => widget.freeFormCrop;
  bool get _useCircleCrop => !widget.isCover && !_clusterThumb && !_postFeed && !_freeForm;

  String _postAspectHint() {
    switch (_postAspectMode) {
      case _PostCropAspectMode.square:
        return 'Квадрат 1:1 — жестом увеличьте и сдвиньте фото внутри рамки.';
      case _PostCropAspectMode.story:
        return 'Вертикаль 9:16 как в сторис — только масштаб и сдвиг фото.';
      case _PostCropAspectMode.feed:
        return 'Портрет 4:5 под ленту — масштаб и сдвиг.';
      case _PostCropAspectMode.portrait:
        return 'Портрет 3:4 — масштаб и сдвиг.';
      case _PostCropAspectMode.landscape:
        return 'Альбом 4:3 — масштаб и сдвиг.';
      case _PostCropAspectMode.free:
        return 'Тяните за углы «L» или сдвигайте/масштабируйте фото. Пресеты выше — фиксированное соотношение без тяг за углы.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCover = widget.isCover;
    final bool postFree = _freeForm && _postAspectMode == _PostCropAspectMode.free;

    final double? aspect = _freeForm
        ? _postAspectMode.aspectRatio
        : _postFeed
        ? 4 / 5
        : _clusterThumb
        ? 1.0
        : (isCover ? _coverAspectRatio(context) : 1.0);
    // Пост: явно без круглой маски и круглого выреза (у аватара — круг).
    final withCircleUi = widget.freeFormCrop ? false : _useCircleCrop;
    final cropRadius = _freeForm ? 0.0 : (_postFeed ? 16.0 : (_clusterThumb ? 12.0 : (isCover ? 24.0 : 0.0)));
    final fixCropRect = !_freeForm ? true : _postAspectMode.fixCropRect;

    final String title;
    final String hint;
    if (_freeForm) {
      title = 'Обрезка для поста';
      hint = _postAspectHint();
    } else if (_postFeed) {
      title = 'Кадр поста';
      hint = 'Формат 4:5, как в ленте: масштаб и сдвиг, как в редакторе историй.';
    } else if (_clusterThumb) {
      title = 'Обложка кластера';
      hint = 'Квадрат, как превью в карточке коллекции: масштаб и сдвиг.';
    } else if (isCover) {
      title = 'Обложка';
      hint = 'Подгоните фото под рамку: жестом масштабируйте и сдвигайте.';
    } else {
      title = 'Аватар';
      hint = 'Подгоните фото под круг: жестом масштабируйте и сдвигайте.';
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppAppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(AppIcons.back.icon, color: Colors.white),
          onPressed: () => context.router.maybePop(),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: AppTextStyle.base(17, color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: (!_editorReady || _cropping) ? null : _confirm,
            child: Text(
              'Готово',
              style: AppTextStyle.base(16, color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(hint, style: AppTextStyle.base(14, color: Colors.white70, height: 1.35)),
            ),
            if (_freeForm)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      for (final m in _PostCropAspectMode.values) ...[
                        if (m != _PostCropAspectMode.values.first) const SizedBox(width: 8),
                        _postAspectChip(
                          label: m.label,
                          selected: _postAspectMode == m,
                          onTap: () => _switchPostAspectMode(m),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Crop(
                key: ValueKey<_PostCropAspectMode>(_postAspectMode),
                image: widget.imageBytes,
                controller: _cropController,
                onCropped: _onCropped,
                aspectRatio: aspect,
                withCircleUi: withCircleUi,
                interactive: true,
                fixCropRect: fixCropRect,
                clipBehavior: Clip.none,
                radius: cropRadius,
                baseColor: Colors.black,
                maskColor: Colors.black.withValues(alpha: 0.55),
                progressIndicator: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                ),
                onStatusChanged: (status) {
                  if (status == CropStatus.ready) {
                    setState(() => _editorReady = true);
                  } else if (status == CropStatus.loading) {
                    setState(() => _editorReady = false);
                  }
                },
                cornerDotBuilder: _freeForm
                    ? (postFree ? _postFreeCornerHandle : _postFixedRatioCornerPassthrough)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Углы не тянутся при фикс. соотношении — пропускаем жесты к слою с фото.
  Widget _postFixedRatioCornerPassthrough(double size, EdgeAlignment _) {
    return IgnorePointer(
      ignoring: true,
      child: SizedBox(width: size, height: size),
    );
  }

  /// Крупные «L» в углах — проще попасть и понять направление, чем маленький квадрат.
  Widget _postFreeCornerHandle(double size, EdgeAlignment align) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CropCornerBracketPainter(align: align)),
    );
  }

  Widget _postAspectChip({required String label, required bool selected, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.22) : Colors.white10,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.primary : Colors.white24, width: selected ? 2 : 1),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyle.base(
              13,
              color: selected ? AppColors.primary : Colors.white70,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Рисует угловую скобку «L» для свободной обрезки (в пределах [dotTotalSize] ≈ 32).
class _CropCornerBracketPainter extends CustomPainter {
  _CropCornerBracketPainter({required this.align});

  final EdgeAlignment align;

  static const double _arm = 12;
  static const double _inset = 2;
  static const double _stroke = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = _stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final outline = Paint()
      ..color = Colors.black54
      ..strokeWidth = _stroke + 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void drawL(Offset a, Offset b, Offset c) {
      canvas.drawLine(a, b, outline);
      canvas.drawLine(b, c, outline);
      canvas.drawLine(a, b, paint);
      canvas.drawLine(b, c, paint);
    }

    final w = size.width;
    final h = size.height;
    switch (align) {
      case EdgeAlignment.topLeft:
        drawL(Offset(_inset, _inset + _arm), Offset(_inset, _inset), Offset(_inset + _arm, _inset));
      case EdgeAlignment.topRight:
        drawL(
          Offset(w - _inset, _inset + _arm),
          Offset(w - _inset, _inset),
          Offset(w - _inset - _arm, _inset),
        );
      case EdgeAlignment.bottomLeft:
        drawL(
          Offset(_inset, h - _inset - _arm),
          Offset(_inset, h - _inset),
          Offset(_inset + _arm, h - _inset),
        );
      case EdgeAlignment.bottomRight:
        drawL(
          Offset(w - _inset, h - _inset - _arm),
          Offset(w - _inset, h - _inset),
          Offset(w - _inset - _arm, h - _inset),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _CropCornerBracketPainter oldDelegate) => oldDelegate.align != align;
}
