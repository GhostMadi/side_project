import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/dependencies/get_it.config.dart';

final sl = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // название метода генерации
  preferRelativeImports: true, // использовать относительные импорты
  asExtension: true, // генерация в виде расширения для GetIt
)
Future<void> configureDependencies() async => sl.init();
