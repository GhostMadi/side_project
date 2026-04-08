import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/presentation/cubit/posts_list_cubit.dart';
import 'package:side_project/feature/posts/presentation/widget/posts_section.dart';

/// Переиспользуемый виджет, который показывает посты из [PostsListCubit].
///
/// Важно: **кубит создаётся и вызывается родителем** (как в кластерах) через `BlocProvider.value`.
class PostsListView extends StatelessWidget {
  const PostsListView({super.key, this.onPostTap});

  final void Function(PostModel post)? onPostTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsListCubit, PostsListState>(
      builder: (context, state) {
        return state.when(
          initial: () => const PostsSection(posts: []),
          loading: () => const PostsSection(posts: []),
          loaded: (items) => PostsSection(posts: items, onPostTap: onPostTap),
          error: (_) => const PostsSection(posts: []),
        );
      },
    );
  }
}

