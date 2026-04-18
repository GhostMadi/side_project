import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_dialog.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/feature/edit_profile_page/profile_image_upload_flow.dart';
import 'package:side_project/feature/profile/data/models/profile_model.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:side_project/feature/profile/presentation/edit_profile_field_keys.dart';

@RoutePage()
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final cubit = context.read<ProfileCubit>();
      if (cubit.state.mapOrNull(loaded: (_) => true) != true) {
        await cubit.loadMyProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppAppBar(
        title: Text(
          'Редактировать профиль',
          style: AppTextStyle.base(17, color: AppColors.textColor, fontWeight: FontWeight.w700),
        ),
        automaticallyImplyLeading: true,
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return state.map(
            initial: (_) => _EditProfileLoadingBody(message: null),
            loading: (_) => _EditProfileLoadingBody(message: null),
            error: (e) => _EditProfileLoadingBody(message: e.message),
            loaded: (s) {
              final p = s.profile;
              final email = p.email;

              return AbsorbPointer(
                absorbing: _uploading,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        if (_uploading)
                          const LinearProgressIndicator(minHeight: 2, color: AppColors.primary),
                        _EditProfileHero(
                          coverUrl: p.backgroundUrl,
                          avatarUrl: p.avatarUrl,
                          onAvatarTap: _uploading ? null : () => _openPhotoActions(isCover: false),
                          onCoverTap: _uploading ? null : () => _openPhotoActions(isCover: true),
                        ),
                        const SizedBox(height: 32),
                        if (email != null && email.isNotEmpty)
                          _EditProfileFieldTile(label: 'Email', value: email, onTap: null, showChevron: false),
                        _EditProfileFieldTile(
                          label: 'Обложка',
                          value: _photoTileValue(p.backgroundUrl),
                          onTap: () => _openField(context, EditProfileFieldKeys.background, ''),
                        ),
                        _EditProfileFieldTile(
                          label: 'Аватар',
                          value: _photoTileValue(p.avatarUrl),
                          onTap: () => _openField(context, EditProfileFieldKeys.avatar, ''),
                        ),
                        _EditProfileFieldTile(
                          label: 'Имя',
                          value: p.fullName ?? '',
                          onTap: () => _openField(context, EditProfileFieldKeys.fullName, p.fullName ?? ''),
                        ),
                        _EditProfileFieldTile(
                          label: 'Имя пользователя',
                          value: p.username ?? '',
                          onTap: () => _openField(context, EditProfileFieldKeys.username, p.username ?? ''),
                        ),
                        _EditProfileFieldTile(
                          label: 'Страна',
                          value: _countryTileValue(p),
                          onTap: () => context.router.push(
                            EditProfileSelectFieldRoute(fieldKey: EditProfileFieldKeys.country),
                          ),
                        ),
                        _EditProfileFieldTile(
                          label: 'Город',
                          value: _cityTileValue(p),
                          onTap: _hasCountry(p)
                              ? () => context.router.push(
                                    EditProfileSelectFieldRoute(fieldKey: EditProfileFieldKeys.city),
                                  )
                              : null,
                          showChevron: _hasCountry(p),
                        ),
                        _EditProfileFieldTile(
                          label: 'Категория',
                          value: _categoryTileValue(p),
                          onTap: () => context.router.push(
                            EditProfileSelectFieldRoute(fieldKey: EditProfileFieldKeys.category),
                          ),
                        ),
                        _EditProfileFieldTile(
                          label: 'Телефон',
                          value: p.phone ?? '',
                          onTap: () => _openField(context, EditProfileFieldKeys.phone, p.phone ?? ''),
                        ),
                        _EditProfileFieldTile(
                          label: 'О себе',
                          value: p.bio ?? '',
                          onTap: () => _openField(context, EditProfileFieldKeys.bio, p.bio ?? ''),
                          multilineValue: true,
                          isLast: true,
                        ),
                        SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
                      ],
                    ),
                    if (_uploading)
                      Positioned.fill(
                        child: ColoredBox(
                          color: Colors.white.withValues(alpha: 0.45),
                          child: const Center(
                            child: SizedBox(
                              width: 36,
                              height: 36,
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
        },
      ),
    );
  }

  Future<void> _openPhotoActions({required bool isCover}) async {
    final cubit = context.read<ProfileCubit>();
    final p = cubit.state.mapOrNull(loaded: (s) => s.profile);
    if (p == null) return;
    final hasPhoto = isCover
        ? (p.backgroundUrl?.trim().isNotEmpty ?? false)
        : (p.avatarUrl?.trim().isNotEmpty ?? false);

    await AppBottomSheet.show<void>(
      context: context,
      title: isCover ? 'Обложка' : 'Аватар',
      upperCaseTitle: false,
      contentBottomSpacing: 16,
      content: Builder(
        builder: (sheetContext) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                leading: Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
                title: Text(
                  hasPhoto ? 'Заменить фото' : 'Загрузить из галереи',
                  style: AppTextStyle.base(16, color: AppColors.textColor, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickProfileImage(uploadBackground: isCover);
                },
              ),
              if (hasPhoto)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  leading: Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  title: Text(
                    'Удалить',
                    style: AppTextStyle.base(16, color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final ok = await AppDialog.showConfirm(
                      context: context,
                      title: isCover ? 'Удалить обложку?' : 'Удалить аватар?',
                      message: isCover ? 'Обложка будет убрана из профиля.' : 'Фото профиля будет убрано.',
                      confirmLabel: 'Удалить',
                      confirmIsDestructive: true,
                    );
                    if (ok != true || !mounted) return;
                    setState(() => _uploading = true);
                    final err = isCover ? await cubit.deleteBackgroundImage() : await cubit.deleteAvatarImage();
                    if (!mounted) return;
                    setState(() => _uploading = false);
                    if (err != null) {
                      AppSnackBar.show(context, message: err, kind: AppSnackBarKind.error);
                    }
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickProfileImage({required bool uploadBackground}) async {
    setState(() => _uploading = true);
    final err = await pickCropAndUploadProfileImage(context: context, isCover: uploadBackground);
    if (!mounted) return;
    setState(() => _uploading = false);
    if (err != null) {
      AppSnackBar.show(context, message: err, kind: AppSnackBarKind.error);
    }
  }

  String _photoTileValue(String? url) {
    final t = url?.trim();
    if (t == null || t.isEmpty) return 'Загрузить';
    return 'Изменить или удалить';
  }

  void _openField(BuildContext context, String fieldKey, String initial) {
    context.router.push(EditProfileFieldRoute(fieldKey: fieldKey, initialValue: initial));
  }

  bool _hasCountry(ProfileModel p) => p.countryCode != null;

  String _countryTileValue(ProfileModel p) {
    final c = p.countryCode;
    if (c == null) return '';
    return c.labelRu;
  }

  String _cityTileValue(ProfileModel p) {
    if (!_hasCountry(p)) return 'Сначала выберите страну';
    final line = p.cityLabel;
    return line ?? '';
  }

  String _categoryTileValue(ProfileModel p) {
    final c = p.categoryCode;
    if (c == null) return '';
    return c.labelRu;
  }
}

class _EditProfileLoadingBody extends StatelessWidget {
  const _EditProfileLoadingBody({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 24),
      children: [
        const _EditProfileHero(coverUrl: null, avatarUrl: null),
        const SizedBox(height: 56),
        if (message != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.35),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => context.read<ProfileCubit>().loadMyProfile(),
              child: Text(
                'Повторить',
                style: AppTextStyle.base(16, color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

/// Минималистичная строка: без карточек, только типографика и тонкая линия снизу.
class _EditProfileFieldTile extends StatelessWidget {
  const _EditProfileFieldTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.showChevron = true,
    this.multilineValue = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool multilineValue;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final hasValue = value.trim().isNotEmpty;
    final display = hasValue ? value.trim() : 'Заполнить';

    final labelStyle = AppTextStyle.base(
      14,
      color: AppColors.subTextColor.withValues(alpha: 0.85),
      fontWeight: FontWeight.w500,
      height: 1.25,
    );
    final valueStyle = AppTextStyle.base(
      multilineValue ? 15 : 15,
      color: hasValue ? AppColors.textColor : AppColors.subTextColor.withValues(alpha: 0.45),
      fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
      height: multilineValue ? 1.45 : 1.3,
    );

    final padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 15);

    Widget body;
    if (multilineValue) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(height: 8),
                Text(display, maxLines: 8, overflow: TextOverflow.clip, style: valueStyle),
              ],
            ),
          ),
          if (showChevron && onTap != null) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.subTextColor.withValues(alpha: 0.22),
              ),
            ),
          ],
        ],
      );
    } else {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: Text(label, style: labelStyle)),
          Expanded(
            flex: 6,
            child: Text(
              display,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: valueStyle,
            ),
          ),
          if (showChevron && onTap != null) ...[
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.subTextColor.withValues(alpha: 0.22),
            ),
          ],
        ],
      );
    }

    final interactive = onTap == null
        ? Padding(padding: padding, child: body)
        : Material(
            color: AppColors.pageBackground,
            child: InkWell(
              onTap: onTap,
              splashColor: AppColors.primary.withValues(alpha: 0.06),
              highlightColor: AppColors.subTextColor.withValues(alpha: 0.04),
              child: Padding(padding: padding, child: body),
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        interactive,
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Divider(height: 1, thickness: 0.5, color: AppColors.border.withValues(alpha: 0.55)),
          ),
      ],
    );
  }
}

/// Обложка и аватар с сервера; без заглушек-картинок из сети (как на экране профиля).
class _EditProfileHero extends StatelessWidget {
  const _EditProfileHero({
    this.coverUrl,
    this.avatarUrl,
    this.onAvatarTap,
    this.onCoverTap,
  });

  final String? coverUrl;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onCoverTap;

  @override
  Widget build(BuildContext context) {
    final hasCover = coverUrl != null && coverUrl!.trim().isNotEmpty;
    final avatarTrim = avatarUrl?.trim();
    final hasAvatar = avatarTrim != null && avatarTrim.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Непозиционированный ребёнок задаёт высоту Stack (иначе в ListView — только Positioned → размер 0).
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onCoverTap,
                  borderRadius: BorderRadius.circular(24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: hasCover
                          ? DecoratedBox(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(coverUrl!.trim()),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : ColoredBox(
                              color: AppColors.surfaceSoft,
                              child: Center(
                                child: Icon(
                                  AppIcons.addPhotoAlternate.icon,
                                  size: 52,
                                  color: AppColors.subTextColor.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -42,
                child: GestureDetector(
                  onTap: onAvatarTap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFC5FEB7)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: const Color(0xFFF0F0F0),
                            backgroundImage: hasAvatar ? NetworkImage(avatarTrim) : null,
                            child: hasAvatar
                                ? null
                                : const Icon(Icons.person_rounded, size: 44, color: Color(0xFF9E9E9E)),
                          ),
                        ),
                      ),
                      if (onAvatarTap != null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 1,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: onAvatarTap,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 18,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(100),
                  child: InkWell(
                    onTap: onCoverTap,
                    borderRadius: BorderRadius.circular(100),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_camera_outlined, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Обложка',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 52),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.touch_app_outlined, size: 18, color: AppColors.subTextColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Нажмите на обложку, аватар или иконку камеры — откроется меню: загрузить или удалить фото. '
                    'То же в списке ниже: пункты «Обложка» и «Аватар».',
                    style: AppTextStyle.base(12, color: AppColors.subTextColor, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
