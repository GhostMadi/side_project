import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/resources/color_settings/color_extension.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';

class ProfileStatsWidget extends StatelessWidget {
  const ProfileStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // Магия Freezed:
        return state.when(
          // 1. Что показать при загрузке
          loading: () => const Center(child: CircularProgressIndicator()),

          // 2. Что показать при ошибке
          error: (message) => Center(child: Text('Ошибка: $message')),

          // 3. Что показать, когда данные есть
          loaded: (stats) => Container(
            margin: EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMiddle,
            ),
            padding: EdgeInsets.symmetric(
              vertical: AppDimensions.paddingMiddle,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: colors.fourth),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem('Following', stats.followingCount),
                _StatItem('Followers', stats.followersCount),
                _StatItem('Events', stats.eventersCount),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _StatItem(String label, int count) => Column(
    children: [
      Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(label),
    ],
  );
}
