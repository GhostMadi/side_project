import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:side_project/core/dependencies/get_it.dart' show sl;
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/shared/app_text_button.dart';
import 'package:side_project/core/shared/app_text_field.dart';
import 'package:side_project/core/shared/ig_edit/ig_edit_bake.dart';
import 'package:side_project/feature/cluster/presentation/cluster_list_refresh.dart';
import 'package:side_project/feature/cluster_create_page/presentation/cubit/cluster_create_cubit.dart';
import 'package:side_project/feature/media_pick_edit/media_pick_edit.dart';
import 'package:side_project/feature/post_create_page/presentation/page/post_create_gallery_step.dart';
import 'package:side_project/feature/post_create_page/presentation/page/post_create_models.dart';
import 'package:side_project/feature/post_create_page/presentation/widget/post_create_image_edit_body.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:side_project/feature/profile_page/presentation/models/profile_feed_preview.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_collection_card.dart';

/// Рекомендуемые параметры обложки кластера (1 фото, 1:1, без видео) — тот же смысл, что [MediaPickEditConfig] для поста.
const MediaPickEditConfig kClusterCreateMediaConfig = MediaPickEditConfig(
  maxSelection: 1,
  allowVideo: false,
  cropPresets: [MediaAspectPreset.ratio1x1],
);

/// Превью на шаге «детали», пока название не введено.
const String _kClusterDetailsPreviewPlaceholderTitle = 'Новая коллекция';

class _BakeCoverInput {
  const _BakeCoverInput(this.bytes, this.params);
  final Uint8List bytes;
  final PostImageEditParams params;
}

Uint8List _bakeCoverInIsolate(_BakeCoverInput input) {
  return bakePostImageEdit(input.bytes, input.params);
}

/// Экран создания кластера: шаг 1 — как у поста ([PostCreateGalleryStep]) → шаг 2 — как у поста ([PostCreateImageEditBody]) → форма.
@RoutePage()
class ClusterCreatePage extends StatefulWidget {
  const ClusterCreatePage({super.key});

  @override
  State<ClusterCreatePage> createState() => _ClusterCreatePageState();
}

enum _ClusterCreateStep { pick, edit, details }

class _ClusterCreatePageState extends State<ClusterCreatePage> {
  final GlobalKey<PostCreateGalleryStepState> _galleryStepKey = GlobalKey<PostCreateGalleryStepState>();
  final GlobalKey<PostCreateImageEditBodyState> _imageEditKey = GlobalKey<PostCreateImageEditBodyState>();
  int _galleryEpoch = 0;

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();

  _ClusterCreateStep _step = _ClusterCreateStep.pick;
  Uint8List? _rawCoverBytes;
  Uint8List? _editedCoverBytes;
  Uint8List? _bakedCoverBytes;
  late final ValueNotifier<PostImageEditParams> _editParams;
  late final ValueNotifier<PostImageEditParams> _stripDisplayParams;
  final ValueNotifier<PostImageEditAppBarFlags> _imageEditAppBarFlags = ValueNotifier(
    const PostImageEditAppBarFlags(),
  );

  File? _coverOriginalFile;
  File? _coverDisplayFile;
  String _coverAspectLabel = '1x1';

  late final VoidCallback _fieldsListener;

  @override
  void initState() {
    super.initState();
    _editParams = ValueNotifier<PostImageEditParams>(const PostImageEditParams());
    _stripDisplayParams = ValueNotifier<PostImageEditParams>(_editParams.value);
    void onFieldsChanged() {
      setState(() {});
    }

    _fieldsListener = onFieldsChanged;
    _titleCtrl.addListener(_fieldsListener);
    _subtitleCtrl.addListener(_fieldsListener);
  }

  @override
  void dispose() {
    _titleCtrl.removeListener(_fieldsListener);
    _subtitleCtrl.removeListener(_fieldsListener);
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _editParams.dispose();
    _stripDisplayParams.dispose();
    _imageEditAppBarFlags.dispose();
    super.dispose();
  }

  Future<void> _ensureCoverFilesForEdit() async {
    final bytes = _editedCoverBytes ?? _rawCoverBytes;
    if (bytes == null || bytes.isEmpty) return;
    if (_coverOriginalFile != null && _coverDisplayFile != null) return;
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/cluster_cover_restore_${DateTime.now().microsecondsSinceEpoch}.jpg');
    await f.writeAsBytes(bytes, flush: true);
    _coverOriginalFile = f;
    _coverDisplayFile = f;
  }

  Future<void> _onGalleryContinue(List<PostCreateSlot> slots) async {
    if (slots.isEmpty) {
      return;
    }
    final s = slots.first;
    if (s.isVideo) return;
    try {
      final bytes = await s.originalFile.readAsBytes();
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/cluster_cover_${DateTime.now().microsecondsSinceEpoch}.jpg');
      await f.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      setState(() {
        _rawCoverBytes = Uint8List.fromList(bytes);
        _editedCoverBytes = null;
        _bakedCoverBytes = null;
        _coverOriginalFile = f;
        _coverDisplayFile = f;
        _coverAspectLabel = '1x1';
        _editParams.value = const PostImageEditParams();
        _stripDisplayParams.value = const PostImageEditParams();
        _step = _ClusterCreateStep.edit;
      });
    } catch (_) {}
  }

  Future<void> _onCoverDisplayReplaced(File newDisplay) async {
    final b = await newDisplay.readAsBytes();
    if (!mounted) return;
    setState(() {
      _coverDisplayFile = newDisplay;
      _rawCoverBytes = Uint8List.fromList(b);
      _editedCoverBytes = null;
      _bakedCoverBytes = null;
    });
  }

  String get _previewTitle {
    final t = _titleCtrl.text.trim();
    return t.isEmpty ? _kClusterDetailsPreviewPlaceholderTitle : t;
  }

  String? get _previewSubtitle {
    final s = _subtitleCtrl.text.trim();
    return s.isEmpty ? null : s;
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final bytes = _bakedCoverBytes ?? _editedCoverBytes ?? _rawCoverBytes;
    context.read<ClusterCreateCubit>().submit(
      title: _titleCtrl.text,
      subtitle: _subtitleCtrl.text,
      coverBytes: bytes,
    );
  }

  void _goBack() {
    if (_step == _ClusterCreateStep.pick) {
      context.router.maybePop();
      return;
    }
    if (_step == _ClusterCreateStep.edit) {
      if (_imageEditKey.currentState?.exitCropIfActive() ?? false) {
        return;
      }
    }
    setState(() {
      _step = switch (_step) {
        _ClusterCreateStep.edit => _ClusterCreateStep.pick,
        _ClusterCreateStep.details => _ClusterCreateStep.edit,
        _ClusterCreateStep.pick => _ClusterCreateStep.pick,
      };
      if (_step == _ClusterCreateStep.pick) {
        _galleryEpoch++;
        _rawCoverBytes = null;
        _editedCoverBytes = null;
        _bakedCoverBytes = null;
        _coverOriginalFile = null;
        _coverDisplayFile = null;
      }
    });
  }

  Color _clusterScaffoldBackground() {
    return switch (_step) {
      _ClusterCreateStep.edit => AppColors.postEditorBackground,
      _ClusterCreateStep.details => AppColors.surfaceSoft,
      _ClusterCreateStep.pick => AppColors.surfaceSoft,
    };
  }

  String _clusterAppBarTitle(PostImageEditAppBarFlags? editBar) {
    if (_step == _ClusterCreateStep.edit && (editBar?.cropSurface ?? false)) {
      return 'Кадр';
    }
    return switch (_step) {
      _ClusterCreateStep.pick => 'Новая коллекция',
      _ClusterCreateStep.edit => 'Изменить',
      _ClusterCreateStep.details => 'Новая коллекция',
    };
  }

  Future<void> _continueFromEditStep() async {
    final src = _editedCoverBytes ?? _rawCoverBytes;
    if (src == null || src.isEmpty) return;
    final p = _editParams.value;
    final baked = p.isNeutral ? src : await compute(_bakeCoverInIsolate, _BakeCoverInput(src, p));
    if (!mounted) return;
    setState(() {
      _bakedCoverBytes = baked;
      _step = _ClusterCreateStep.details;
    });
  }

  PreferredSizeWidget _buildClusterAppBar(
    BuildContext context,
    bool submitting, {
    PostImageEditAppBarFlags? editBar,
  }) {
    final isEdit = _step == _ClusterCreateStep.edit;
    final isDetails = _step == _ClusterCreateStep.details;
    final isPick = _step == _ClusterCreateStep.pick;
    final hasRaw = _rawCoverBytes != null && _rawCoverBytes!.isNotEmpty;
    final galleryHasSelection = isPick ? (_galleryStepKey.currentState?.hasSelection ?? false) : false;

    final actions = <Widget>[];
    if (isPick && galleryHasSelection && !submitting) {
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
    if (isEdit && hasRaw && !submitting) {
      final bar = editBar;
      final cropSurface = bar?.cropSurface ?? false;
      if (cropSurface) {
        final canApply = bar?.cropReady ?? false;
        final working = bar?.cropWorking ?? false;
        actions.add(
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton(
              onPressed: working || !canApply ? null : () => _imageEditKey.currentState?.applyCrop(),
              child: working
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
            onPressed: () => unawaited(_continueFromEditStep()),
            child: Text(
              'Далее',
              style: AppTextStyle.base(16, color: AppColors.postEditorCta, fontWeight: FontWeight.w700),
            ),
          ),
        );
      }
    }
    if (isDetails) {
      if (submitting) {
        actions.add(
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.primary),
            ),
          ),
        );
      } else {
        actions.add(
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton(
              onPressed: () => _submit(context),
              child: Text(
                'Создать',
                style: AppTextStyle.base(16, color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        );
      }
    }

    return AppAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: isEdit
          ? AppColors.postEditorBackground
          : (isDetails || isPick)
          ? AppColors.surfaceSoft
          : null,
      foregroundColor: isEdit ? AppColors.postEditorOnSurface : AppColors.textColor,
      leading: IconButton(
        icon: Icon(AppIcons.back.icon, color: isEdit ? AppColors.postEditorOnSurface : AppColors.textColor),
        onPressed: submitting ? null : _goBack,
      ),
      title: Text(
        _clusterAppBarTitle(editBar),
        style: AppTextStyle.base(
          17,
          color: isEdit ? AppColors.postEditorOnSurface : AppColors.textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: actions.isEmpty ? null : actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClusterCreateCubit>(),
      child: BlocConsumer<ClusterCreateCubit, ClusterCreateState>(
        listener: (context, state) {
          state.whenOrNull(
            success: (_) {
              clusterListRefreshTick.value++;
              unawaited(sl<ProfileCubit>().refreshMyProfile());
              AppSnackBar.show(context, message: 'Кластер создан', kind: AppSnackBarKind.success);
              context.router.maybePop();
            },
            error: (message) {
              AppSnackBar.show(context, message: message, kind: AppSnackBarKind.error);
              context.read<ClusterCreateCubit>().acknowledgeError();
            },
          );
        },
        builder: (context, state) {
          final submitting = state.maybeWhen(submitting: () => true, orElse: () => false);
          final hasRaw = _rawCoverBytes != null && _rawCoverBytes!.isNotEmpty;
          final coverForPreview = _editedCoverBytes?.isNotEmpty == true ? _editedCoverBytes : _rawCoverBytes;
          final bakedForPreview = _bakedCoverBytes?.isNotEmpty == true ? _bakedCoverBytes : coverForPreview;
          final hasCover = coverForPreview?.isNotEmpty == true;

          Widget body() {
            return switch (_step) {
              _ClusterCreateStep.pick => KeyedSubtree(
                key: ValueKey(_galleryEpoch),
                child: PostCreateGalleryStep(
                  key: _galleryStepKey,
                  maxSelection: 1,
                  allowVideo: false,
                  onContinue: _onGalleryContinue,
                  onSelectionCountChanged: (_) => setState(() {}),
                ),
              ),
              _ClusterCreateStep.edit =>
                _coverOriginalFile != null && _coverDisplayFile != null && hasRaw
                    ? PostCreateImageEditBody(
                        key: _imageEditKey,
                        originalFile: _coverOriginalFile!,
                        displayFile: _coverDisplayFile!,
                        liveParams: _editParams,
                        stripParams: _stripDisplayParams,
                        flowConfig: kClusterCreateMediaConfig,
                        aspectLabel: _coverAspectLabel,
                        onAspectLabelChanged: (s) => setState(() => _coverAspectLabel = s),
                        onDisplayFileReplaced: _onCoverDisplayReplaced,
                        appBarFlags: _imageEditAppBarFlags,
                      )
                    : const SizedBox.shrink(),
              _ClusterCreateStep.details => Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 28 + MediaQuery.paddingOf(context).bottom),
                  children: [
                    const _SectionLabel(text: 'Как будет в профиле'),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ProfileCollectionCard(
                        index: 0,
                        imageUrl: '',
                        memoryImageBytes: hasCover ? bakedForPreview : null,
                        title: _previewTitle,
                        collectionSubtitle: _previewSubtitle,
                        countLabel: profileCollectionCountLabel(kProfileClusterDraftMockPostCount),
                        isSelected: true,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel(text: 'Основное'),
                    const SizedBox(height: 8),
                    AppTextField(
                      hintText: 'Название · title',
                      controller: _titleCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      readOnly: submitting,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Укажите название';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      hintText: 'Подзаголовок · subtitle',
                      controller: _subtitleCtrl,
                      maxLines: 3,
                      minLines: 2,
                      readOnly: submitting,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppTextButton(
                        text: 'Изменить фото',
                        onPressed: submitting
                            ? null
                            : () async {
                                await _ensureCoverFilesForEdit();
                                if (mounted) {
                                  setState(() => _step = _ClusterCreateStep.edit);
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            };
          }

          if (_step == _ClusterCreateStep.edit) {
            return ValueListenableBuilder<PostImageEditAppBarFlags>(
              valueListenable: _imageEditAppBarFlags,
              builder: (context, flags, _) {
                return Scaffold(
                  backgroundColor: _clusterScaffoldBackground(),
                  appBar: _buildClusterAppBar(context, submitting, editBar: flags),
                  body: body(),
                );
              },
            );
          }

          return Scaffold(
            backgroundColor: _clusterScaffoldBackground(),
            appBar: _buildClusterAppBar(context, submitting, editBar: null),
            body: body(),
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyle.base(
        13,
        color: AppColors.subTextColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}
