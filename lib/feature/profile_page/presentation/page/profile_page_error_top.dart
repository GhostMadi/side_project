import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';

/// Блок ошибки над скелетоном хедера при [ProfileState.error].
class ProfilePageErrorTop extends StatelessWidget {
  const ProfilePageErrorTop({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.subTextColor, fontSize: 13),
          ),
          const SizedBox(height: 8),
          AppButton(
            text: 'Повторить',
            onPressed: () => context.read<ProfileCubit>().loadMyProfile(),
          ),
        ],
      ),
    );
  }
}
