import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_dialog.dart';
import 'package:side_project/core/shared/app_informer.dart';
import 'package:side_project/core/shared/app_outlined_button.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/shared/app_text_field.dart';
import 'package:side_project/feature/edit_profile_page/profile_image_upload_flow.dart';
import 'package:side_project/feature/profile/data/models/profile_model.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:side_project/feature/profile/presentation/edit_profile_field_keys.dart';

/// Отдельный экран редактирования одного поля (как в Instagram).
@RoutePage()
class EditProfileFieldPage extends StatefulWidget {
  const EditProfileFieldPage({super.key, required this.fieldKey, required this.initialValue});

  final String fieldKey;
  final String initialValue;

  @override
  State<EditProfileFieldPage> createState() => _EditProfileFieldPageState();
}

class _EditProfileFieldPageState extends State<EditProfileFieldPage> {
  late final TextEditingController _controller;
  bool _saving = false;

  _FieldConfig get _config => _fieldConfig(widget.fieldKey);

  bool get _isUsername => widget.fieldKey == EditProfileFieldKeys.username;

  bool get _isPhotoField =>
      widget.fieldKey == EditProfileFieldKeys.avatar || widget.fieldKey == EditProfileFieldKeys.background;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDone() async {
    if (_saving) return;
    final router = context.router;
    final cubit = context.read<ProfileCubit>();
    setState(() => _saving = true);
    final err = await cubit.saveProfileField(fieldKey: widget.fieldKey, value: _controller.text);
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      AppSnackBar.show(context, message: err, kind: AppSnackBarKind.error);
      return;
    }
    router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPhotoField) {
      return _EditProfilePhotoFieldPage(fieldKey: widget.fieldKey);
    }
    if (_isUsername) {
      return BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final p = state.mapOrNull(loaded: (s) => s.profile);
          if (p == null) {
            return Scaffold(
              backgroundColor: AppColors.pageBackground,
              appBar: AppAppBar(
                title: Text(
                  _config.title,
                  style: AppTextStyle.base(17, color: AppColors.textColor, fontWeight: FontWeight.w700),
                ),
                automaticallyImplyLeading: true,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          final locked = !p.canChangeUsername;
          return _scaffold(usernameLocked: locked);
        },
      );
    }
    return _scaffold(usernameLocked: false);
  }

  Widget _scaffold({required bool usernameLocked}) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppAppBar(
        title: Text(
          _config.title,
          style: AppTextStyle.base(17, color: AppColors.textColor, fontWeight: FontWeight.w700),
        ),
        automaticallyImplyLeading: true,
        actions: [
          if (_isUsername && usernameLocked)
            TextButton(
              onPressed: () => context.router.maybePop(),
              child: Text(
                'Закрыть',
                style: AppTextStyle.base(16, color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            )
          else
            TextButton(
              onPressed: (_saving || (_isUsername && usernameLocked)) ? null : _onDone,
              child: _saving
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : Text(
                      'Готово',
                      style: AppTextStyle.base(16, color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isUsername && usernameLocked) ...[
              const AppInformer(message: 'Пока что нельзя редактировать профиль.'),
              const SizedBox(height: 16),
            ],
            if (_config.hint != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _config.hint!,
                  style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
                ),
              ),
            AppTextField(
              controller: _controller,
              hintText: _config.placeholder,
              autofocus: _isUsername ? !usernameLocked : true,
              readOnly: _isUsername && usernameLocked,
              textCapitalization: _config.capitalization,
              autocorrect: _config.autocorrect,
              keyboardType: _config.keyboardType,
              maxLines: _config.maxLines,
              minLines: _config.minLines,
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран только для фото: загрузить из галереи или удалить.
class _EditProfilePhotoFieldPage extends StatefulWidget {
  const _EditProfilePhotoFieldPage({required this.fieldKey});

  final String fieldKey;

  @override
  State<_EditProfilePhotoFieldPage> createState() => _EditProfilePhotoFieldPageState();
}

class _EditProfilePhotoFieldPageState extends State<_EditProfilePhotoFieldPage> {
  bool _busy = false;

  bool get _isCover => widget.fieldKey == EditProfileFieldKeys.background;

  String get _title => _isCover ? 'Обложка профиля' : 'Аватар';

  String? _imageUrl(ProfileModel p) {
    final u = _isCover ? p.backgroundUrl : p.avatarUrl;
    final t = u?.trim();
    return t != null && t.isNotEmpty ? t : null;
  }

  Future<void> _upload() async {
    if (_busy) return;
    setState(() => _busy = true);
    final err = await pickCropAndUploadProfileImage(context: context, isCover: _isCover);
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      AppSnackBar.show(context, message: err, kind: AppSnackBarKind.error);
    }
  }

  Future<void> _delete() async {
    if (_busy) return;
    final cubit = context.read<ProfileCubit>();
    final p = cubit.state.mapOrNull(loaded: (s) => s.profile);
    if (p == null) return;
    if (_imageUrl(p) == null) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: _isCover ? 'Сначала загрузите обложку.' : 'Сначала загрузите аватар.',
        kind: AppSnackBarKind.info,
      );
      return;
    }

    final ok = await AppDialog.showConfirm(
      context: context,
      title: _isCover ? 'Удалить обложку?' : 'Удалить аватар?',
      message: _isCover ? 'Обложка будет убрана из профиля.' : 'Фото профиля будет убрано.',
      confirmLabel: 'Удалить',
      confirmIsDestructive: true,
    );
    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    final err = _isCover ? await cubit.deleteBackgroundImage() : await cubit.deleteAvatarImage();
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      AppSnackBar.show(context, message: err, kind: AppSnackBarKind.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final p = state.mapOrNull(loaded: (s) => s.profile);
        if (p == null) {
          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            appBar: AppAppBar(
              title: Text(
                _title,
                style: AppTextStyle.base(17, color: AppColors.textColor, fontWeight: FontWeight.w700),
              ),
              automaticallyImplyLeading: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final url = _imageUrl(p);

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppAppBar(
            title: Text(
              _title,
              style: AppTextStyle.base(17, color: AppColors.textColor, fontWeight: FontWeight.w700),
            ),
            automaticallyImplyLeading: true,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppInformer(
                      title: _isCover ? 'Обложка' : 'Аватар',
                      message: _isCover
                          ? 'Только галерея: загрузите новое фото или удалите текущее. Редактор подгонит кадр под рамку.'
                          : 'Только галерея: загрузите фото или удалите его. Редактор подгонит кадр под круг.',
                      leading: Icon(
                        _isCover ? Icons.panorama_wide_angle_select_rounded : Icons.account_circle_outlined,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: _PhotoPreview(isCover: _isCover, imageUrl: url),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: AppOutlinedButton(
                            text: 'Загрузить',
                            isExpanded: true,
                            onPressed: _busy ? null : _upload,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'Загрузить',
                                  style: AppTextStyle.base(
                                    16,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: _busy ? null : _delete,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: BorderSide(
                                  color: !_busy ? AppColors.error.withValues(alpha: 0.45) : AppColors.border,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Удалить',
                                    style: AppTextStyle.base(
                                      16,
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_busy)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.white.withValues(alpha: 0.5),
                    child: const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.isCover, required this.imageUrl});

  final bool isCover;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (isCover) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          height: 160,
          color: AppColors.surfaceSoft,
          child: imageUrl != null
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover),
                  ),
                )
              : Center(
                  child: Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.subTextColor),
                ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFC5FEB7)),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: CircleAvatar(
          radius: 72,
          backgroundColor: const Color(0xFFF0F0F0),
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Icon(Icons.person_rounded, size: 72, color: AppColors.subTextColor)
              : null,
        ),
      ),
    );
  }
}

class _FieldConfig {
  const _FieldConfig({
    required this.title,
    this.hint,
    required this.placeholder,
    this.capitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.keyboardType = TextInputType.text,
    this.maxLines,
    this.minLines,
  });

  final String title;
  final String? hint;
  final String placeholder;
  final TextCapitalization capitalization;
  final bool autocorrect;
  final TextInputType keyboardType;
  final int? maxLines;
  final int? minLines;
}

_FieldConfig _fieldConfig(String key) {
  switch (key) {
    case EditProfileFieldKeys.fullName:
      return const _FieldConfig(
        title: 'Имя',
        hint: 'Имя помогает людям узнать вас в приложении.',
        placeholder: 'Отображаемое имя',
        capitalization: TextCapitalization.words,
      );
    case EditProfileFieldKeys.username:
      return const _FieldConfig(
        title: 'Имя пользователя',
        hint: 'Латиница, цифры и подчёркивание. Так вас показывают в профиле с @.',
        placeholder: 'username',
        capitalization: TextCapitalization.none,
        autocorrect: false,
      );
    case EditProfileFieldKeys.category:
      return const _FieldConfig(
        title: 'Категория',
        hint: 'Код категории из справочника (например beauty, music).',
        placeholder: 'Категория',
        capitalization: TextCapitalization.sentences,
      );
    case EditProfileFieldKeys.city:
      return const _FieldConfig(
        title: 'Город',
        placeholder: 'Город',
        capitalization: TextCapitalization.words,
      );
    case EditProfileFieldKeys.country:
      return const _FieldConfig(
        title: 'Страна',
        hint: 'Двухбуквенный или короткий код, например KZ или ES.',
        placeholder: 'Код страны',
        capitalization: TextCapitalization.characters,
        autocorrect: false,
      );
    case EditProfileFieldKeys.phone:
      return const _FieldConfig(title: 'Телефон', placeholder: '+7 …', keyboardType: TextInputType.phone);
    case EditProfileFieldKeys.bio:
      return const _FieldConfig(
        title: 'О себе',
        hint: 'Расскажите немного о себе — это видно в профиле.',
        placeholder: 'Несколько строк о себе…',
        capitalization: TextCapitalization.sentences,
        maxLines: 8,
        minLines: 4,
      );
    default:
      return const _FieldConfig(title: 'Поле', placeholder: '');
  }
}
