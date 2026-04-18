// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Clover';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get editProfileFieldDone => 'Done';

  @override
  String get profileTabLabel => 'Profile';

  @override
  String get mapTabLabel => 'Map';

  @override
  String get createTabLabel => 'Create';

  @override
  String get chatTabLabel => 'Chats';
}
