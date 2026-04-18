import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/locale/app_supported_locales.dart';
import 'package:side_project/core/storage/prefs/app_locale_prefs_storage.dart';

@lazySingleton
class AppLocaleCubit extends Cubit<Locale> {
  AppLocaleCubit(this._prefs)
      : super(
          AppSupportedLocales.matchDeviceOrFallback(
            WidgetsBinding.instance.platformDispatcher.locale,
          ),
        ) {
    _loadFromStorage();
  }

  final AppLocalePrefsStorage _prefs;

  Future<void> _loadFromStorage() async {
    final code = await _prefs.readCode();
    if (code == null || code.trim().isEmpty) return;
    final loc = AppLocalePrefsStorage.localeFromCode(code);
    if (loc == null) return;
    if (!AppSupportedLocales.contains(loc)) return;
    emit(loc);
  }

  Future<void> setLocale(Locale locale) async {
    if (!AppSupportedLocales.contains(locale)) return;
    await _prefs.writeCode(locale.languageCode);
    emit(locale);
  }
}
