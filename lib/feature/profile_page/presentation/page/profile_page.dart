import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart' show sl;
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/feature/cluster/presentation/cubit/clusters_list_cubit.dart';
import 'package:side_project/feature/cluster/presentation/widget/clusters_strip_shimmer.dart';
import 'package:side_project/feature/posts/presentation/cubit/posts_list_cubit.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:side_project/feature/profile_page/presentation/cubit/profile_marker_linked_posts_cubit.dart';
import 'package:side_project/feature/profile_page/presentation/cubit/profile_markers_cubit.dart';
import 'package:side_project/feature/profile_page/presentation/page/profile_loaded_body.dart';
import 'package:side_project/feature/profile_page/presentation/page/profile_page_error_top.dart';
import 'package:side_project/feature/profile_page/presentation/page/profile_page_scroll_shell.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ValueNotifier<bool> _refreshingVisual = ValueNotifier(false);
  late final ClustersListCubit _clustersCubit;
  late final PostsListCubit _postsCubit;
  late final ProfileMarkersCubit _markersCubit;
  late final ProfileMarkerLinkedPostsCubit _markerLinkedCubit;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _clustersCubit = sl<ClustersListCubit>();
    _postsCubit = sl<PostsListCubit>();
    _markersCubit = sl<ProfileMarkersCubit>();
    _markerLinkedCubit = sl<ProfileMarkerLinkedPostsCubit>();
    _uid = Supabase.instance.client.auth.currentUser?.id;
    if (_uid != null) {
      _clustersCubit.load(_uid!);
      _postsCubit.loadUserFeed(_uid!);
      _markersCubit.load(_uid!);
      _markerLinkedCubit.load(_uid!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileCubit>().loadMyProfile();
    });
  }

  @override
  void dispose() {
    _refreshingVisual.dispose();
    _clustersCubit.close();
    _postsCubit.close();
    _markersCubit.close();
    _markerLinkedCubit.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final cubit = context.read<ProfileCubit>();
    final isError = cubit.state.maybeWhen(error: (_) => true, orElse: () => false);
    _refreshingVisual.value = true;
    try {
      if (_uid != null) {
        _clustersCubit.load(_uid!);
        _postsCubit.loadUserFeed(_uid!);
        _markersCubit.load(_uid!);
        _markerLinkedCubit.reload();
      }
      if (isError) {
        await cubit.loadMyProfile();
      } else {
        await cubit.refreshMyProfile();
      }
    } finally {
      if (mounted) _refreshingVisual.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom + 88;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      extendBody: true,
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _clustersCubit),
          BlocProvider.value(value: _postsCubit),
          BlocProvider.value(value: _markersCubit),
          BlocProvider.value(value: _markerLinkedCubit),
        ],
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return state.map(
              initial: (_) => ProfilePageScrollShell(
                bottomPad: bottomPad,
                onRefresh: _onRefresh,
                header: const _ProfileLoadingBody(),
              ),
              loading: (_) => ProfilePageScrollShell(
                bottomPad: bottomPad,
                onRefresh: _onRefresh,
                header: const _ProfileLoadingBody(),
              ),
              error: (e) => ProfilePageScrollShell(
                bottomPad: bottomPad,
                onRefresh: _onRefresh,
                top: ProfilePageErrorTop(message: e.message),
                header: const _ProfileLoadingBody(),
              ),
              loaded: (s) => ListenableBuilder(
                listenable: _refreshingVisual,
                builder: (context, _) {
                  return ProfilePageScrollShell(
                    bottomPad: bottomPad,
                    onRefresh: _onRefresh,
                    header: _refreshingVisual.value
                        ? const _ProfileLoadingBody()
                        : ProfileLoadedBody(profile: s.profile),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileLoadingBody extends StatelessWidget {
  const _ProfileLoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileHeader.loading(),
        SizedBox(height: 6),
        Padding(padding: EdgeInsets.only(bottom: 8), child: ClustersStripShimmer()),
      ],
    );
  }
}
