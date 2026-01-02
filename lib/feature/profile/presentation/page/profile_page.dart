import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/user/cubit/user_cubit.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:side_project/feature/profile/presentation/widget/avatar_circle.dart';
import 'package:side_project/feature/profile/presentation/widget/profile_stats.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>()..loadMyStats(),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: AppDimensions.spaceSenior,
              children: [
                const ProfileCircleAvatar(),

                Text(
                  textAlign: TextAlign.center,
                  sl<UserCubit>().currentUser?.fullName ?? 'Без имени',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const ProfileStatsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
