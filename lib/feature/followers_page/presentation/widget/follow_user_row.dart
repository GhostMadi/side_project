import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_progressive_network_image.dart';
import 'package:side_project/feature/followers_page/data/models/profile_follow_row.dart';
import 'package:side_project/feature/followers_page/data/repository/follow_list_repository.dart';
import 'package:side_project/feature/followers_page/presentation/cubit/follow_mutation_cubit.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FollowUserRow extends StatefulWidget {
  const FollowUserRow({super.key, required this.row, this.onTap, this.initialIsFollowing});

  final ProfileFollowRow row;
  final VoidCallback? onTap;
  final bool? initialIsFollowing;

  @override
  State<FollowUserRow> createState() => _FollowUserRowState();
}

class _FollowUserRowState extends State<FollowUserRow> {
  late final FollowListRepository _followRepository;
  bool? _isFollowing;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _followRepository = sl<FollowListRepository>();
    _isFollowing = widget.initialIsFollowing;
    if (_isFollowing == null) {
      _loadInitial();
    }
  }

  Future<void> _loadInitial() async {
    setState(() => _isLoading = true);
    try {
      final v = await _followRepository.isFollowing(widget.row.profileId);
      if (!mounted) return;
      setState(() => _isFollowing = v);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isFollowing = false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nick = widget.row.username?.trim();
    final title = (nick != null && nick.isNotEmpty) ? '@$nick' : 'noName';
    final url = widget.row.avatarUrl?.trim();

    return BlocProvider(
      create: (_) => sl<FollowMutationCubit>(),
      child: BlocConsumer<FollowMutationCubit, FollowMutationState>(
        listener: (context, state) {
          state.whenOrNull(
            success: () {
              if (_isFollowing != null) {
                setState(() => _isFollowing = !_isFollowing!);
              }
              context.read<FollowMutationCubit>().reset();
            },
            failure: (msg) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
              context.read<FollowMutationCubit>().reset();
            },
          );
        },
        builder: (context, state) {
          final mutationBusy = state.maybeWhen(inProgress: () => true, orElse: () => false);
          final currentUserId = sl<SupabaseClient>().auth.currentUser?.id;
          final isSelf = currentUserId != null && currentUserId == widget.row.profileId;
          final isFollowing = _isFollowing ?? false;

          Widget trailing;
          if (isSelf) {
            trailing = const SizedBox.shrink();
          } else if (_isLoading) {
            trailing = const AppCircularProgressIndicator(dimension: 20, strokeWidth: 2);
          } else {
            trailing = _FollowButton(
              isFollowing: isFollowing,
              isBusy: mutationBusy,
              onTap: () {
                if (mutationBusy) return;
                final cubit = context.read<FollowMutationCubit>();
                if (isFollowing) {
                  cubit.unfollow(widget.row.profileId);
                } else {
                  cubit.follow(widget.row.profileId);
                }
              },
            );
          }

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap ?? () => context.router.root.push(ProfileForGuestRoute(profileId: widget.row.profileId)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.inputBackground,
                      child: ClipOval(
                        child: url != null && url.isNotEmpty
                            ? AppProgressiveNetworkImage(
                                imageUrl: url,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person_rounded, color: AppColors.iconMuted, size: 28),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    trailing,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({
    required this.isFollowing,
    required this.isBusy,
    required this.onTap,
  });

  final bool isFollowing;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isFollowing ? AppColors.inputBackground : AppColors.primary;
    final fg = isFollowing ? AppColors.textColor : Colors.white;
    final label = isFollowing ? 'Отписаться' : 'Подписаться';

    return SizedBox(
      height: 34,
      child: TextButton(
        onPressed: isBusy ? null : onTap,
        style: TextButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isBusy
            ? AppCircularProgressIndicator(dimension: 16, strokeWidth: 2, color: fg)
            : Text(label, style: AppTextStyle.base(13, fontWeight: FontWeight.w700, color: fg)),
      ),
    );
  }
}
