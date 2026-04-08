import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/locale/app_supported_locales.dart';
import 'package:side_project/core/storage/app_locale_prefs_storage.dart';

@lazySingleton
class AppLocaleCubit extends Cubit<Locale> {
  AppLocaleCubit(this._prefs) : super(_resolveInitial(_prefs));

  final AppLocalePrefsStorage _prefs;

  static Locale _resolveInitial(AppLocalePrefsStorage prefs) {
    final code = prefs.readCode();
    if (code != null && code.isNotEmpty) {
      final loc = AppLocalePrefsStorage.localeFromCode(code);
      if (loc != null && AppSupportedLocales.contains(loc)) {
        return loc;
      }
    }
    return AppSupportedLocales.matchDeviceOrFallback(
      WidgetsBinding.instance.platformDispatcher.locale,
    );
  }

  Future<void> setLocale(Locale locale) async {
    if (!AppSupportedLocales.contains(locale)) return;
    await _prefs.writeCode(locale.languageCode);
    emit(locale);
  }
}
