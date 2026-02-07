// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../feature/login/data/repository/auth_repository_impl.dart' as _i350;
import '../../feature/login/domain/repository/auth_repository.dart' as _i704;
import '../../feature/login/presentation/cubit/auth_cubit.dart' as _i899;
import '../../feature/request/data/repository/brand_request_repository_impl.dart'
    as _i181;
import '../../feature/request/domain/repository/brand_request_repository.dart'
    as _i838;
import '../../feature/request/presentation/cubit/brand_request_cubit.dart'
    as _i1023;
import '../feature/city/cubit/city_cubit.dart' as _i580;
import '../feature/city/data/datasources/city_local_data_source.dart' as _i549;
import '../feature/city/data/repository/city_repository.dart' as _i559;
import '../feature/country/cubit/country_cubit.dart' as _i1047;
import '../feature/country/data/datasources/country_local_data_source.dart'
    as _i1055;
import '../feature/country/data/repository/country_repository.dart' as _i786;
import '../feature/establishments/cubit/establishment_types_cubit.dart'
    as _i234;
import '../feature/establishments/data/datasources/establishment_local_data_source.dart'
    as _i388;
import '../feature/establishments/data/repository/establishment_repository.dart'
    as _i381;
import '../feature/meta/cubit/splash_cubit.dart' as _i972;
import '../feature/meta/sync_service/sync_service.dart' as _i815;
import '../feature/profile/cubit/profile_cubit.dart' as _i508;
import '../feature/profile/data/repository/profile_repository_i.dart' as _i458;
import '../feature/profile/domain/repository/profile_repository.dart' as _i58;
import 'app_module.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i454.SupabaseClient>(() => appModule.supabaseClient);
    gh.lazySingleton<_i704.AuthRepository>(
      () => _i350.IAuthRepository(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i58.ProfileRepository>(
      () => _i458.ProfileRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.singleton<_i508.ProfileCubit>(
      () => _i508.ProfileCubit(gh<_i58.ProfileRepository>()),
    );
    gh.lazySingleton<_i838.BrandRequestRepository>(
      () => _i181.BrandRequestRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i899.AuthCubit>(
      () => _i899.AuthCubit(gh<_i704.AuthRepository>()),
    );
    gh.factory<_i549.CityLocalDataSource>(
      () => _i549.CityLocalDataSource(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i1055.CountryLocalDataSource>(
      () => _i1055.CountryLocalDataSource(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i388.EstablishmentLocalDataSource>(
      () => _i388.EstablishmentLocalDataSource(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i1023.BrandRequestCubit>(
      () => _i1023.BrandRequestCubit(gh<_i838.BrandRequestRepository>()),
    );
    gh.lazySingleton<_i559.ICityRepository>(
      () => _i559.CityRepository(
        gh<_i454.SupabaseClient>(),
        gh<_i549.CityLocalDataSource>(),
      ),
    );
    gh.singleton<_i580.CityCubit>(
      () => _i580.CityCubit(gh<_i559.ICityRepository>()),
    );
    gh.lazySingleton<_i381.IEstablishmentRepository>(
      () => _i381.EstablishmentRepository(
        gh<_i454.SupabaseClient>(),
        gh<_i388.EstablishmentLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i786.ICountryRepository>(
      () => _i786.CountryRepository(
        gh<_i454.SupabaseClient>(),
        gh<_i1055.CountryLocalDataSource>(),
      ),
    );
    gh.singleton<_i234.EstablishmentTypesCubit>(
      () => _i234.EstablishmentTypesCubit(gh<_i381.IEstablishmentRepository>()),
    );
    gh.singleton<_i1047.CountryCubit>(
      () => _i1047.CountryCubit(gh<_i786.ICountryRepository>()),
    );
    gh.lazySingleton<_i815.SyncService>(
      () => _i815.SyncService(
        gh<_i454.SupabaseClient>(),
        gh<_i381.IEstablishmentRepository>(),
        gh<_i786.ICountryRepository>(),
        gh<_i559.ICityRepository>(),
      ),
    );
    gh.singleton<_i972.SplashCubit>(
      () => _i972.SplashCubit(gh<_i815.SyncService>()),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}
