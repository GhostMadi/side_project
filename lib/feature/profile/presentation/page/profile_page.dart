import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/feature/profile/cubit/profile_cubit.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors;
    return BlocProvider(create: (context) => sl<ProfileCubit>()..loadMyProfile(), child: Scaffold());
  }
}
