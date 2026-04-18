import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:side_project/core/dependencies/get_it.dart' show sl;
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_ig_adjust_panel.dart';
import 'package:side_project/core/shared/app_single_select.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/shared/app_text_field.dart';
import 'package:side_project/core/shared/ig_edit/ig_edit_bake.dart';
import 'package:side_project/feature/media_pick_edit/media_pick_edit.dart';
import 'package:side_project/feature/post_create_page/data/models/post_create_draft.dart';
import 'package:side_project/feature/post_create_page/data/models/post_create_media_item.dart';
import 'package:side_project/feature/post_create_page/presentation/cubit/post_create_cubit.dart';
import 'package:side_project/feature/post_create_page/presentation/page/post_create_gallery_step.dart';
import 'package:side_project/feature/post_create_page/presentation/page/post_create_models.dart';
import 'package:side_project/feature/post_create_page/presentation/page/post_create_video_preview.dart';
import 'package:side_project/feature/post_create_page/presentation/page/post_edit_gpu_preview.dart';
import 'package:side_project/feature/post_create_page/presentation/widget/post_reorder_bottom_sheet.dart';
import 'package:side_project/feature/post_create_page/presentation/widget/post_reorder_card.dart';
import 'package:side_project/feature/profile/data/models/profile_search_hit.dart';
import 'package:side_project/feature/profile/presentation/widget/profile_people_search_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const int _kCropEditorMaxSide = 2048;
const int _kCropEditorJpegQuality = 88;

/// Быстрый путь в [compute]: JPEG/PNG/WebP → даунскейл → JPEG (без PNG-энкода полного кадра).
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

/// HEIC и др.: нативный декод с ограничением **длинной** стороны (нельзя задавать оба target 2048 — иначе квадратное растягивание).
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

/// Удобный размер для [crop_your_image]: меньше пикселей — быстрее второй парсинг в редакторе.
Future<Uint8List?> _postCreateBytesForCropEditor(Uint8List raw) async {
  final fromIsolate = await compute(_cropEditorNormalizeInIsolate, raw);
  if (fromIsolate != null) {
    return fromIsolate;
  }
  return _cropEditorNormalizeWithFlutterUi(raw);
}

String? _nullableTrimField(String value) {
  final t = value.trim();
  return t.isEmpty ? null : t;
}

/// Галерея → редактирование → детали публикации.
///
/// Для других сценариев: [mediaConfig] (лимит фото, пресеты кадра, видео),
/// [customThirdStep] — свой UI вместо стандартного экрана публикации (получает [MediaPickEditOutcome]).
@RoutePage()
class PostCreatePage extends StatelessWidget {
  const PostCreatePage({super.key, this.mediaConfig, this.customThirdStep});

  /// Если null — [MediaPickEditConfig.postDefault].
  final MediaPickEditConfig? mediaConfig;

  /// Не сериализуется в auto_route; только при открытии через `Navigator` из кода.
  final Widget Function(BuildContext context, MediaPickEditOutcome outcome)? customThirdStep;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<PostCreateCubit>();
        final uid = Supabase.instance.client.auth.currentUser?.id;
        if (uid != null) {
          cubit.load(uid);
        }
        return cubit;
      },
      child: _PostCreateFlow(mediaConfig: mediaConfig, customThirdStep: customThirdStep),
    );
  }
}

class _PostCreateFlow extends StatefulWidget {
  const _PostCreateFlow({this.mediaConfig, this.customThirdStep});

  final MediaPickEditConfig? mediaConfig;
  final Widget Function(BuildContext context, MediaPickEditOutcome outcome)? customThirdStep;

  @override
  State<_PostCreateFlow> createState() => _PostCreateFlowState();
}

enum _PostStep { gallery, edit, details }

/// Отдельный параметр коррекции (как в Instagram: один инструмент — один слайдер).
enum _EditAdjustTool {
  exposure,
  brightness,
  shadows,
  highlights,
  saturation,
  warmth,
  contrast,
  sharpness,
  crop,
}

const String _kClusterNone = '';

class _PostCreateFlowState extends State<_PostCreateFlow> {
  MediaPickEditConfig get _flowConfig => widget.mediaConfig ?? MediaPickEditConfig.postDefault;

  MediaAspectPreset get _defaultCropPreset {
    final r = _flowConfig.resolvedCropPresets;
    return r.contains(MediaAspectPreset.ratio1x1) ? MediaAspectPreset.ratio1x1 : r.first;
  }

  final GlobalKey<PostCreateGalleryStepState> _galleryStepKey = GlobalKey<PostCreateGalleryStepState>();

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  _PostStep _step = _PostStep.gallery;

  List<PostCreateSlot> _slots = [];
  List<PostImageEditParams> _params = [];

  final PageController _editPageCtrl = PageController();
  int _editIndex = 0;

  final TransformationController _editZoomController = TransformationController();
  bool _editZoomedPastOne = false;

  Uint8List? _cropImageBytes;
  CropController _cropController = CropController();
  bool _cropEditorReady = false;
  bool _cropWorking = false;
  MediaAspectPreset _cropAspectPreset = MediaAspectPreset.ratio1x1;

  List<Uint8List?> _bakedForDetails = [];

  String _clusterId = _kClusterNone;

  final List<ProfileSearchHit> _taggedPeople = [];

  /// `null` — только лента инструментов, фото на весь экран; иначе снизу панель с одним слайдером.
  _EditAdjustTool? _activeAdjust;

  /// Параметры текущего кадра для превью/слайдеров без полного [setState] при каждом тике слайдера.
  late final ValueNotifier<PostImageEditParams> _liveEditParams;

  /// Параметры для полоски пресетов: обновляются без дебаунса при смене пресета/кадра и в [Slider.onChangeEnd],
  /// чтобы не пересобирать ~12 миниатюр на каждый тик слайдера теней/контраста и т.д.
  late final ValueNotifier<PostImageEditParams> _stripDisplayParams;

  @override
  void initState() {
    super.initState();
    _liveEditParams = ValueNotifier<PostImageEditParams>(const PostImageEditParams());
    _stripDisplayParams = ValueNotifier<PostImageEditParams>(const PostImageEditParams());
    _editZoomController.addListener(_onEditZoomChanged);
  }

  void _onEditZoomChanged() {
    final scale = _editZoomController.value.getMaxScaleOnAxis();
    final zoomed = scale > 1.02;
    if (zoomed != _editZoomedPastOne) {
      setState(() => _editZoomedPastOne = zoomed);
    }
  }

  void _resetEditZoom() {
    _editZoomController.value = Matrix4.identity();
    if (_editZoomedPastOne) {
      setState(() => _editZoomedPastOne = false);
    }
  }

  @override
  void dispose() {
    _editZoomController.removeListener(_onEditZoomChanged);
    _editZoomController.dispose();
    _liveEditParams.dispose();
    _stripDisplayParams.dispose();
    _editPageCtrl.dispose();
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _syncStripToLive() {
    _stripDisplayParams.value = _liveEditParams.value;
  }

  void _onGalleryContinue(List<PostCreateSlot> slots) {
    setState(() {
      _slots = slots;
      _params = List<PostImageEditParams>.generate(slots.length, (_) => const PostImageEditParams());
      _editIndex = 0;
      _activeAdjust = null;
      _taggedPeople.clear();
      if (slots.isEmpty) {
        _bakedForDetails = [];
        _step = _PostStep.details;
      } else {
        _step = _PostStep.edit;
      }
    });
    _liveEditParams.value = slots.isEmpty ? const PostImageEditParams() : _params[0];
    _syncStripToLive();
    if (slots.isNotEmpty) {
      _resetEditZoom();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_editPageCtrl.hasClients) {
          _editPageCtrl.jumpToPage(0);
        }
      });
    }
  }

  MediaPickEditOutcome _mediaOutcome() {
    return MediaPickEditOutcome(
      slots: List<PostCreateSlot>.from(_slots),
      editParams: List<PostImageEditParams>.from(_params),
      bakedImageBytes: List<Uint8List?>.from(_bakedForDetails),
    );
  }

  Future<void> _goToDetails() async {
    final baked = <Uint8List?>[];
    for (var i = 0; i < _slots.length; i++) {
      final s = _slots[i];
      if (s.isVideo) {
        baked.add(null);
      } else {
        try {
          final raw = await s.displayFile.readAsBytes();
          baked.add(bakePostImageEdit(raw, _params[i]));
        } catch (_) {
          baked.add(null);
        }
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _bakedForDetails = baked;
      _step = _PostStep.details;
      _activeAdjust = null;
      _clearCropSession();
    });
  }

  void _openDetailsMediaViewer(int initialIndex) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        barrierColor: AppColors.shadowDark.withValues(alpha: 0.45),
        pageBuilder: (_, __, ___) => _DetailsMediaViewerPage(
          initialIndex: initialIndex,
          slots: _slots,
          bakedForDetails: _bakedForDetails,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _onBack() {
    switch (_step) {
      case _PostStep.gallery:
        context.router.maybePop();
      case _PostStep.edit:
        if (_activeAdjust == _EditAdjustTool.crop) {
          setState(() {
            _activeAdjust = null;
            _clearCropSession();
          });
          return;
        }
        setState(() {
          _step = _PostStep.gallery;
          _slots = [];
          _params = [];
          _bakedForDetails = [];
          _activeAdjust = null;
          _clearCropSession();
        });
      case _PostStep.details:
        setState(() {
          _bakedForDetails = [];
          if (_slots.isEmpty) {
            _step = _PostStep.gallery;
          } else {
            _step = _PostStep.edit;
          }
        });
        if (_slots.isNotEmpty) {
          _liveEditParams.value = _params[_editIndex.clamp(0, _params.length - 1)];
          _syncStripToLive();
        }
    }
  }

  String _appBarTitle() {
    switch (_step) {
      case _PostStep.gallery:
        return 'Новый пост';
      case _PostStep.edit:
        return _activeAdjust == _EditAdjustTool.crop ? 'Кадр' : 'Изменить';
      case _PostStep.details:
        return 'Новый пост';
    }
  }

  void _reorderEditSlots(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final anchorPath = _slots[_editIndex].displayFile.path;
    setState(() {
      final s = _slots.removeAt(oldIndex);
      _slots.insert(newIndex, s);
      final p = _params.removeAt(oldIndex);
      _params.insert(newIndex, p);
      final ni = _slots.indexWhere((x) => x.displayFile.path == anchorPath);
      _editIndex = ni < 0 ? 0 : ni;
      _activeAdjust = null;
      _clearCropSession();
    });
    _liveEditParams.value = _params[_editIndex];
    _syncStripToLive();
    _resetEditZoom();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_editPageCtrl.hasClients) {
        _editPageCtrl.jumpToPage(_editIndex);
      }
    });
  }

  Future<void> _openEditReorderSheet() async {
    await showPostReorderBottomSheet(
      context: context,
      variant: PostReorderSheetVariant.editor,
      itemCount: _slots.length,
      onReorder: _reorderEditSlots,
      itemBuilder: (context, index) {
        final slot = _slots[index];
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final thumbPx = (64 * dpr).round().clamp(96, 256);

        final Widget thumb = slot.isVideo
            ? ColoredBox(
                color: AppColors.inputBackground,
                child: Icon(
                  Icons.play_circle_fill,
                  color: AppColors.postEditorOnSurfaceMuted.withValues(alpha: 0.85),
                  size: 32,
                ),
              )
            : Image.file(
                slot.displayFile,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                filterQuality: FilterQuality.low,
                cacheWidth: thumbPx,
                cacheHeight: thumbPx,
                errorBuilder: (_, __, ___) => ColoredBox(color: AppColors.inputBackground),
              );

        return postReorderListRow(
          key: ValueKey<String>('edit-reorder-${slot.displayFile.path}'),
          variant: PostReorderSheetVariant.editor,
          index: index,
          itemCount: _slots.length,
          card: PostReorderCard.editor(
            index: index,
            mediaLabel: slot.isVideo ? 'Видео' : 'Фото',
            thumbnail: thumb,
            dragHandle: ReorderableDragStartListener(
              index: index,
              child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.drag_handle_rounded)),
            ),
          ),
        );
      },
    );
  }

  Future<List<PostCreateMediaItem>> _buildMediaForDraft() async {
    if (_slots.length != _bakedForDetails.length) {
      throw StateError('Медиа не готово');
    }
    final out = <PostCreateMediaItem>[];
    for (var i = 0; i < _slots.length; i++) {
      final s = _slots[i];
      final aspect = s.aspect.trim().isEmpty ? null : s.aspect.trim();
      if (s.isVideo) {
        final bytes = await s.displayFile.readAsBytes();
        final path = s.displayFile.path;
        final ext = path.contains('.') ? path.split('.').last.toLowerCase() : 'mp4';
        final mime = switch (ext) {
          'mov' => 'video/quicktime',
          'webm' => 'video/webm',
          _ => 'video/mp4',
        };
        out.add(PostCreateMediaItem.video(bytes: bytes, mime: mime, ext: ext, aspect: aspect));
      } else {
        final baked = _bakedForDetails[i];
        if (baked == null) {
          throw StateError('Изображение не обработано');
        }
        out.add(PostCreateMediaItem.image(bytes: baked, aspect: aspect));
      }
    }
    return out;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final cubit = context.read<PostCreateCubit>();
    try {
      final media = await _buildMediaForDraft();
      final draft = PostCreateDraft(
        title: _nullableTrimField(_titleCtrl.text),
        subtitle: _nullableTrimField(_subtitleCtrl.text),
        description: _nullableTrimField(_descriptionCtrl.text),
        clusterId: _clusterId == _kClusterNone ? null : _clusterId,
        media: media,
      );
      final res = await cubit.submit(draft);
      if (!mounted) {
        return;
      }
      if (res != null) {
        AppSnackBar.show(context, message: 'Успешно создалось', kind: AppSnackBarKind.success);
        context.router.maybePop();
      } else {
        final err = cubit.state.maybeWhen(ready: (_, __, ___, msg) => msg, orElse: () => null);
        AppSnackBar.show(
          context,
          message: err ?? 'Не удалось создать пост',
          kind: AppSnackBarKind.error,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: '$e', kind: AppSnackBarKind.error);
      }
    }
  }

  Future<void> _openTagProfileSheet() async {
    if (!mounted) {
      return;
    }
    final self = Supabase.instance.client.auth.currentUser?.id;
    final excluded = <String>{if (self != null) self, ..._taggedPeople.map((e) => e.id)};
    final hit = await ProfilePeopleSearchSheet.show(context, excludeProfileIds: excluded);
    if (hit != null && mounted) {
      setState(() {
        if (!_taggedPeople.any((e) => e.id == hit.id)) {
          _taggedPeople.add(hit);
        }
      });
    }
  }

  void _updateParam(PostImageEditParams Function(PostImageEditParams p) fn, {bool syncStrip = false}) {
    final i = _editIndex;
    final next = fn(_liveEditParams.value);
    _params[i] = next;
    _liveEditParams.value = next;
    if (syncStrip) {
      _stripDisplayParams.value = next;
    }
  }

  void _clearCropSession() {
    _cropImageBytes = null;
    _cropEditorReady = false;
    _cropWorking = false;
    _cropAspectPreset = _defaultCropPreset;
    _cropController = CropController();
  }

  Future<void> _prepareCropSession() async {
    final i = _editIndex;
    if (i >= _slots.length || _slots[i].isVideo) {
      if (mounted) {
        setState(() {
          _activeAdjust = null;
          _clearCropSession();
        });
      }
      return;
    }
    try {
      // Всегда исходник: при повторной обрезке не тянуть уже обрезанный displayFile.
      final raw = await _slots[i].originalFile.readAsBytes();
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
        }
        return;
      }
      setState(() {
        _cropImageBytes = normalized;
        _cropController = CropController();
        _cropEditorReady = false;
        _cropWorking = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _activeAdjust = null;
          _clearCropSession();
        });
      }
    }
  }

  void _setCropAspectPreset(MediaAspectPreset mode) {
    if (_cropAspectPreset == mode) {
      return;
    }
    setState(() {
      _cropAspectPreset = mode;
      // Apply only to current slot (each media can have its own aspect).
      final i = _editIndex;
      if (i >= 0 && i < _slots.length) {
        _slots[i] = _slots[i].copyWithAspect(mode.fileAspect);
      }
      _cropController = CropController();
      _cropEditorReady = false;
    });
  }

  Future<void> _onCropResult(CropResult result) async {
    if (!mounted) {
      return;
    }
    setState(() => _cropWorking = false);
    switch (result) {
      case CropSuccess(:final croppedImage):
        final i = _editIndex;
        try {
          final dir = await getTemporaryDirectory();
          final f = File('${dir.path}/post_crop_${DateTime.now().microsecondsSinceEpoch}.jpg');
          await f.writeAsBytes(croppedImage, flush: true);
          if (!mounted) {
            return;
          }
          setState(() {
            _slots[i] = _slots[i].copyWithDisplay(f);
            _params[i] = const PostImageEditParams();
            _liveEditParams.value = _params[i];
            _stripDisplayParams.value = _params[i];
            _activeAdjust = null;
            _clearCropSession();
          });
          _resetEditZoom();
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

  void _applyCrop() {
    if (!_cropEditorReady || _cropWorking) {
      return;
    }
    setState(() => _cropWorking = true);
    _cropController.crop();
  }

  /// Кнопка «Готово» в AppBar: исходник загружен, редактор готов, не идёт обрезка.
  bool get _canApplyCrop => _cropImageBytes != null && _cropEditorReady && !_cropWorking;

  Color _postCreateScaffoldBackground() {
    return switch (_step) {
      _PostStep.edit => AppColors.postEditorBackground,
      _PostStep.details => AppColors.surfaceSoft,
      _PostStep.gallery => AppColors.surfaceSoft,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostCreateCubit, PostCreateState>(
      listenWhen: (prev, next) {
        final po = prev.maybeWhen(ready: (_, o, __, ___) => o, orElse: () => null);
        final no = next.maybeWhen(ready: (_, o, __, ___) => o, orElse: () => null);
        return po != no;
      },
      listener: (context, state) {
        state.maybeWhen(
          ready: (_, options, __, ___) {
            if (_clusterId != _kClusterNone && !options.any((o) => o.value == _clusterId)) {
              setState(() => _clusterId = _kClusterNone);
            }
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        backgroundColor: _postCreateScaffoldBackground(),
        appBar: _buildPostCreateAppBar(),
        body: switch (_step) {
          _PostStep.gallery => PostCreateGalleryStep(
            key: _galleryStepKey,
            maxSelection: _flowConfig.maxSelection,
            allowVideo: _flowConfig.allowVideo,
            onContinue: _onGalleryContinue,
            onSelectionCountChanged: (_) => setState(() {}),
          ),
          _PostStep.edit => _buildEditBody(),
          _PostStep.details =>
            widget.customThirdStep != null
                ? widget.customThirdStep!(context, _mediaOutcome())
                : _buildDetailsBody(),
        },
      ),
    );
  }

  PreferredSizeWidget _buildPostCreateAppBar() {
    final isIgEdit = _step == _PostStep.edit;
    final isDetails = _step == _PostStep.details;
    final isGallery = _step == _PostStep.gallery;
    final actions = <Widget>[];
    if (_step == _PostStep.gallery) {
      final galleryHasSelection = _galleryStepKey.currentState?.hasSelection ?? false;
      if (galleryHasSelection) {
        actions.add(
          TextButton(
            onPressed: () => _galleryStepKey.currentState?.continueWithSelection(),
            child: Text(
              'Далее',
              style: AppTextStyle.base(16, color: AppColors.postEditorCta, fontWeight: FontWeight.w700),
            ),
          ),
        );
      }
    }
    if (_step == _PostStep.edit && _slots.isNotEmpty) {
      if (_activeAdjust == _EditAdjustTool.crop) {
        actions.add(
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton(
              onPressed: _canApplyCrop ? _applyCrop : null,
              child: _cropWorking
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.postEditorCta),
                    )
                  : Text(
                      'Готово',
                      style: AppTextStyle.base(
                        16,
                        color: AppColors.postEditorCta,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        );
      } else {
        actions.add(
          TextButton(
            onPressed: _goToDetails,
            child: Text(
              'Далее',
              style: AppTextStyle.base(16, color: AppColors.postEditorCta, fontWeight: FontWeight.w700),
            ),
          ),
        );
        if (_slots.length > 1) {
          actions.add(
            TextButton(
              onPressed: _openEditReorderSheet,
              child: Text(
                'Порядок',
                style: AppTextStyle.base(
                  16,
                  color: AppColors.postEditorOnSurfaceMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }
      }
    }
    if (_step == _PostStep.details && widget.customThirdStep == null) {
      actions.add(
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: BlocBuilder<PostCreateCubit, PostCreateState>(
            buildWhen: (p, n) =>
                p.maybeWhen(ready: (_, __, s, ___) => s, orElse: () => false) !=
                n.maybeWhen(ready: (_, __, s, ___) => s, orElse: () => false),
            builder: (context, state) {
              final submitting = state.maybeWhen(ready: (_, __, s, ___) => s, orElse: () => false);
              return TextButton(
                onPressed: submitting ? null : () => _submit(),
                child: submitting
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.primary.withValues(alpha: 0.85),
                        ),
                      )
                    : Text(
                        'Поделиться',
                        style: AppTextStyle.base(16, color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
              );
            },
          ),
        ),
      );
    }
    return AppAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: isIgEdit
          ? AppColors.postEditorBackground
          : (isDetails || isGallery)
          ? AppColors.surfaceSoft
          : null,
      foregroundColor: isIgEdit
          ? AppColors.postEditorOnSurface
          : (isDetails || isGallery)
          ? AppColors.textColor
          : null,
      leading: IconButton(
        icon: Icon(
          AppIcons.back.icon,
          color: isIgEdit
              ? AppColors.postEditorOnSurface
              : (isDetails || isGallery)
              ? AppColors.textColor
              : null,
        ),
        onPressed: _onBack,
      ),
      title: Text(
        _appBarTitle(),
        style: AppTextStyle.base(
          17,
          color: isIgEdit ? AppColors.postEditorOnSurface : AppColors.textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: actions.isEmpty ? null : actions,
    );
  }

  Widget _buildEditBody() {
    if (_slots.isEmpty) {
      return const SizedBox.shrink();
    }
    final slot = _slots[_editIndex];
    final bottomInset = MediaQuery.paddingOf(context).bottom;

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
                if (slot.isVideo)
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 18, 24, 20 + bottomInset * 0.5),
                    child: Text(
                      'Для видео коррекция недоступна — файл уйдёт в пост как есть.',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.base(14, color: AppColors.postEditorOnSurfaceMuted, height: 1.4),
                    ),
                  )
                else ...[
                  AppIgAdjustPanel<_EditAdjustTool>(
                    imageLabel: 'Фильтр',
                    stripParams: _stripDisplayParams,
                    showFilters: _activeAdjust != _EditAdjustTool.crop,
                    showTools: true,
                    onFilterTap: (f) => _updateParam((x) => x.copyWith(styleFilter: f), syncStrip: true),
                    filterThumbnailBuilder: (filter, baseParams) => PostStyleFilterThumbnail(
                      file: slot.displayFile,
                      baseParams: baseParams,
                      chipStyle: filter,
                    ),
                    tools: _EditAdjustTool.values,
                    activeTool: _activeAdjust,
                    onToolTap: _onAdjustToolTapped,
                    toolLabel: _adjustToolLabel,
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
                if (slot.isVideo) SizedBox(height: 8 + bottomInset * 0.35),
              ],
            ),
          ),
        ),
      ],
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
            SizedBox(
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
                    itemCount: _flowConfig.resolvedCropPresets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final m = _flowConfig.resolvedCropPresets[i];
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

  String _adjustToolLabel(_EditAdjustTool t) => switch (t) {
    _EditAdjustTool.exposure => 'Экспозиция',
    _EditAdjustTool.brightness => 'Яркость',
    _EditAdjustTool.shadows => 'Тени',
    _EditAdjustTool.highlights => 'Света',
    _EditAdjustTool.saturation => 'Насыщенность',
    _EditAdjustTool.warmth => 'Тепло',
    _EditAdjustTool.contrast => 'Контраст',
    _EditAdjustTool.sharpness => 'Резкость',
    _EditAdjustTool.crop => 'Кадр',
  };

  void _onAdjustToolTapped(_EditAdjustTool t) {
    if (t == _EditAdjustTool.crop) {
      if (_activeAdjust == _EditAdjustTool.crop) {
        setState(() {
          _activeAdjust = null;
          _clearCropSession();
        });
        return;
      }
      setState(() {
        _activeAdjust = _EditAdjustTool.crop;
        final i = _editIndex;
        final slotAspect = (i >= 0 && i < _slots.length) ? _slots[i].aspect : '1x1';
        _cropAspectPreset = _flowConfig.resolvedCropPresets.firstWhere(
          (m) => m.fileAspect == slotAspect,
          orElse: () => _defaultCropPreset,
        );
        _cropController = CropController();
        _cropEditorReady = false;
        _cropWorking = false;
        _cropImageBytes = null;
      });
      unawaited(_prepareCropSession());
      _resetEditZoom();
      return;
    }
    setState(() {
      if (_activeAdjust == _EditAdjustTool.crop) {
        _clearCropSession();
      }
      if (_activeAdjust == t) {
        _activeAdjust = null;
      } else {
        _activeAdjust = t;
      }
    });
  }

  Widget _buildAdjustSliderPanel() {
    final t = _activeAdjust;
    if (t == null) {
      return const SizedBox.shrink();
    }
    if (t == _EditAdjustTool.crop) {
      return _buildCropPresetPanel();
    }

    return ValueListenableBuilder<PostImageEditParams>(
      valueListenable: _liveEditParams,
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _adjustToolLabel(t),
                textAlign: TextAlign.center,
                style: AppTextStyle.base(
                  15,
                  color: AppColors.postEditorOnSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              switch (t) {
                _EditAdjustTool.exposure => _igSliderSymmetric(
                  p.exposure,
                  (v) => _updateParam((x) => x.copyWith(exposure: v)),
                ),
                _EditAdjustTool.brightness => _igSliderSymmetric(
                  p.brightness,
                  (v) => _updateParam((x) => x.copyWith(brightness: v)),
                ),
                _EditAdjustTool.shadows => _igSliderSymmetric(
                  p.shadows,
                  (v) => _updateParam((x) => x.copyWith(shadows: v)),
                ),
                _EditAdjustTool.highlights => _igSliderSymmetric(
                  p.highlights,
                  (v) => _updateParam((x) => x.copyWith(highlights: v)),
                ),
                _EditAdjustTool.saturation => _igSliderSymmetric(
                  p.saturation,
                  (v) => _updateParam((x) => x.copyWith(saturation: v)),
                ),
                _EditAdjustTool.warmth => _igSliderSymmetric(
                  p.warmth,
                  (v) => _updateParam((x) => x.copyWith(warmth: v)),
                ),
                _EditAdjustTool.contrast => _igSliderSymmetric(
                  p.contrast,
                  (v) => _updateParam((x) => x.copyWith(contrast: v)),
                ),
                _EditAdjustTool.sharpness => _igSliderSharpness(
                  p.sharpness.clamp(0.0, 1.0),
                  (v) => _updateParam((x) => x.copyWith(sharpness: v)),
                ),
                _EditAdjustTool.crop => const SizedBox.shrink(),
              },
            ],
          ),
        );
      },
    );
  }

  Widget _igSliderSymmetric(double value, ValueChanged<double> onChanged) {
    return AppIgSlider.symmetric(context, value: value, onChanged: onChanged, onChangeEnd: _syncStripToLive);
  }

  Widget _igSliderSharpness(double value, ValueChanged<double> onChanged) {
    return AppIgSlider.sharpness(context, value: value, onChanged: onChanged, onChangeEnd: _syncStripToLive);
  }

  /// Pinch-to-zoom на шаге «Изменить»; двойной тап — сброс масштаба. Пока увеличено, листать кадры нельзя.
  /// [InteractiveViewer] снаружи [ValueListenableBuilder], чтобы слайдеры не сбрасывали зум.
  Widget _buildEditZoomablePhoto(File file) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onDoubleTap: _resetEditZoom,
          behavior: HitTestBehavior.deferToChild,
          child: InteractiveViewer(
            transformationController: _editZoomController,
            minScale: 1.0,
            maxScale: 4.0,
            clipBehavior: Clip.hardEdge,
            boundaryMargin: const EdgeInsets.all(120),
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: ValueListenableBuilder<PostImageEditParams>(
                valueListenable: _liveEditParams,
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
    final lockSwipe = _editZoomedPastOne || _activeAdjust == _EditAdjustTool.crop;
    return ColoredBox(
      color: AppColors.postEditorBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _editPageCtrl,
            physics: lockSwipe ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
            itemCount: _slots.length,
            onPageChanged: (i) {
              _editZoomController.value = Matrix4.identity();
              setState(() {
                _editIndex = i;
                _activeAdjust = null;
                _editZoomedPastOne = false;
                _clearCropSession();
              });
              _liveEditParams.value = _params[i];
              _syncStripToLive();
            },
            itemBuilder: (context, i) {
              final s = _slots[i];
              if (s.isVideo) {
                return RepaintBoundary(
                  child: Center(child: PostCreateVideoPreview(file: s.displayFile)),
                );
              }
              if (i == _editIndex) {
                if (_activeAdjust == _EditAdjustTool.crop) {
                  if (_cropImageBytes == null) {
                    return const ColoredBox(
                      color: AppColors.postEditorBackground,
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    );
                  }
                  final bytes = _cropImageBytes!;
                  final aspect = _cropAspectPreset.aspectRatio;
                  return RepaintBoundary(
                    child: SizedBox.expand(
                      child: Crop(
                        key: ValueKey(_cropAspectPreset),
                        image: bytes,
                        controller: _cropController,
                        onCropped: _onCropResult,
                        aspectRatio: aspect,
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
                          } else if (status == CropStatus.loading) {
                            setState(() => _cropEditorReady = false);
                          }
                        },
                      ),
                    ),
                  );
                }
                return RepaintBoundary(child: _buildEditZoomablePhoto(s.displayFile));
              }
              final par = _params[i];
              Widget media;
              if (par.isNeutral) {
                media = Image.file(
                  s.displayFile,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.low,
                  isAntiAlias: true,
                );
              } else {
                media = PostEditGpuPreview(file: s.displayFile, params: par, fit: BoxFit.contain);
              }
              return RepaintBoundary(child: Center(child: media));
            },
          ),
          if (_slots.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slots.length, (j) {
                  final active = j == _editIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      width: active ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  /// Превью кадра на шаге «Новый пост»: квадрат, как в Instagram.
  Widget _detailsIgMediaThumb(int i, {required double size, double radius = 4}) {
    final s = _slots[i];
    final baked = _bakedForDetails[i];
    return GestureDetector(
      onTap: () => _openDetailsMediaViewer(i),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: size,
          height: size,
          child: s.isVideo
              ? ColoredBox(
                  color: AppColors.inputBackground,
                  child: Icon(
                    Icons.play_circle_fill,
                    color: AppColors.iconMuted.withValues(alpha: 0.9),
                    size: (size * 0.42).clamp(28.0, 44.0),
                  ),
                )
              : baked != null
              ? Image.memory(
                  baked,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                )
              : ColoredBox(
                  color: AppColors.surfaceMuted,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.iconMuted,
                      size: (size * 0.28).clamp(22.0, 36.0),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  String _detailsClusterSubtitle(List<AppSingleSelectOption<String>> clusterOptions) {
    for (final o in clusterOptions) {
      if (o.value == _clusterId) {
        return o.label;
      }
    }
    return 'Не привязывать';
  }

  /// Минималистичная группа настроек (коллекция + люди) в одной карточке.
  Widget _buildDetailsSettingsGroup() {
    final clusterOptions = context.select<PostCreateCubit, List<AppSingleSelectOption<String>>>(
      (c) => c.state.maybeWhen(
        ready: (_, opts, __, ___) => opts,
        orElse: () => const [AppSingleSelectOption<String>(value: _kClusterNone, label: 'Не привязывать')],
      ),
    );
    final n = _taggedPeople.length;
    final peopleSubtitle = n == 0 ? 'Добавить людей' : 'Отмечено: $n';

    Future<void> openCluster() async {
      final picked = await AppSingleSelect.showSheet<String>(
        context: context,
        title: 'Коллекция',
        options: clusterOptions,
        selected: _clusterId,
      );
      if (picked != null && mounted) {
        setState(() => _clusterId = picked);
      }
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: openCluster,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Icon(Icons.folder_outlined, size: 22, color: AppColors.primary.withValues(alpha: 0.9)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Коллекция',
                              style: AppTextStyle.base(
                                16,
                                color: AppColors.textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _detailsClusterSubtitle(clusterOptions),
                              style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.iconMuted.withValues(alpha: 0.85),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              indent: 52,
              endIndent: 16,
              color: AppColors.border.withValues(alpha: 0.45),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openTagProfileSheet,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.alternate_email_rounded,
                          size: 22,
                          color: AppColors.primary.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Отметить людей',
                              style: AppTextStyle.base(
                                16,
                                color: AppColors.textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              peopleSubtitle,
                              style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.3),
                            ),
                            if (n > 0) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final hit in _taggedPeople)
                                    InputChip(
                                      label: Text(
                                        hit.displayLabel,
                                        style: AppTextStyle.base(13, color: AppColors.textColor),
                                      ),
                                      onDeleted: () =>
                                          setState(() => _taggedPeople.removeWhere((e) => e.id == hit.id)),
                                      deleteIconColor: AppColors.subTextColor,
                                      backgroundColor: AppColors.surfaceMuted,
                                      side: BorderSide(color: AppColors.border.withValues(alpha: 0.65)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.iconMuted.withValues(alpha: 0.85),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsBody() {
    if (_slots.isNotEmpty && _bakedForDetails.length != _slots.length) {
      return const SizedBox.shrink();
    }

    const pad = 20.0;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final safe = MediaQuery.paddingOf(context);

    final fieldsNoMedia = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          hintText: 'Заголовок (необязательно)',
          controller: _titleCtrl,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 14),
        AppTextField(
          hintText: 'Подзаголовок (необязательно)',
          controller: _subtitleCtrl,
          maxLines: 4,
          minLines: 1,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 14),
        AppTextField(
          hintText: 'Описание (необязательно)',
          controller: _descriptionCtrl,
          maxLines: 8,
          minLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );

    if (_slots.isEmpty) {
      return Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(safe.left + pad, 24, safe.right + pad, 28 + bottom),
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              'Медиа не выбрано — заполните текст и параметры ниже.',
              textAlign: TextAlign.center,
              style: AppTextStyle.base(15, color: AppColors.subTextColor, height: 1.45),
            ),
            const SizedBox(height: 28),
            fieldsNoMedia,
            const SizedBox(height: 28),
            _buildDetailsSettingsGroup(),
          ],
        ),
      );
    }

    final multi = _slots.length > 1;
    final heroSize = multi ? 86.0 : 92.0;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (multi)
            Padding(
              padding: EdgeInsets.fromLTRB(safe.left + pad, 16, safe.right + pad, 0),
              child: SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _slots.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => _detailsIgMediaThumb(i, size: 58, radius: 10),
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(safe.left + pad, multi ? 18 : 22, safe.right + pad, 28 + bottom),
              physics: const BouncingScrollPhysics(),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowDark.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _detailsIgMediaThumb(0, size: heroSize, radius: 12),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AppTextField(
                        hintText: 'Заголовок (необязательно)',
                        controller: _titleCtrl,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AppTextField(
                  hintText: 'Подзаголовок (необязательно)',
                  controller: _subtitleCtrl,
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  hintText: 'Описание (необязательно)',
                  controller: _descriptionCtrl,
                  maxLines: 8,
                  minLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 28),
                _buildDetailsSettingsGroup(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsMediaViewerPage extends StatefulWidget {
  const _DetailsMediaViewerPage({
    required this.initialIndex,
    required this.slots,
    required this.bakedForDetails,
  });

  final int initialIndex;
  final List<PostCreateSlot> slots;
  final List<Uint8List?> bakedForDetails;

  @override
  State<_DetailsMediaViewerPage> createState() => _DetailsMediaViewerPageState();
}

class _DetailsMediaViewerPageState extends State<_DetailsMediaViewerPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.postEditorBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.slots.length,
            itemBuilder: (context, i) {
              final s = widget.slots[i];
              final baked = widget.bakedForDetails[i];
              if (s.isVideo) {
                return Center(child: PostCreateVideoPreview(file: s.displayFile));
              }
              if (baked != null) {
                return InteractiveViewer(
                  minScale: 0.85,
                  maxScale: 4,
                  child: Center(
                    child: Image.memory(
                      baked,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                );
              }
              return Center(
                child: Icon(Icons.broken_image_outlined, color: AppColors.postEditorOnSurfaceDim, size: 56),
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.close, color: AppColors.postEditorOnSurface),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
