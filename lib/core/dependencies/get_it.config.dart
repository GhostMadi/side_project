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

import '../../feature/cities/data/repository/cities_repository.dart' as _i969;
import '../../feature/cities/data/repository/cities_repository_impl.dart'
    as _i656;
import '../../feature/cities/presentation/cubit/cities_cubit.dart' as _i744;
import '../../feature/cluster/data/repository/cluster_repository.dart' as _i312;
import '../../feature/cluster/presentation/cubit/archived_clusters_cubit.dart'
    as _i684;
import '../../feature/cluster/presentation/cubit/clusters_list_cubit.dart'
    as _i402;
import '../../feature/cluster_create_page/presentation/cubit/cluster_create_cubit.dart'
    as _i721;
import '../../feature/countries/data/repository/countries_repository.dart'
    as _i641;
import '../../feature/countries/data/repository/countries_repository_impl.dart'
    as _i646;
import '../../feature/countries/presentation/cubit/countries_cubit.dart'
    as _i1024;
import '../../feature/login_page/data/repository/auth_repository.dart' as _i722;
import '../../feature/login_page/presentation/cubit/auth_cubit.dart' as _i917;
import '../../feature/post_create_page/data/repository/post_create_repository.dart'
    as _i314;
import '../../feature/post_create_page/presentation/cubit/post_create_cubit.dart'
    as _i651;
import '../../feature/posts/data/repository/posts_repository.dart' as _i305;
import '../../feature/posts/presentation/cubit/post_detail_cubit.dart' as _i368;
import '../../feature/posts/presentation/cubit/posts_list_cubit.dart' as _i84;
import '../../feature/profile/data/repository/profile_repository.dart' as _i42;
import '../../feature/profile/data/repository/profile_repository_impl.dart'
    as _i681;
import '../../feature/profile/presentation/cubit/profile_cubit.dart' as _i499;
import '../../feature/profile/presentation/cubit/profile_search_cubit.dart'
    as _i366;
import '../../feature/profile_categories/data/repository/profile_categories_repository.dart'
    as _i775;
import '../../feature/profile_categories/data/repository/profile_categories_repository_impl.dart'
    as _i394;
import '../../feature/profile_categories/presentation/cubit/profile_categories_cubit.dart'
    as _i122;
import '../../feature_draft/request/data/repository/brand_request_repository_impl.dart'
    as _i1008;
import '../../feature_draft/request/domain/repository/brand_request_repository.dart'
    as _i945;
import '../../feature_draft/request/presentation/cubit/brand_request_cubit.dart'
    as _i993;
import '../locale/app_locale_cubit.dart' as _i97;
import '../network/supabase_edge_functions_invoker.dart' as _i460;
import '../storage/app_locale_prefs_storage.dart' as _i968;
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
    gh.lazySingleton<_i722.AuthRepository>(
      () => _i722.AuthRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i945.BrandRequestRepository>(
      () => _i1008.BrandRequestRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i917.AuthCubit>(
      () => _i917.AuthCubit(gh<_i722.AuthRepository>()),
    );
    gh.lazySingleton<_i969.CitiesRepository>(
      () => _i656.CitiesRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i460.SupabaseEdgeFunctionsInvoker>(
      () => _i460.SupabaseEdgeFunctionsInvoker(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i42.ProfileRepository>(
      () => _i681.ProfileRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i775.ProfileCategoriesRepository>(
      () => _i394.ProfileCategoriesRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i641.CountriesRepository>(
      () => _i646.CountriesRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i305.PostsRepository>(
      () => _i305.PostsRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i968.AppLocalePrefsStorage>(
      () => _i968.AppLocalePrefsStorage(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i312.ClusterRepository>(
      () => _i312.ClusterRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i122.ProfileCategoriesCubit>(
      () =>
          _i122.ProfileCategoriesCubit(gh<_i775.ProfileCategoriesRepository>()),
    );
    gh.factory<_i993.BrandRequestCubit>(
      () => _i993.BrandRequestCubit(gh<_i945.BrandRequestRepository>()),
    );
    gh.lazySingleton<_i1024.CountriesCubit>(
      () => _i1024.CountriesCubit(gh<_i641.CountriesRepository>()),
    );
    gh.lazySingleton<_i744.CitiesCubit>(
      () => _i744.CitiesCubit(gh<_i969.CitiesRepository>()),
    );
    gh.lazySingleton<_i499.ProfileCubit>(
      () => _i499.ProfileCubit(gh<_i42.ProfileRepository>()),
    );
    gh.factory<_i366.ProfileSearchCubit>(
      () => _i366.ProfileSearchCubit(gh<_i42.ProfileRepository>()),
    );
    gh.factory<_i368.PostDetailCubit>(
      () => _i368.PostDetailCubit(gh<_i305.PostsRepository>()),
    );
    gh.factory<_i84.PostsListCubit>(
      () => _i84.PostsListCubit(gh<_i305.PostsRepository>()),
    );
    gh.factory<_i684.ArchivedClustersCubit>(
      () => _i684.ArchivedClustersCubit(gh<_i312.ClusterRepository>()),
    );
    gh.factory<_i402.ClustersListCubit>(
      () => _i402.ClustersListCubit(gh<_i312.ClusterRepository>()),
    );
    gh.factory<_i721.ClusterCreateCubit>(
      () => _i721.ClusterCreateCubit(gh<_i312.ClusterRepository>()),
    );
    gh.lazySingleton<_i97.AppLocaleCubit>(
      () => _i97.AppLocaleCubit(gh<_i968.AppLocalePrefsStorage>()),
    );
    gh.lazySingleton<_i314.PostCreateRepository>(
      () => _i314.PostCreateRepositoryImpl(
        gh<_i460.SupabaseEdgeFunctionsInvoker>(),
        gh<_i312.ClusterRepository>(),
      ),
    );
    gh.factory<_i651.PostCreateCubit>(
      () => _i651.PostCreateCubit(gh<_i314.PostCreateRepository>()),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}
