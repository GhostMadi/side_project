import 'package:get_it/get_it.dart';
import 'package:side_project/feature/announcments/data/repository/announcement_repository_impl.dart';
import 'package:side_project/feature/announcments/domain/repository/announcement_repository.dart';
import 'package:side_project/feature/announcments/presentation/cubit/announcement_cubit.dart';
import 'package:side_project/feature/login/data/repository/auth_repository_impl.dart';
import 'package:side_project/feature/login/domain/repository/auth_repository.dart';
import 'package:side_project/feature/login/presentation/cubit/auth_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt sl = GetIt.instance;

Future<void> setupLocator() async {
  // == repositories == //

  // сначала регаем сам клиент
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  //-- auth --//
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  //-- announcements --//
  sl.registerLazySingleton<AnnouncementRepository>(
    () => AnnouncementRepositoryImpl(client: sl<SupabaseClient>()),
  );

  // == cubits == //

  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(sl.get<AuthRepository>()),
  );

  sl.registerFactory<AnnouncementCubit>(
    () => AnnouncementCubit(repository: sl.get<AnnouncementRepository>()),
  );
}
