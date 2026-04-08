import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart' show sl;
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_text_field.dart';
import 'package:side_project/feature/profile/data/models/profile_search_hit.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_search_cubit.dart';

/// Шторка поиска профиля по нику и имени для отметок (например шаг «детали» при создании поста).
abstract final class ProfilePeopleSearchSheet {
  static Future<ProfileSearchHit?> show(
    BuildContext context, {
    Set<String> excludeProfileIds = const {},
    String title = 'Отметить профиль',
    String searchHint = 'Поиск по @нику или имени',
  }) async {
    final h = MediaQuery.sizeOf(context).height * 0.58;
    return AppBottomSheet.show<ProfileSearchHit>(
      context: context,
      title: title,
      upperCaseTitle: false,
      showCloseButton: true,
      contentHeight: h,
      contentBottomSpacing: 0,
      content: BlocProvider(
        create: (_) => sl<ProfileSearchCubit>(),
        child: _ProfilePeopleSearchBody(excludeProfileIds: excludeProfileIds, searchHint: searchHint),
      ),
    );
  }
}

class _ProfilePeopleSearchBody extends StatefulWidget {
  const _ProfilePeopleSearchBody({
    required this.excludeProfileIds,
    required this.searchHint,
  });

  final Set<String> excludeProfileIds;
  final String searchHint;

  @override
  State<_ProfilePeopleSearchBody> createState() => _ProfilePeopleSearchBodyState();
}

class _ProfilePeopleSearchBodyState extends State<_ProfilePeopleSearchBody> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          hintText: widget.searchHint,
          controller: _search,
          onChanged: (v) => context.read<ProfileSearchCubit>().onQueryChanged(v),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: BlocBuilder<ProfileSearchCubit, ProfileSearchState>(
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
                      'Введите ник или имя',
                      style: AppTextStyle.base(14, color: AppColors.subTextColor),
                    ),
                  ),
                );
              }

              if (state.isLoading && state.results.isEmpty) {
                return const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final visible = state.results
                  .where((h) => !widget.excludeProfileIds.contains(h.id))
                  .toList();

              if (visible.isEmpty) {
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
                    padding: EdgeInsets.only(bottom: 16 + bottom),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: AppColors.border.withValues(alpha: 0.6)),
                    itemBuilder: (context, i) {
                      final hit = visible[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        title: Text(
                          hit.displayLabel,
                          style: AppTextStyle.base(16, color: AppColors.textColor, fontWeight: FontWeight.w500),
                        ),
                        onTap: () => Navigator.pop(context, hit),
                      );
                    },
                  ),
                  if (state.isLoading)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
