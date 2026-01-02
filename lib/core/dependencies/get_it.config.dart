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
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../feature/login/data/repository/auth_repository_impl.dart' as _i350;
import '../../feature/login/domain/repository/auth_repository.dart' as _i704;
import '../../feature/login/presentation/cubit/auth_cubit.dart' as _i899;
import '../user/cubit/user_cubit.dart' as _i385;
import '../user/data/repository/user_repository_i.dart' as _i852;
import '../user/domain/repository/user_repository.dart' as _i329;
import 'app_module.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i454.SupabaseClient>(() => appModule.supabaseClient);
    gh.lazySingleton<_i329.UserRepository>(
      () => _i852.IUserRepository(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i704.AuthRepository>(
      () => _i350.IAuthRepository(gh<_i454.SupabaseClient>()),
    );
    gh.singleton<_i385.UserCubit>(
      () => _i385.UserCubit(gh<_i329.UserRepository>()),
    );
    gh.lazySingleton<_i899.AuthCubit>(
      () => _i899.AuthCubit(gh<_i704.AuthRepository>()),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}
