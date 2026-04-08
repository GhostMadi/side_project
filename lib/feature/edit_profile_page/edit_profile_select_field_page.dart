import 'dart:developer' as developer;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/feature/cities/presentation/widget/city_single_select_field.dart';
import 'package:side_project/feature/countries/presentation/widget/country_single_select_field.dart';
import 'package:side_project/feature/profile/data/models/profile_model.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:side_project/feature/profile/presentation/edit_profile_field_keys.dart';
import 'package:side_project/feature/profile_categories/presentation/widget/profile_category_single_select_field.dart';

/// Отдельный экран выбора страны / города / категории: как [EditProfileFieldPage], но поле — селектор с бэком.
@RoutePage()
class EditProfileSelectFieldPage extends StatefulWidget {
  const EditProfileSelectFieldPage({super.key, required this.fieldKey});

  /// Только [EditProfileFieldKeys.country], [EditProfileFieldKeys.city], [EditProfileFieldKeys.category].
  final String fieldKey;

  @override
  State<EditProfileSelectFieldPage> createState() => _EditProfileSelectFieldPageState();
}

class _EditProfileSelectFieldPageState extends State<EditProfileSelectFieldPage> {
  bool _saving = false;

  String? _countryCode;
  String? _cityCode;
  String? _categoryCode;

  _SelectFieldConfig get _config => _selectFieldConfig(widget.fieldKey);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final cubit = context.read<ProfileCubit>();
      if (cubit.state.mapOrNull(loaded: (_) => true) != true) {
        await cubit.loadMyProfile();
      }
      if (!mounted) return;
      _syncFromProfile();
    });
  }

  void _syncFromProfile() {
    final p = context.read<ProfileCubit>().state.mapOrNull(loaded: (s) => s.profile);
    if (!mounted || p == null) return;
    setState(() {
      _countryCode = p.countryCode?.code;
      _cityCode = p.cityCode?.cityCode ?? p.citySlug;
      _categoryCode = p.categoryCode?.value;
    });
  }

  Future<void> _onDone() async {
    if (_saving) return;
    final messenger = ScaffoldMessenger.of(context);
    final router = context.router;
    final cubit = context.read<ProfileCubit>();
    final p = cubit.state.mapOrNull(loaded: (s) => s.profile);
    if (p == null) return;

    setState(() => _saving = true);

    String? err;
    switch (widget.fieldKey) {
      case EditProfileFieldKeys.country:
        err = await _saveCountry(cubit, p);
        break;
      case EditProfileFieldKeys.city:
        err = await _saveCity(cubit, p);
        break;
      case EditProfileFieldKeys.category:
        err = await _saveCategory(cubit, p);
        break;
      default:
        err = 'Неизвестное поле';
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (err != null) {
      messenger.showSnackBar(SnackBar(content: Text(err), backgroundColor: AppColors.error));
      return;
    }
    router.maybePop();
  }

  Future<String?> _saveCountry(ProfileCubit cubit, ProfileModel p) async {
    final code = _countryCode?.trim();
    if (code == null || code.isEmpty) {
      if (p.countryCode == null) return null;
      return 'Выберите страну';
    }
    final prev = p.countryCode?.code ?? '';
    if (prev == code.toLowerCase()) return null;

    developer.log('saveCountry: prev=$prev new=${code.toLowerCase()}', name: 'EditProfileSelect');

    final err = await cubit.saveProfileField(
      fieldKey: EditProfileFieldKeys.country,
      value: code.toLowerCase(),
    );
    if (err != null) {
      developer.log('saveCountry: country update failed: $err', name: 'EditProfileSelect');
      return err;
    }

    developer.log('saveCountry: clearing city after country change', name: 'EditProfileSelect');
    final errCity = await cubit.saveProfileField(fieldKey: EditProfileFieldKeys.city, value: '');
    if (errCity != null) {
      developer.log('saveCountry: city clear failed: $errCity', name: 'EditProfileSelect');
    }
    return errCity;
  }

  Future<String?> _saveCity(ProfileCubit cubit, ProfileModel p) async {
    if (p.countryCode == null) {
      return 'Сначала выберите страну';
    }
    final code = _cityCode?.trim();
    if (code == null || code.isEmpty) {
      final prevCity = p.cityCode?.cityCode ?? p.citySlug;
      if (prevCity == null || prevCity.isEmpty) return null;
      return 'Выберите город';
    }
    final prev = p.cityCode?.cityCode ?? p.citySlug ?? '';
    if (prev.toLowerCase() == code.toLowerCase()) return null;
    return cubit.saveProfileField(fieldKey: EditProfileFieldKeys.city, value: code);
  }

  Future<String?> _saveCategory(ProfileCubit cubit, ProfileModel p) async {
    final code = _categoryCode?.trim();
    final prev = p.categoryCode?.value ?? '';
    if (code == null || code.isEmpty) {
      if (prev.isEmpty) return null;
      return 'Выберите категорию';
    }
    if (prev == code.toLowerCase()) return null;
    return cubit.saveProfileField(fieldKey: EditProfileFieldKeys.category, value: code.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileCubit>().state.mapOrNull(loaded: (s) => s.profile);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppAppBar(
        title: Text(
          _config.title,
          style: AppTextStyle.base(17, color: AppColors.textColor, fontWeight: FontWeight.w700),
        ),
        automaticallyImplyLeading: true,
        actions: [
          TextButton(
            onPressed: _saving ? null : _onDone,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_config.hint != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _config.hint!,
                  style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
                ),
              ),
            if (p == null)
              const Center(
                child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
              )
            else
              _buildField(p),
          ],
        ),
      ),
    );
  }

  Widget _buildField(ProfileModel p) {
    switch (widget.fieldKey) {
      case EditProfileFieldKeys.country:
        return CountrySingleSelectField(
          hint: 'Выберите страну',
          sheetTitle: 'Страна',
          value: _countryCode,
          onChanged: (v) => setState(() => _countryCode = v),
        );
      case EditProfileFieldKeys.city:
        return CitySingleSelectField(
          hint: 'Выберите город',
          sheetTitle: 'Город',
          countryCode: p.countryCode?.code,
          value: _cityCode,
          onChanged: (v) => setState(() => _cityCode = v),
        );
      case EditProfileFieldKeys.category:
        return ProfileCategorySingleSelectField(
          hint: 'Выберите категорию',
          sheetTitle: 'Категория',
          value: _categoryCode,
          onChanged: (v) => setState(() => _categoryCode = v),
        );
      default:
        return Text('Неподдерживаемое поле', style: AppTextStyle.base(14, color: AppColors.error));
    }
  }
}

class _SelectFieldConfig {
  const _SelectFieldConfig({required this.title, this.hint});

  final String title;
  final String? hint;
}

_SelectFieldConfig _selectFieldConfig(String key) {
  switch (key) {
    case EditProfileFieldKeys.country:
      return const _SelectFieldConfig(
        title: 'Страна',
        hint: 'Выберите страну из списка. Данные подгружаются с сервера.',
      );
    case EditProfileFieldKeys.city:
      return const _SelectFieldConfig(
        title: 'Город',
        hint: 'Список городов зависит от выбранной страны в профиле.',
      );
    case EditProfileFieldKeys.category:
      return const _SelectFieldConfig(title: 'Категория', hint: 'Направление или тип профиля.');
    default:
      return const _SelectFieldConfig(title: 'Выбор');
  }
}
