part of 'post_detail_page.dart';

class _PostDetailScaffoldMessage extends StatelessWidget {
  const _PostDetailScaffoldMessage({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: AppTextStyle.base(14, color: AppColors.subTextColor)),
    );
  }
}

class _AuthorFollowButton extends StatelessWidget {
  const _AuthorFollowButton({
    required this.authorId,
    required this.initialIsFollowing,
    required this.currentIsFollowing,
    required this.onChanged,
  });

  final String authorId;
  final bool? initialIsFollowing;
  final bool? currentIsFollowing;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final currentUserId = sl<AuthCubit>().state.maybeWhen(authenticated: (u) => u.id, orElse: () => null);
    final isSelf = currentUserId != null && currentUserId == authorId;
    if (isSelf) return const SizedBox.shrink();

    // Если пользователь уже был подписан при открытии поста — кнопку вообще не показываем.
    if (initialIsFollowing == true) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => sl<FollowMutationCubit>(),
      child: _AuthorFollowButtonBody(
        authorId: authorId,
        initialIsFollowing: initialIsFollowing,
        currentIsFollowing: currentIsFollowing,
        onChanged: onChanged,
      ),
    );
  }
}

class _AuthorFollowButtonBody extends StatelessWidget {
  const _AuthorFollowButtonBody({
    required this.authorId,
    required this.initialIsFollowing,
    required this.currentIsFollowing,
    required this.onChanged,
  });

  final String authorId;
  final bool? initialIsFollowing;
  final bool? currentIsFollowing;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FollowMutationCubit, FollowMutationState>(
      listener: (context, state) async {
        state.whenOrNull(
          success: () async {
            final uid = sl<AuthCubit>().state.maybeWhen(authenticated: (u) => u.id, orElse: () => null);
            final was = initialIsFollowing ?? false;
            final next = !was;
            if (uid != null && uid.isNotEmpty) {
              await sl<ProfileFollowStatusPrefsStorage>().setCached(uid, authorId, next);
            }
            onChanged(next);
            if (context.mounted) {
              context.read<FollowMutationCubit>().reset();
            }
          },
          failure: (msg) {
            AppSnackBar.show(context, message: msg, kind: AppSnackBarKind.error);
            context.read<FollowMutationCubit>().reset();
          },
        );
      },
      builder: (context, state) {
        final busy = state.maybeWhen(inProgress: () => true, orElse: () => false);
        final isFollowing = currentIsFollowing ?? (initialIsFollowing ?? false);

        final label = (currentIsFollowing == null && initialIsFollowing == null)
            ? '...'
            : (isFollowing ? 'Отписаться' : 'Подписаться');

        return AppTextButton(
          text: label,
          onPressed: (busy || (currentIsFollowing == null && initialIsFollowing == null))
              ? () {}
              : () {
                  final cubit = context.read<FollowMutationCubit>();
                  if (isFollowing) {
                    cubit.unfollow(authorId);
                  } else {
                    cubit.follow(authorId);
                  }
                },
        );
      },
    );
  }
}
