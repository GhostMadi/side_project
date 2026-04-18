// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Clover';

  @override
  String get editProfileTitle => 'Редактировать профиль';

  @override
  String get editProfileFieldDone => 'Готово';

  @override
  String get profileTabLabel => 'Профиль';

  @override
  String get mapTabLabel => 'Карта';

  @override
  String get createTabLabel => 'Создать';

  @override
  String get chatTabLabel => 'Чаты';
}
