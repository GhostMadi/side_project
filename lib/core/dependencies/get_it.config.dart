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
import 'package:isar_community/isar.dart' as _i214;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../feature/account_page/data/account_actions_repository.dart' as _i0;
import '../../feature/account_page/presentation/cubit/account_hibernate_reset_cubit.dart'
    as _i583;
import '../../feature/archive_page/presentation/cubit/archived_posts_cubit.dart'
    as _i258;
import '../../feature/chat/data/repository/chat_repository.dart' as _i425;
import '../../feature/chat/data/repository/chat_repository_impl.dart' as _i188;
import '../../feature/chat/presentation/cubit/chat_conversations_list_cubit.dart'
    as _i941;
import '../../feature/chat/presentation/cubit/chat_message_send_cubit.dart'
    as _i908;
import '../../feature/chat/presentation/cubit/chat_thread_cubit.dart' as _i422;
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
import '../../feature/comment/data/repository/comments_repository.dart' as _i90;
import '../../feature/countries/data/repository/countries_repository.dart'
    as _i641;
import '../../feature/countries/data/repository/countries_repository_impl.dart'
    as _i646;
import '../../feature/countries/presentation/cubit/countries_cubit.dart'
    as _i1024;
import '../../feature/followers_page/data/repository/follow_list_repository.dart'
    as _i838;
import '../../feature/followers_page/presentation/cubit/follow_mutation_cubit.dart'
    as _i55;
import '../../feature/followers_page/presentation/cubit/profile_followers_list_cubit.dart'
    as _i471;
import '../../feature/followers_page/presentation/cubit/profile_following_list_cubit.dart'
    as _i122;
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
import '../../feature/save_page/data/repository/saved_list_repository.dart'
    as _i423;
import '../../feature/save_page/presentation/cubit/saved_page_cubit.dart'
    as _i820;
import '../../feature_draft/request/data/repository/brand_request_repository_impl.dart'
    as _i1008;
import '../../feature_draft/request/domain/repository/brand_request_repository.dart'
    as _i945;
import '../../feature_draft/request/presentation/cubit/brand_request_cubit.dart'
    as _i993;
import '../locale/app_locale_cubit.dart' as _i97;
import '../network/supabase_edge_functions_invoker.dart' as _i460;
import '../storage/app_locale_prefs_storage.dart' as _i968;
import '../storage/kv/isar_kv_store.dart' as _i765;
import '../storage/prefs/app_locale_prefs_storage.dart' as _i263;
import '../storage/prefs/chat_conversations_cache_storage.dart' as _i552;
import '../storage/prefs/chat_thread_cache_storage.dart' as _i631;
import '../storage/prefs/post_reactions_prefs_storage.dart' as _i690;
import '../storage/prefs/post_saves_prefs_storage.dart' as _i31;
import '../storage/prefs/profile_follow_status_prefs_storage.dart' as _i370;
import '../storage/prefs/profile_mini_cache_storage.dart' as _i1030;
import 'app_module.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    await gh.factoryAsync<_i214.Isar>(() => appModule.isar, preResolve: true);
    gh.lazySingleton<_i454.SupabaseClient>(() => appModule.supabaseClient);
    gh.lazySingleton<_i722.AuthRepository>(
      () => _i722.AuthRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i765.IsarKvStore>(
      () => _i765.IsarKvStore(gh<_i214.Isar>()),
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
    gh.lazySingleton<_i552.ChatConversationsCacheStorage>(
      () => _i552.ChatConversationsCacheStorage(gh<_i765.IsarKvStore>()),
    );
    gh.lazySingleton<_i631.ChatThreadCacheStorage>(
      () => _i631.ChatThreadCacheStorage(gh<_i765.IsarKvStore>()),
    );
    gh.lazySingleton<_i690.PostReactionsPrefsStorage>(
      () => _i690.PostReactionsPrefsStorage(gh<_i765.IsarKvStore>()),
    );
    gh.lazySingleton<_i31.PostSavesPrefsStorage>(
      () => _i31.PostSavesPrefsStorage(gh<_i765.IsarKvStore>()),
    );
    gh.lazySingleton<_i370.ProfileFollowStatusPrefsStorage>(
      () => _i370.ProfileFollowStatusPrefsStorage(gh<_i765.IsarKvStore>()),
    );
    gh.lazySingleton<_i1030.ProfileMiniCacheStorage>(
      () => _i1030.ProfileMiniCacheStorage(gh<_i765.IsarKvStore>()),
    );
    gh.lazySingleton<_i968.AppLocalePrefsStorage>(
      () => _i968.AppLocalePrefsStorage(gh<_i765.IsarKvStore>()),
    );
    gh.lazySingleton<_i263.AppLocalePrefsStorage>(
      () => _i263.AppLocalePrefsStorage(gh<_i765.IsarKvStore>()),
    );
    gh.lazySingleton<_i775.ProfileCategoriesRepository>(
      () => _i394.ProfileCategoriesRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i641.CountriesRepository>(
      () => _i646.CountriesRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i42.ProfileRepository>(
      () => _i681.ProfileRepositoryImpl(
        gh<_i454.SupabaseClient>(),
        gh<_i1030.ProfileMiniCacheStorage>(),
      ),
    );
    gh.lazySingleton<_i0.AccountActionsRepository>(
      () => _i0.AccountActionsRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i425.ChatRepository>(
      () => _i188.ChatRepositoryImpl(
        gh<_i454.SupabaseClient>(),
        gh<_i460.SupabaseEdgeFunctionsInvoker>(),
      ),
    );
    gh.lazySingleton<_i838.FollowListRepository>(
      () => _i838.FollowListRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i90.CommentsRepository>(
      () => _i90.CommentsRepositoryImpl(gh<_i454.SupabaseClient>()),
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
    gh.factory<_i55.FollowMutationCubit>(
      () => _i55.FollowMutationCubit(gh<_i838.FollowListRepository>()),
    );
    gh.factory<_i471.ProfileFollowersListCubit>(
      () => _i471.ProfileFollowersListCubit(gh<_i838.FollowListRepository>()),
    );
    gh.factory<_i122.ProfileFollowingListCubit>(
      () => _i122.ProfileFollowingListCubit(gh<_i838.FollowListRepository>()),
    );
    gh.lazySingleton<_i97.AppLocaleCubit>(
      () => _i97.AppLocaleCubit(gh<_i263.AppLocalePrefsStorage>()),
    );
    gh.lazySingleton<_i1024.CountriesCubit>(
      () => _i1024.CountriesCubit(gh<_i641.CountriesRepository>()),
    );
    gh.factory<_i422.ChatThreadCubit>(
      () => _i422.ChatThreadCubit(
        gh<_i425.ChatRepository>(),
        gh<_i454.SupabaseClient>(),
        gh<_i631.ChatThreadCacheStorage>(),
      ),
    );
    gh.lazySingleton<_i744.CitiesCubit>(
      () => _i744.CitiesCubit(gh<_i969.CitiesRepository>()),
    );
    gh.factory<_i908.ChatMessageSendCubit>(
      () => _i908.ChatMessageSendCubit(gh<_i425.ChatRepository>()),
    );
    gh.lazySingleton<_i423.SavedListRepository>(
      () => _i423.SavedListRepositoryImpl(
        gh<_i454.SupabaseClient>(),
        gh<_i31.PostSavesPrefsStorage>(),
      ),
    );
    gh.lazySingleton<_i499.ProfileCubit>(
      () => _i499.ProfileCubit(gh<_i42.ProfileRepository>()),
    );
    gh.factory<_i366.ProfileSearchCubit>(
      () => _i366.ProfileSearchCubit(gh<_i42.ProfileRepository>()),
    );
    gh.factory<_i941.ChatConversationsListCubit>(
      () => _i941.ChatConversationsListCubit(
        gh<_i425.ChatRepository>(),
        gh<_i454.SupabaseClient>(),
        gh<_i552.ChatConversationsCacheStorage>(),
      ),
    );
    gh.lazySingleton<_i305.PostsRepository>(
      () => _i305.PostsRepositoryImpl(
        gh<_i454.SupabaseClient>(),
        gh<_i460.SupabaseEdgeFunctionsInvoker>(),
        gh<_i690.PostReactionsPrefsStorage>(),
        gh<_i31.PostSavesPrefsStorage>(),
        gh<_i1030.ProfileMiniCacheStorage>(),
      ),
    );
    gh.factory<_i583.AccountHibernateResetCubit>(
      () =>
          _i583.AccountHibernateResetCubit(gh<_i0.AccountActionsRepository>()),
    );
    gh.factory<_i258.ArchivedPostsCubit>(
      () => _i258.ArchivedPostsCubit(gh<_i305.PostsRepository>()),
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
    gh.lazySingleton<_i314.PostCreateRepository>(
      () => _i314.PostCreateRepositoryImpl(
        gh<_i460.SupabaseEdgeFunctionsInvoker>(),
        gh<_i312.ClusterRepository>(),
      ),
    );
    gh.factory<_i368.PostDetailCubit>(
      () => _i368.PostDetailCubit(
        gh<_i305.PostsRepository>(),
        gh<_i1030.ProfileMiniCacheStorage>(),
      ),
    );
    gh.factory<_i820.SavedPageCubit>(
      () => _i820.SavedPageCubit(gh<_i423.SavedListRepository>()),
    );
    gh.factory<_i651.PostCreateCubit>(
      () => _i651.PostCreateCubit(gh<_i314.PostCreateRepository>()),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}
