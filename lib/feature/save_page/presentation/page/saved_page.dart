import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_pill_back_nav_overlay.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/save_page/presentation/cubit/saved_page_cubit.dart';
import 'package:side_project/feature/save_page/presentation/widget/saved_page_view.dart';

@RoutePage()
class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  late final SavedPageCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<SavedPageCubit>()..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppAppBar(
          backgroundColor: bg,
          automaticallyImplyLeading: false,
          title: Text(
            'Сохранённое',
            style: AppTextStyle.base(19, fontWeight: FontWeight.w700),
          ),
        ),
        body: AppPillBackNavOverlay(
          child: SavedPageView(
            onPostTap: (PostModel post) async {
              final deleted = await context.router.push<bool>(
                PostDetailRoute(post: post, initialIsSaved: true),
              );
              if (deleted == true && context.mounted) {
                _cubit.removePostLocally(post.id);
              }
            },
          ),
        ),
      ),
    );
  }
}
