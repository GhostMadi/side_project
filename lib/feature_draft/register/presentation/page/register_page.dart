import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/shared/app_text_field.dart';
import 'package:side_project/feature/login_page/presentation/cubit/auth_cubit.dart';
import 'package:side_project/feature/login_page/presentation/widget/login_google_sign_in_button.dart';
import 'package:sizer/sizer.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (prev, next) =>
          next.maybeMap(authenticated: (_) => true, error: (_) => true, orElse: () => false),
      listener: (context, state) {
        state.whenOrNull(
          authenticated: (_) => context.router.replaceAll([const ApplicationRoute()]),
          error: (message) {
            AppSnackBar.show(context, message: message, kind: AppSnackBarKind.error);
          },
        );
      },
      builder: (context, state) {
        final googleLoading = state.maybeWhen(loading: () => true, orElse: () => false);
        return Scaffold(
          appBar: AppAppBar(automaticallyImplyLeading: true),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 2.h,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 15.h),
                    Text('Create Account'),
                    Text(
                      'Please choose character or image for avatar anf fill\n Nick name',
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      width: 30.h,
                      height: 30.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 1, color: AppColors.hintCardBorder),
                      ),
                      child: const Icon(Icons.person_pin_rounded),
                    ),
                    AppTextField(hintText: 'Nick name'),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: AppColors.subTextColor.withValues(alpha: 0.2)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          child: Text('или', style: TextStyle(color: AppColors.subTextColor)),
                        ),
                        Expanded(
                          child: Divider(color: AppColors.subTextColor.withValues(alpha: 0.2)),
                        ),
                      ],
                    ),
                    LoginGoogleSignInButton(
                      isLoading: googleLoading,
                      onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
