import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_text_field.dart';
import 'package:side_project/feature/people_search_page/presentation/widget/people_search_result_row.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_search_cubit.dart';

@RoutePage()
class PeopleSearchPage extends StatefulWidget {
  const PeopleSearchPage({super.key});

  @override
  State<PeopleSearchPage> createState() => _PeopleSearchPageState();
}

class _PeopleSearchPageState extends State<PeopleSearchPage> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isSearchOpen = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    // По умолчанию сразу открываем поиск — это основной смысл экрана.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch(ProfileSearchCubit cubit) {
    setState(() => _isSearchOpen = !_isSearchOpen);
    if (_isSearchOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    } else {
      _focusNode.unfocus();
      _controller.clear();
      cubit.onQueryChanged('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileSearchCubit>(),
      child: Builder(
        builder: (context) {
          final cubit = context.read<ProfileSearchCubit>();

          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            appBar: AppAppBar(
              automaticallyImplyLeading: true,
              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SizeTransition(sizeFactor: anim, axis: Axis.horizontal, child: child),
                ),
                child: _isSearchOpen
                    ? _AppBarSearchField(
                        key: const ValueKey('searchField'),
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: cubit.onQueryChanged,
                      )
                    : Text(
                        'Поиск',
                        key: const ValueKey('title'),
                        style: AppTextStyle.base(18, fontWeight: FontWeight.w700),
                      ),
              ),
              actions: [
                IconButton(
                  icon: Icon((_isSearchOpen ? Icons.close_rounded : AppIcons.search.icon)),
                  onPressed: () => _toggleSearch(cubit),
                ),
              ],
            ),
            body: BlocBuilder<ProfileSearchCubit, ProfileSearchState>(
              builder: (context, state) {
                if (state.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.base(14, color: AppColors.subTextColor),
                      ),
                    ),
                  );
                }

                final q = state.query.trim();
                if (q.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Ищите по @нику или имени',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.base(14, color: AppColors.subTextColor),
                      ),
                    ),
                  );
                }

                if (state.isLoading && state.results.isEmpty) {
                  return const Center(child: AppCircularProgressIndicator(dimension: 28, strokeWidth: 2));
                }

                if (state.results.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Ничего не найдено',
                        style: AppTextStyle.base(14, color: AppColors.subTextColor),
                      ),
                    ),
                  );
                }

                return Stack(
                  children: [
                    ListView.separated(
                      itemCount: state.results.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border.withValues(alpha: 0.55)),
                      itemBuilder: (context, i) => PeopleSearchResultRow(hit: state.results[i]),
                    ),
                    if (state.isLoading)
                      const Positioned(
                        top: 10,
                        right: 12,
                        child: AppCircularProgressIndicator(dimension: 18, strokeWidth: 2),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AppBarSearchField extends StatelessWidget {
  const _AppBarSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // Используем общий стиль инпутов проекта, чтобы выглядело единообразно.
    // `AppTextField` — это TextFormField, он нормально работает в AppBar.
    return SizedBox(
      height: 44,
      child: AppTextField(
        hintText: 'Поиск по @нику или имени',
        controller: controller,
        autofocus: false,
        onChanged: onChanged,
        // В AppBar нужно компактнее, иначе текст клипается по высоте.
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        suffixIcon: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.iconMuted, size: 20),
          onPressed: () {
            controller.clear();
            onChanged('');
            focusNode.requestFocus();
          },
        ),
      ),
    );
  }
}

