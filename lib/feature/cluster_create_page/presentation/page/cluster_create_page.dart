import 'dart:async';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart' show sl;
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_text_button.dart';
import 'package:side_project/core/shared/app_text_field.dart';
import 'package:side_project/core/shared/ig_edit/ig_edit_bake.dart';
import 'package:side_project/feature/cluster/presentation/cluster_list_refresh.dart';
import 'package:side_project/feature/cluster_create_page/cluster_cover_pick_flow.dart';
import 'package:side_project/feature/cluster_create_page/data/cluster_preview_session.dart';
import 'package:side_project/feature/cluster_create_page/presentation/cubit/cluster_create_cubit.dart';
import 'package:side_project/feature/cluster_create_page/presentation/widget/cluster_cover_edit_step.dart';
import 'package:side_project/feature/post_create_page/presentation/page/post_create_models.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:side_project/feature/profile_page/presentation/models/profile_feed_preview.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_collection_card.dart';

/// Экран создания кластера: форма → [ClusterRepository.createCluster] через [ClusterCreateCubit].
@RoutePage()
class ClusterCreatePage extends StatefulWidget {
  const ClusterCreatePage({super.key});

  @override
  State<ClusterCreatePage> createState() => _ClusterCreatePageState();
}

enum _ClusterCreateStep { pick, edit, details }

class _BakeCoverInput {
  const _BakeCoverInput(this.bytes, this.params);
  final Uint8List bytes;
  final PostImageEditParams params;
}

Uint8List _bakeCoverInIsolate(_BakeCoverInput input) {
  return bakePostImageEdit(input.bytes, input.params);
}

class _ClusterCreatePageState extends State<ClusterCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();

  _ClusterCreateStep _step = _ClusterCreateStep.pick;
  Uint8List? _rawCoverBytes;
  Uint8List? _editedCoverBytes;
  Uint8List? _bakedCoverBytes;
  late final ValueNotifier<PostImageEditParams> _editParams;

  late final VoidCallback _fieldsListener;
  bool _sessionPostFrameScheduled = false;

  @override
  void initState() {
    super.initState();
    _editParams = ValueNotifier<PostImageEditParams>(const PostImageEditParams());
    final existing = ClusterPreviewSession.draftNotifier.value;
    if (existing != null) {
      _titleCtrl.text = existing.title;
      _subtitleCtrl.text = existing.subtitle;
      if (existing.coverBytes != null && existing.coverBytes!.isNotEmpty) {
        final b = Uint8List.fromList(existing.coverBytes!);
        _rawCoverBytes = b;
        _editedCoverBytes = b;
        _step = _ClusterCreateStep.details;
      }
    }
    void onFieldsChanged() {
      setState(() {});
      _syncToSession();
    }

    _fieldsListener = onFieldsChanged;
    _titleCtrl.addListener(_fieldsListener);
    _subtitleCtrl.addListener(_fieldsListener);
    _syncToSession();
  }

  void _syncToSession() {
    if (_sessionPostFrameScheduled) return;
    _sessionPostFrameScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionPostFrameScheduled = false;
      if (!mounted) return;
      ClusterPreviewSession.update(
        title: _titleCtrl.text,
        subtitle: _subtitleCtrl.text,
        coverBytes: _editedCoverBytes ?? _rawCoverBytes,
      );
    });
  }

  @override
  void dispose() {
    _titleCtrl.removeListener(_fieldsListener);
    _subtitleCtrl.removeListener(_fieldsListener);
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _editParams.dispose();
    super.dispose();
  }

  Future<void> _pickRawCover() async {
    final bytes = await pickClusterCoverRaw(context);
    if (!mounted || bytes == null) return;
    setState(() {
      _rawCoverBytes = bytes;
      _editedCoverBytes = null;
      _step = _ClusterCreateStep.edit;
    });
    _syncToSession();
  }

  Future<void> _editCover() async {
    final raw = _rawCoverBytes;
    if (raw == null || raw.isEmpty) return;
    final out = await editClusterCover(context, raw);
    if (!mounted || out == null) return;
    setState(() {
      _editedCoverBytes = out;
      _bakedCoverBytes = null;
    });
    _syncToSession();
  }

  void _clearCover() {
    setState(() {
      _rawCoverBytes = null;
      _editedCoverBytes = null;
      _bakedCoverBytes = null;
      _editParams.value = const PostImageEditParams();
      _step = _ClusterCreateStep.pick;
    });
    _syncToSession();
  }

  String get _previewTitle {
    final t = _titleCtrl.text.trim();
    return t.isEmpty ? kClusterDraftPlaceholderTitle : t;
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
    setState(() {
      _step = switch (_step) {
        _ClusterCreateStep.edit => _ClusterCreateStep.pick,
        _ClusterCreateStep.details => _ClusterCreateStep.edit,
        _ClusterCreateStep.pick => _ClusterCreateStep.pick,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClusterCreateCubit>(),
      child: BlocConsumer<ClusterCreateCubit, ClusterCreateState>(
        listener: (context, state) {
          state.whenOrNull(
            success: (_) {
              ClusterPreviewSession.clear();
              clusterListRefreshTick.value++;
              unawaited(sl<ProfileCubit>().refreshMyProfile());
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Кластер создан')));
              context.router.maybePop();
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

          final stepTitle = switch (_step) {
            _ClusterCreateStep.pick => 'Выбор фото',
            _ClusterCreateStep.edit => 'Редактирование',
            _ClusterCreateStep.details => 'Информация',
          };

          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            appBar: AppAppBar(
              title: Text(
                stepTitle,
                style: AppTextStyle.base(17, color: AppColors.textColor, fontWeight: FontWeight.w700),
              ),
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: submitting ? null : _goBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
            ),
            body: switch (_step) {
              _ClusterCreateStep.pick => _PickStep(
                bytes: _rawCoverBytes,
                onPick: submitting ? null : () => _pickRawCover(),
                onClear: submitting ? null : (hasRaw ? _clearCover : null),
                onContinue: submitting || !hasRaw
                    ? null
                    : () => setState(() => _step = _ClusterCreateStep.edit),
              ),
              _ClusterCreateStep.edit => _EditStep(
                rawBytes: _rawCoverBytes,
                editedBytes: _editedCoverBytes,
                params: _editParams,
                onCrop: submitting ? null : () => _editCover(),
                onBakeAndContinue: submitting || !hasRaw
                    ? null
                    : () async {
                        final src = _editedCoverBytes ?? _rawCoverBytes;
                        if (src == null || src.isEmpty) return;
                        final p = _editParams.value;
                        // Neutral -> don't waste CPU.
                        final baked = p.isNeutral
                            ? src
                            : await compute(_bakeCoverInIsolate, _BakeCoverInput(src, p));
                        if (!mounted) return;
                        setState(() {
                          _bakedCoverBytes = baked;
                          _step = _ClusterCreateStep.details;
                        });
                        _syncToSession();
                      },
              ),
              _ClusterCreateStep.details => Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
                              if (v == null || v.trim().isEmpty) {
                                return 'Укажите название';
                              }
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
                                  : () {
                                      setState(() => _step = _ClusterCreateStep.edit);
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + MediaQuery.paddingOf(context).bottom),
                      child: AppButton(
                        text: submitting ? 'Создание…' : 'Создать кластер',
                        onPressed: submitting ? () {} : () => _submit(context),
                      ),
                    ),
                  ],
                ),
              ),
            },
          );
        },
      ),
    );
  }
}

class _PickStep extends StatelessWidget {
  const _PickStep({
    required this.bytes,
    required this.onPick,
    required this.onClear,
    required this.onContinue,
  });

  final Uint8List? bytes;
  final VoidCallback? onPick;
  final VoidCallback? onClear;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final has = bytes != null && bytes!.isNotEmpty;
    final side = MediaQuery.sizeOf(context).width - 40;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          SizedBox(
            width: side,
            height: side,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPick,
                borderRadius: _clusterCoverLargePreviewRadius,
                child: Ink(
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: _clusterCoverLargePreviewRadius,
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: ClipRRect(
                    borderRadius: _clusterCoverLargePreviewRadius,
                    child: has
                        ? Image.memory(bytes!, fit: BoxFit.cover, gaplessPlayback: true)
                        : SizedBox.expand(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(AppIcons.addPhotoAlternate.icon, color: AppColors.primary, size: 40),
                                const SizedBox(height: 10),
                                Text(
                                  'Выбрать фото',
                                  style: AppTextStyle.base(
                                    16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Одна фотография для обложки кластера',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          AppButton(text: has ? 'Далее' : 'Выбрать', onPressed: has ? onContinue : onPick),
          if (onClear != null) ...[
            const SizedBox(height: 10),
            AppTextButton(text: 'Убрать фото', onPressed: onClear),
          ],
        ],
      ),
    );
  }
}

class _EditStep extends StatelessWidget {
  const _EditStep({
    required this.rawBytes,
    required this.editedBytes,
    required this.params,
    required this.onCrop,
    required this.onBakeAndContinue,
  });

  final Uint8List? rawBytes;
  final Uint8List? editedBytes;
  final ValueNotifier<PostImageEditParams> params;
  final VoidCallback? onCrop;
  final Future<void> Function()? onBakeAndContinue;

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes = editedBytes?.isNotEmpty == true ? editedBytes : rawBytes;
    if (bytes == null || bytes.isEmpty) return const SizedBox.shrink();

    return ClusterCoverEditStep(
      bytes: bytes,
      params: params,
      onCrop: onCrop,
      onContinue: onBakeAndContinue,
      borderRadius: _clusterCoverLargePreviewRadius,
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

const BorderRadius _clusterCoverLargePreviewRadius = BorderRadius.only(
  topLeft: Radius.circular(14),
  topRight: Radius.circular(10),
  bottomRight: Radius.circular(14),
  bottomLeft: Radius.circular(10),
);
